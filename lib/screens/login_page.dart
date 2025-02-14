import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'buyer/buyer_dashboard.dart';
import 'seller/seller_dashboard.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Duration get loadingTime => const Duration(milliseconds: 2000);

  // Authentication and validation methods remain the same
  bool _validatePassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String?> _authUser(LoginData data) async {
    try {
      if (!await _checkConnectivity()) {
        return 'No internet connection. Please check your network.';
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(data.name)) {
        return 'Please enter a valid email address';
      }

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );

      if (userCredential.user == null) {
        return 'Authentication failed';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account exists with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'user-disabled':
          return 'This account has been disabled';
        default:
          return e.message ?? 'Authentication failed';
      }
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> _signUpUser(SignupData data) async {
    try {
      if (!await _checkConnectivity()) {
        return 'No internet connection. Please check your network.';
      }

      if (!_validatePassword(data.password!)) {
        return 'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character';
      }

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );

      String role =
          (data.additionalSignupData?['role'] ?? 'buyer').toLowerCase();
      if (role != 'buyer' && role != 'seller') {
        role = 'buyer';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': data.name!,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'invalid-email':
          return 'Invalid email format';
        case 'weak-password':
          return 'Password is too weak';
        default:
          return e.message ?? 'Sign up failed';
      }
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      if (!await _checkConnectivity()) {
        return 'No internet connection. Please check your network.';
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account exists with this email';
        case 'invalid-email':
          return 'Invalid email format';
        default:
          return e.message ?? 'Password recovery failed';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        onLogin: _authUser,
        onSignup: _signUpUser,
        onRecoverPassword: _recoverPassword,
        title: 'Hackathon App',
        theme: LoginTheme(
          primaryColor: const Color(0xFF35524A), // Dark teal
          accentColor: const Color(0xFFA2E8DD), // Light turquoise
          errorColor: Colors.redAccent,
          pageColorLight: const Color(0xFF779CAB), // Light blue-grey
          pageColorDark: const Color(0xFF627C85), // Medium blue-grey
          titleStyle: const TextStyle(
            color: Color(0xFF32DE8A), // Bright green
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF35524A), // Dark teal
            elevation: 8,
          ),
          bodyStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFFA2E8DD), // Light turquoise
          ),
          textFieldStyle: const TextStyle(
            color: Color(0xFFA2E8DD), // Light turquoise
          ),
          buttonStyle: const TextStyle(
            color: Color(0xFF35524A), // Dark teal
          ),
          buttonTheme: LoginButtonTheme(
            backgroundColor: const Color(0xFFA2E8DD), // Light turquoise
            highlightColor: const Color(0xFF32DE8A), // Bright green
            elevation: 5.0,
          ),
          inputTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF627C85), // Medium blue-grey
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: Color(0xFFA2E8DD)), // Light turquoise
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: Color(0xFF32DE8A)), // Bright green
            ),
            // Fix for placeholder text overlapping icons
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: const TextStyle(
              color: Color(0xFFA2E8DD), // Light turquoise
            ),
          ),
        ),
        additionalSignupFields: [
          UserFormField(
            keyName: 'role',
            displayName: 'Role',
            icon: const Icon(Icons.person),
            defaultValue: 'buyer',
            fieldValidator: (value) {
              if (value == null ||
                  (value.toLowerCase() != 'buyer' &&
                      value.toLowerCase() != 'seller')) {
                return 'Please enter either "buyer" or "seller"';
              }
              return null;
            },
          ),
        ],
        loginProviders: [
          LoginProvider(
            icon: Icons.g_mobiledata,
            label: 'Google',
            callback: () async {
              try {
                final GoogleSignInAccount? googleUser =
                    await GoogleSignIn().signIn();
                if (googleUser == null) return 'Google sign in cancelled';

                final GoogleSignInAuthentication googleAuth =
                    await googleUser.authentication;
                final credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );

                await FirebaseAuth.instance.signInWithCredential(credential);
                return null;
              } catch (e) {
                return 'Google sign-in failed: ${e.toString()}';
              }
            },
          ),
        ],
        onSubmitAnimationCompleted: () async {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null && context.mounted) {
            final String? selectedRole = await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Your Role'),
                  content:
                      const Text('Please choose your role in the application:'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Buyer'),
                      onPressed: () {
                        Navigator.of(context).pop('buyer');
                        // Add navigation to SellerDashboard after popping the dialog
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BuyerDashboard()),
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Seller'),
                      onPressed: () {
                        Navigator.of(context).pop('seller');
                        // Add navigation to SellerDashboard after popping the dialog
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => SellerDashboard()),
                        );
                      },
                    ),
                  ],
                );
              },
            );

            if (selectedRole != null && context.mounted) {
              try {
                // Save role to Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .set({
                  'email': user.email,
                  'role': selectedRole,
                  'createdAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                // Navigate based on role
                if (context.mounted) {
                  if (selectedRole == 'buyer') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const BuyerDashboard()),
                    );
                  } else if (selectedRole == 'seller') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => SellerDashboard()),
                    );
                  }
                }
              } catch (e) {
                print("Error during role selection: $e");
                // Handle error appropriately
              }
            }
          }
        },
      ),
    );
  }
}
