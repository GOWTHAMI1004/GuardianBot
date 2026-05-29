import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;

  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        backgroundColor:
        const Color(0xFFE91E63),

        title: const Text(

          "Create Account",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.symmetric(
            horizontal: 25,
          ),

          child: SingleChildScrollView(

            child: Column(

              children: [

                const SizedBox(height: 40),

                Image.asset(
                  'assets/images/logo.jpeg',
                  height: 90,
                ),

                const SizedBox(height: 20),

                const Text(

                  "GuardianBot",

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),

                const SizedBox(height: 40),

                // FULL NAME

                TextField(

                  controller: nameController,

                  decoration: InputDecoration(

                    hintText: "Full Name",

                    filled: true,

                    fillColor:
                    Colors.grey.shade100,

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // EMAIL

                TextField(

                  controller: emailController,

                  decoration: InputDecoration(

                    hintText: "Email",

                    filled: true,

                    fillColor:
                    Colors.grey.shade100,

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD

                TextField(

                  controller: passwordController,

                  obscureText: hidePassword,

                  decoration: InputDecoration(

                    hintText: "Password",

                    filled: true,

                    fillColor:
                    Colors.grey.shade100,

                    suffixIcon: IconButton(

                      icon: Icon(

                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {

                        setState(() {

                          hidePassword =
                          !hidePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CONFIRM PASSWORD

                TextField(

                  controller:
                  confirmPasswordController,

                  obscureText:
                  hideConfirmPassword,

                  decoration: InputDecoration(

                    hintText: "Confirm Password",

                    filled: true,

                    fillColor:
                    Colors.grey.shade100,

                    suffixIcon: IconButton(

                      icon: Icon(

                        hideConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {

                        setState(() {

                          hideConfirmPassword =
                          !hideConfirmPassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // CREATE ACCOUNT BUTTON

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(0xFFE91E63),

                      shape: RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                    ),

                    onPressed: () async {

                      String email =
                      emailController.text.trim();

                      String password =
                      passwordController.text.trim();

                      String confirmPassword =
                      confirmPasswordController
                          .text
                          .trim();

                      if (nameController.text.isEmpty ||

                          email.isEmpty ||

                          password.isEmpty ||

                          confirmPassword.isEmpty) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Please fill all fields",
                            ),
                          ),
                        );

                        return;
                      }

                      // EMAIL VALIDATION

                      if (!email.contains("@") ||

                          !email.contains(".")) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Enter valid email",
                            ),
                          ),
                        );

                        return;
                      }

                      // PASSWORD LENGTH

                      if (password.length < 6) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Password must be at least 6 characters",
                            ),
                          ),
                        );

                        return;
                      }

                      // PASSWORD MATCH

                      if (password != confirmPassword) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Passwords do not match",
                            ),
                          ),
                        );

                        return;
                      }

                      try {

                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(

                          email: email,

                          password: password,
                        );

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Account Created Successfully",
                            ),
                          ),
                        );

                        // GO TO ONBOARDING

                        Navigator.pushReplacement(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                            const OnboardingScreen(),
                          ),
                        );

                      } on FirebaseAuthException
                      catch (e) {

                        String message =
                            "Signup Failed";

                        if (e.code ==
                            'email-already-in-use') {

                          message =
                          "Email already exists";
                        }

                        else if (e.code ==
                            'invalid-email') {

                          message =
                          "Invalid email address";
                        }

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          SnackBar(
                            content: Text(message),
                          ),
                        );
                      }
                    },

                    child: const Text(

                      "Create Account",

                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

