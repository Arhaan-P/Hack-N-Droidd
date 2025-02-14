import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      routes: {
        '/seller/dashboard': (context) => BottomNavScaffold(
              userRole: 'seller',
              child: SellerDashboard(),
            ),
        '/buyer/dashboard': (context) => BottomNavScaffold(
              userRole: 'buyer',
              child: BuyerDashboard(),
            ),
        '/profile': (context) => BottomNavScaffold(
              userRole:
                  'seller',
              child: ProfileUI(),
            ),
      },
      home: BottomNavScaffold(
        userRole: 'seller',
        child: SellerDashboard(),
      ),
    );
  }
}
