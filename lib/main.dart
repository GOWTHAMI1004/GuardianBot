import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import all user navigation lifecycle screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/emergency_contacts_setup_screen.dart'; 
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GuardianBotApp());
}

class GuardianBotApp extends StatelessWidget {
  const GuardianBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GuardianBot',
      theme: ThemeData(
        primaryColor: const Color(0xFFE91E63),
        useMaterial3: true,
      ),
      // App kicks off directly at the splash loading animation context
      home: const SplashScreen(),
      
      // Explicit Named Route Table registration
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/emergency-contacts': (context) => const EmergencyContactsSetupScreen(),
        // FIXED: 'const' removed from HomeScreen() so it compiles perfectly
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // If no authenticated token session exists locally, direct user back to Auth Landing
    if (user == null) {
      return const LoginScreen();
    }

    // Checking if an authenticated session already holds structural profile documents
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated but has no Firestore document, route straight to Profile Setup
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ProfileSetupScreen();
        }

        // FIXED: 'const' removed from HomeScreen() here as well
        return HomeScreen();
      },
    );
  }
}