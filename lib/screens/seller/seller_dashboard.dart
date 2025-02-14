import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../widgets/image_uploader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'summary_page.dart';

class SellerDashboard extends StatefulWidget {
  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  XFile? _pickedFile;
  Uint8List? _webImage;
  File? _mobileImageFile;
  String? _imageUrl;
  bool _isUploading = false;

  final List<String> _availableCategories = [
    'Donate',
    'Recyclable',
    'Non-Recyclable'
  ];
  final List<String> _selectedCategories = [];

  Future<String?> _pickAndUploadImage() async {
    return await ImageUploader.pickAndUploadImage(context);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    if (_pickedFile != null) {
      return; // Prevent reopening the gallery
    }

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        if (kIsWeb) {
          _webImage =
              Uint8List.fromList(File(pickedFile.path).readAsBytesSync());
        } else {
          _mobileImageFile = File(pickedFile.path);
        }
      });

      setState(() {
        _isUploading = true;
      });

      String? uploadedUrl = await _pickAndUploadImage();

      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
        });
      }

      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveToFirebase() async {
    if (_imageUrl == null || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one category')),
      );
      return; // ❌ Don't reset the page if there's an error!
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to save data')),
        );
        return;
      }

      // Reference to seller's document
      final sellerDoc =
          FirebaseFirestore.instance.collection('sellers').doc(user.uid);

      // Ensure seller document exists
      await sellerDoc.set({
        'name': user.displayName ?? "Unknown Seller",
        'contact': user.email ?? "No contact info",
      }, SetOptions(merge: true));

      // Add new item under seller's `items` subcollection
      await sellerDoc.collection('items').add({
        'imageUrl': _imageUrl,
        'categories': _selectedCategories,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Only reset after successful upload
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            imageUrl: _imageUrl!,
            selectedCategories: _selectedCategories,
          ),
        ),
      );
    } catch (e) {
      print('Error saving to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving item: $e')),
      );
    }
  }

  void _resetForNewUpload() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _pickedFile = null;
        _webImage = null;
        _mobileImageFile = null;
        _imageUrl = null;
        _selectedCategories.clear();
      });
    });
  }

  Widget _getImagePreview() {
    if (_imageUrl != null) {
      return Image.network(_imageUrl!, fit: BoxFit.cover);
    } else if (_webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    } else if (_mobileImageFile != null && !kIsWeb) {
      return Image.file(_mobileImageFile!, fit: BoxFit.cover);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload, size: 48),
          SizedBox(height: 8),
          Text('Upload your rag image here!'),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploadSection(),
              if (_imageUrl != null) ...[
                SizedBox(height: 24),
                Text(
                  'Select Categories:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildCategorySelection(),
                SizedBox(height: 24),
                _buildContinueButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isUploading
                ? Center(child: CircularProgressIndicator())
                : _getImagePreview(),
          ),
        ),
        SizedBox(height: 16),
        if (_imageUrl == null)
          Center(
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: Icon(Icons.photo_camera),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableCategories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) => _toggleCategory(category),
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.blue[100],
          checkmarkColor: Colors.blue[800],
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await _saveToFirebase();
          _resetForNewUpload();
        },
        icon: Icon(Icons.check),
        label: Text('Continue'),
      ),
    );
  }
}
