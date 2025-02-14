import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/image_uploader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'summary_page.dart';

class SellerDashboard extends StatefulWidget {
  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  String? _imageUrl;
  bool _isUploading = false;
  final List<String> _availableCategories = [
    'Donate',
    'Recyclable',
    'Non-Recyclable'
  ];
  final List<String> _selectedCategories = [];

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? uploadedUrl = await ImageUploader.pickAndUploadImage(context);
      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
        });
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveToFirebase() async {
    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to save data')),
        );
        return;
      }

      final sellerDoc =
          FirebaseFirestore.instance.collection('sellers').doc(user.uid);

      await sellerDoc.set({
        'name': user.displayName ?? "Unknown Seller",
        'email': user.email ?? "No contact info",
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await sellerDoc.collection('items').add({
        'imageUrl': _imageUrl,
        'categories': _selectedCategories,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active'
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            imageUrl: _imageUrl!,
            selectedCategories: List<String>.from(_selectedCategories),
          ),
        ),
      );

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving item: $e')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _imageUrl = null;
      _selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Your Item'),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              SizedBox(height: 24),
              if (_imageUrl != null) ...[
                Text(
                  'Select Categories:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildCategories(),
                SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: _isUploading
                    ? Center(child: CircularProgressIndicator())
                    : _imageUrl != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(_imageUrl!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined,
                                  size: 48, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(
                                'Upload your item image',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
              ),
            ),
          ),
          if (_imageUrl == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: Icon(Icons.photo_library),
                label:
                    Text(_isUploading ? 'Uploading...' : 'Choose from Gallery'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
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
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue[800] : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToFirebase,
            icon: Icon(Icons.check),
            label: Text('Submit'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(0, 45),
              backgroundColor: Colors.green,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetForm,
            icon: Icon(Icons.add_photo_alternate),
            label: Text('New Item'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(0, 45),
            ),
          ),
        ),
      ],
    );
  }
}
