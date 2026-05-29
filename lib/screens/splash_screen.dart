import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {

    super.initState();

    navigateUser();
  }

  Future<void> navigateUser() async {

    await Future.delayed(
      const Duration(seconds: 3),
    );

    final prefs =
    await SharedPreferences.getInstance();

    bool hasSeenOnboarding =
        prefs.getBool(
          'hasSeenOnboarding',
        ) ??
        false;

    if (!mounted) return;

    if (hasSeenOnboarding) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>
          const AuthChecker(),
        ),
      );
    }

    else {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>
          const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Image.asset(

              'assets/images/logo.jpeg',

              height: 120,
            ),

            const SizedBox(height: 20),

            const Text(

              "GuardianBot",

              style: TextStyle(

                fontSize: 30,

                fontWeight: FontWeight.bold,

                color: Color(0xFFE91E63),
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              "AI Assistance Guardian for Women Safety",

              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(

              color: Color(0xFFE91E63),
            ),
          ],
        ),
      ),
    );
  }
}