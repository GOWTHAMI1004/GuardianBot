import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  String verificationId = "";

  bool otpSent = false;

  Future<void> signInWithGoogle() async {

    try {

      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication
          googleAuth =
          await googleUser.authentication;

      final credential =
          GoogleAuthProvider.credential(

        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Google Sign-In Failed: $e",
          ),
        ),
      );
    }
  }

  Future<void> sendOTP() async {

    await FirebaseAuth.instance
        .verifyPhoneNumber(

      phoneNumber:
          phoneController.text.trim(),

      verificationCompleted:
          (PhoneAuthCredential credential)
          async {

        await FirebaseAuth.instance
            .signInWithCredential(
          credential,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
           builder: (_) => const ProfileSetupScreen(),
          ),
        );
      },

      verificationFailed:
          (FirebaseAuthException e) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              e.message ??
                  "OTP Failed",
            ),
          ),
        );
      },

      codeSent:
          (String verId,
          int? resendToken) {

        setState(() {

          verificationId = verId;

          otpSent = true;
        });
      },

      codeAutoRetrievalTimeout:
          (String verId) {

        verificationId = verId;
      },
    );
  }

  Future<void> verifyOTP() async {

    try {

      PhoneAuthCredential credential =
          PhoneAuthProvider.credential(

        verificationId:
            verificationId,

        smsCode:
            otpController.text.trim(),
      );

      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Invalid OTP",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.symmetric(
            horizontal: 25,
          ),

          child: SingleChildScrollView(

            child: Column(

              children: [

                const SizedBox(
                    height: 60),

                Image.asset(
                  'assets/images/logo.jpeg',
                  height: 90,
                ),

                const SizedBox(
                    height: 15),

                const Text(

                  "GuardianBot",

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFFE91E63),
                  ),
                ),

                const SizedBox(
                    height: 8),

                const Text(

                  "Welcome Back",

                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                    height: 40),

                
                SizedBox(

                  width:
                      double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    style:
                        ElevatedButton
                            .styleFrom(

                      backgroundColor:
                          const Color(
                              0xFFE91E63),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius
                                .circular(
                                    30),
                      ),
                    ),

onPressed: () {

  showModalBottomSheet(

    context: context,

    isScrollControlled: true,

    builder: (context) {

      return Padding(

        padding: EdgeInsets.only(

          left: 20,
          right: 20,
          top: 20,

          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom +
              20,
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(

              controller: phoneController,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(

                labelText: "Enter Mobile Number",

                hintText: "+919876543210",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: () {

                  Navigator.pop(context);

                  sendOTP();
                },

                child: const Text(
                  "Send OTP",
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
},

