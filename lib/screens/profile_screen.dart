import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFFE91E63),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    FirebaseAuth.instance.currentUser?.email ??
                        "Guardian User",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "AI Safety Protected",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            buildTile(
              icon: Icons.phone,
              title: "Emergency Contacts",
            ),

            buildTile(
              icon: Icons.location_on,
              title: "Safe Locations",
            ),

            buildTile(
              icon: Icons.mic,
              title: "Voice Trigger",
            ),

            buildTile(
              icon: Icons.security,
              title: "Privacy & Security",
            ),

            buildTile(
              icon: Icons.notifications,
              title: "Notifications",
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

onPressed: () async {

  final GoogleSignIn googleSignIn =
      GoogleSignIn();

  await googleSignIn.signOut();

  await FirebaseAuth.instance.signOut();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) =>
          LoginScreen(),
    ),
        (route) => false,
  );
},
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
          ),
        ],
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
            const Color(0xFFE91E63).withOpacity(0.1),

            child: Icon(
              icon,
              color: const Color(0xFFE91E63),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Icon(Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }
}