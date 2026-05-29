import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;

  /// Handles Google Sign-In and routing logic based on Firestore checks
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Trigger the native Google account picker popup
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker interface
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Obtain authentication details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential for Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign into Firebase using the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 5. Query Firestore to check if this user record already exists
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!mounted) return;

        if (userDoc.exists && userDoc.data() != null) {
          // User exists -> Route straight past setup to Home Screen via named routes
          Fluttertoast.showToast(msg: "Welcome back, ${user.displayName}!");
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Brand New User -> Route into the Profile Setup pipeline via named routes
          Fluttertoast.showToast(msg: "Authentication successful! Let's set up your profile.");
          Navigator.pushReplacementNamed(context, '/profile-setup');
        }
      }
    } catch (e) {
      // Error 1 Fix: Corrected to Toast.LENGTH_LONG
      Fluttertoast.showToast(
        msg: "Sign-In Failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG, 
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Premium theme colors matching your safety application profile
    const Color primaryDeepPurple = Color(0xFF4A154B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Modern Branding Icon Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryDeepPurple.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 80,
                    color: primaryDeepPurple,
                  ),
                ),
                const SizedBox(height: 24),

                // App Branding Title
                Text(
                  "GuardianBot",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryDeepPurple,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle Message
                Text(
                  "Welcome Back",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 64),

                // Professional Action Block (Only Google Button Remains)
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryDeepPurple),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Error 3 Fix: Swapped network image for reliable offline icon
                              const Icon(
                                Icons.g_mobiledata,
                                color: Colors.red,
                                size: 34,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Continue with Google",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
                
                // Fine-print system indicator
                Text(
                  "Your data is completely encrypted and secured",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}