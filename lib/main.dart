import 'screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_screen.dart';
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
      ),

      home: const SplashScreen(),
    );
  }
}

class AuthChecker extends StatelessWidget {

  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {

      return LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(

      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(

            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {

          return const OnboardingScreen();
        }

        return const HomeScreen();
      },
    );
  }
}