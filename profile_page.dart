import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edit_profile_page.dart';

class ProfileUI extends StatefulWidget {
  @override
  _ProfileUIState createState() => _ProfileUIState();
}

class _ProfileUIState extends State<ProfileUI> {
  File? _image;
  final picker = ImagePicker();

  // User info variables
  String userType = "SELLER";
  String name = "User Name";
  String email = "user@example.com";
  String phone = "+91 9876543210";
  String location = "Chennai, India";

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfilePage(
              name: name,
              email: email,
              phone: phone,
              location: location,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        name = result["name"];
        email = result["email"];
        phone = result["phone"];
        location = result["location"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            backgroundImage:
                                _image != null
                                    ? FileImage(_image!)
                                    : AssetImage('assets/default_picture.jpg')
                                        as ImageProvider,
                            backgroundColor: Colors.white,
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
                    child: Card(
                      margin: EdgeInsets.only(top: 45.0),
                      child: Container(
                        width: 310.0,
                        height: 290.0,
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildInfoList(),
                        ),
                      ),
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

  Widget _buildUserTypeBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: userType == "SELLER" ? Colors.green[600] : Colors.blue[600],
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
      _buildInfoRow(Icons.home, Colors.green, "Location", location),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13.0, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
