import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login_page.dart';
import 'edit_profile_page.dart';

class ProfileUI extends StatefulWidget {
  @override
  _ProfileUIState createState() => _ProfileUIState();
}

class _ProfileUIState extends State<ProfileUI> {
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
            userType = data['role'] ?? "";
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

          await _loadUserData();
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
    try {
      await FirebaseAuth.instance.signOut();
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
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D3250), // Dark navy blue
              Color(0xFF424769), // Lighter navy blue
            ]),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _signOut(context),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFE35D6A), // Softer red
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.deepPurple[800],
            ),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: userType.toLowerCase() == "seller"
                  ? Color(0xFF2E8B57) // Sea green for seller
                  : Color(0xFF4682B4), // Steel blue for buyer
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userType.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color iconColor) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildInfoCard(
                      'Email', email, Icons.email, Color(0xFF5C8AB4)),
                  _buildInfoCard(
                      'Phone', phone, Icons.phone, Color(0xFF67A67D)),
                  _buildInfoCard('Location', location, Icons.location_on,
                      Color(0xFFE3935B))
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEditPage,
        backgroundColor: Color(0xFF7077A1), // Muted blue-purple
        child: Icon(Icons.edit),
        elevation: 4,
      ),
    );
  }
}
