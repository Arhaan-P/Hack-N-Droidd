import 'package:flutter/material.dart';

class BottomNavScaffold extends StatefulWidget {
  final String userRole;
  final Widget child;

  const BottomNavScaffold({
    Key? key,
    required this.userRole,
    required this.child,
  }) : super(key: key);

  @override
  _BottomNavScaffoldState createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to dashboard based on role
        if (widget.userRole.toLowerCase() == 'seller') {
          Navigator.pushReplacementNamed(context, '/seller/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/buyer/dashboard');
        }
        break;
      case 1:
        // Navigate to profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on the profile page
    bool isProfilePage =
        widget.child.runtimeType.toString().toLowerCase().contains('profile');

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: isProfilePage ? 1 : 0,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          elevation: 0,
        ),
      ),
    );
  }
}
