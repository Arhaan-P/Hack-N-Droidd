// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'screens/login_page.dart';
// import 'screens/buyer/buyer_dashboard.dart';
// import 'firebase_options.dart';
// import 'screens/profile/profile_page.dart';
// import 'screens/seller/seller_dashboard.dart';
// import 'widgets/bottom_nav_scaffold.dart';
// import 'widgets/role_selection_dialog.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Hackathon App',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // If no user is logged in, show login page
//           if (!snapshot.hasData) {
//             return const LoginPage();
//           }

//           // User is logged in, check their role
//           return FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(snapshot.data!.uid)
//                 .get(),
//             builder: (context, userSnapshot) {
//               if (userSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               // If no user document exists, send to login
//               if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
//                 return const LoginPage();
//               }

//               final userData =
//                   userSnapshot.data!.data() as Map<String, dynamic>;

//               // If no role exists, show role selection dialog
//               if (!userData.containsKey('role')) {
//                 return FutureBuilder<String?>(
//                   future: showRoleSelectionDialog(context),
//                   builder: (context, roleSnapshot) {
//                     if (roleSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     if (roleSnapshot.hasData) {
//                       // Update user's role in Firestore
//                       FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(snapshot.data!.uid)
//                           .update({'role': roleSnapshot.data});

//                       // Return appropriate dashboard
//                       return BottomNavScaffold(
//                         userRole: roleSnapshot.data!,
//                         child: roleSnapshot.data == 'seller'
//                             ? SellerDashboard()
//                             : BuyerDashboard(),
//                       );
//                     }

//                     return const LoginPage();
//                   },
//                 );
//               }

//               // Role exists, return appropriate dashboard
//               final userRole = userData['role'] as String;
//               return BottomNavScaffold(
//                 userRole: userRole,
//                 child:
//                     userRole == 'seller' ? SellerDashboard() : BuyerDashboard(),
//               );
//             },
//           );
//         },
//       ),
//       routes: {
//         '/login': (context) => const LoginPage(),
//         '/seller/dashboard': (context) => FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(FirebaseAuth.instance.currentUser?.uid)
//                   .get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const LoginPage();
//                 }
//                 return BottomNavScaffold(
//                   userRole: 'seller',
//                   child: SellerDashboard(),
//                 );
//               },
//             ),
//         '/buyer/dashboard': (context) => FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(FirebaseAuth.instance.currentUser?.uid)
//                   .get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const LoginPage();
//                 }
//                 return BottomNavScaffold(
//                   userRole: 'buyer',
//                   child: BuyerDashboard(),
//                 );
//               },
//             ),
//         '/profile': (context) => FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(FirebaseAuth.instance.currentUser?.uid)
//                   .get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const LoginPage();
//                 }
//                 final userData = snapshot.data!.data() as Map<String, dynamic>;
//                 final userRole = userData['role'] as String;
//                 return BottomNavScaffold(
//                   userRole: userRole,
//                   child: ProfileUI(),
//                 );
//               },
//             ),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_page.dart';
import 'screens/buyer/buyer_dashboard.dart';
import 'firebase_options.dart';
import 'screens/profile/profile_page.dart';
import 'screens/seller/seller_dashboard.dart';
import 'widgets/bottom_nav_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hackathon App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const LoginPage();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const LoginPage();
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;

              if (!userData.containsKey('role')) {
                return const LoginPage(); // Ensure role selection before dashboard access
              }

              final userRole = userData['role'] as String;
              print(
                  "Current User Role: $userRole"); // Debugging role assignment
              return BottomNavScaffold(
                userRole: userRole,
                child:
                    userRole == 'seller' ? SellerDashboard() : BuyerDashboard(),
              );
            },
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/seller/dashboard': (context) => _buildDashboard('seller'),
        '/buyer/dashboard': (context) => _buildDashboard('buyer'),
        '/profile': (context) => FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const LoginPage();
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'] as String;
                return BottomNavScaffold(
                  userRole: userRole,
                  child: ProfileUI(),
                );
              },
            ),
      },
    );
  }
}

Widget _buildDashboard(String role) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const LoginPage();
      }
      return BottomNavScaffold(
        userRole: role,
        child: role == 'seller' ? SellerDashboard() : BuyerDashboard(),
      );
    },
  );
}
