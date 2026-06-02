import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateUser();
  }

  Future<void> navigateUser() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    final prefs = await SharedPreferences.getInstance();

    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthChecker(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF090D22),
              Color(0xFF141933),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // High-tech circular avatar framing for the JPEG logo
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Subtle glow effect that matches your voice/sound detection tiles
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFA4A74).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFFA4A74).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        fit: BoxFit.cover, // Ensures it perfectly fills the circular frame
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Guardian',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Bot',
                          style: TextStyle(color: Color(0xFFFA4A74)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "AI Assistance Guardian for Women Safety",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  const CircularProgressIndicator(
                    color: Color(0xFFFA4A74),
                    backgroundColor: Color(0xFF222B54),
                    strokeWidth: 3,
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}