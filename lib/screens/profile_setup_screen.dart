import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'emergency_contacts_setup_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    final user =
        FirebaseAuth.instance.currentUser;

    if (user != null) {

      nameController.text =
          user.displayName ?? "";

      emailController.text =
          user.email ?? "";

      phoneController.text =
          user.phoneNumber ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        title: const Text(
          "Profile Setup",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

onPressed: () async {

  final user =
      FirebaseAuth.instance.currentUser;

  if (user != null) {

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({

      'fullName':
          nameController.text.trim(),

      'email':
          emailController.text.trim(),

      'phone':
          phoneController.text.trim(),

      'profileCompleted': true,

    });
  }

  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const EmergencyContactsSetupScreen(),
                    ),
                  );
                },

                child: const Text(
                  "Save & Continue",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}