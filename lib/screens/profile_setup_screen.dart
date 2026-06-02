import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? "";
      emailController.text = user.email ?? "";
      phoneController.text = user.phoneNumber ?? "";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium theme palette from the core application dashboard
    const Color backgroundTop = Color(0xFF090D22);
    const Color backgroundBottom = Color(0xFF141933);
    const Color accentPink = Color(0xFFFA4A74);
    const Color surfaceContainer = Color(0xFF1E254C);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Clean, integrated modern header bar replacing the basic AppBar widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const Spacer(),
                    Text(
                      "Profile Setup",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40), // Balanced counter-alignment
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Tell us about yourself",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "This information helps emergency services and guardians recognize you instantly.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Full Name Input Field
                      _buildCustomTextField(
                        controller: nameController,
                        labelText: "Full Name",
                        prefixIcon: Icons.person_outline,
                        accentColor: accentPink,
                        containerColor: surfaceContainer,
                      ),
                      const SizedBox(height: 24),

                      // Email Address Input Field
                      _buildCustomTextField(
                        controller: emailController,
                        labelText: "Email Address",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        accentColor: accentPink,
                        containerColor: surfaceContainer,
                      ),
                      const SizedBox(height: 24),

                      // Phone Number Input Field
                      _buildCustomTextField(
                        controller: phoneController,
                        labelText: "Phone Number",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        accentColor: accentPink,
                        containerColor: surfaceContainer,
                      ),
                      const SizedBox(height: 48),

                      // Submit Action Button Container
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _isLoading
                            ? const Center(
                          child: CircularProgressIndicator(color: accentPink),
                        )
                            : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accentPink.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentPink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              String name = nameController.text.trim();
                              String phone = phoneController.text.trim();

                              if (name.isEmpty || phone.isEmpty) {
                                Fluttertoast.showToast(msg: "Please fill out required fields.");
                                return;
                              }

                              if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                                Fluttertoast.showToast(msg: "Enter valid 10 digit phone number");
                                return;
                              }

                              setState(() => _isLoading = true);
                              final user = FirebaseAuth.instance.currentUser;

                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .set({
                                  'fullName': name,
                                  'email': emailController.text.trim(),
                                  'phone': phone,
                                  'profileCompleted': true,
                                  'createdAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));
                              }

                              setState(() => _isLoading = false);
                              if (!mounted) return;

                              Navigator.pushReplacementNamed(context, '/emergency-contacts');
                            },
                            child: Text(
                              "Save & Continue",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper builder that compiles modern dark input architecture cleanly
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Color accentColor,
    required Color containerColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: containerColor.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: accentColor,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(prefixIcon, color: accentColor, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        ),
      ),
    );
  }
}