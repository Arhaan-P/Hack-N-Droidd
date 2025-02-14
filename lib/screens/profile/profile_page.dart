import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../login_page.dart';
import 'edit_profile_page.dart';

class ProfileUI extends StatefulWidget {
  @override
  _ProfileUIState createState() => _ProfileUIState();
}

class _ProfileUIState extends State<ProfileUI> {
  File? _image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  // User info variables
  String userType = "";
  String name = "";
  String email = "";
  String phone = "";
  String location = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userData.exists) {
          setState(() {
            Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
            userType = data['role'] ?? ""; // 'seller' or 'buyer'
            name = data['displayName'] ?? "";
            email = currentUser.email ?? "";
            phone = data['phone'] ?? "";
            location = data['location'] ?? "";
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // TODO: Implement Firebase Storage upload for profile picture
    }
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: name,
          email: email,
          phone: phone,
          location: location,
        ),
      ),
    );

    if (result != null) {
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            'displayName': result["name"],
            'phone': result["phone"],
            'location': result["location"],
          });

          await _loadUserData(); // Reload the data
        }
      } catch (e) {
        print('Error updating user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(dialogContext).pop(); // Close dialog

                  // Navigate to LoginPage using MaterialPageRoute
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print('Error signing out: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserTypeBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: userType.toLowerCase() == "seller"
            ? Colors.green[600]
            : Colors.blue[600],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        userType.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildInfoList() {
    return [
      _buildInfoRow(Icons.email, Colors.blueAccent, "Email", email),
      _buildInfoRow(Icons.phone, Colors.orangeAccent, "Phone", phone),
      _buildInfoRow(Icons.location_on, Colors.green, "Location", location),
    ];
  }

  Widget _buildInfoRow(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple[800]!,
                        Colors.deepPurpleAccent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 60.0),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 65.0,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : AssetImage('assets/default_picture.jpg')
                                    as ImageProvider,
                            backgroundColor: Colors.white,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickImage(ImageSource.gallery),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      _buildUserTypeBadge(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.only(top: 45.0),
                          child: Container(
                            width: 310.0,
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: _buildInfoList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 310.0,
                          child: ElevatedButton(
                            onPressed: () => _signOut(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEditPage,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.edit),
      ),
    );
  }
}
