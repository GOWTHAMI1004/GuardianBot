import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmergencyContactsSetupScreen extends StatefulWidget {
  const EmergencyContactsSetupScreen({
    super.key,
  });

  @override
  State<EmergencyContactsSetupScreen> createState() =>
      _EmergencyContactsSetupScreenState();
}

class _EmergencyContactsSetupScreenState
    extends State<EmergencyContactsSetupScreen> {
  final List<Map<String, TextEditingController>> contacts = [];
  bool _isLoading = false;

  void addContact() {
    if (contacts.length >= 5) {
      Fluttertoast.showToast(msg: "Maximum limit of 5 trusted contacts reached.");
      return;
    }
    setState(() {
      contacts.add({
        "name": TextEditingController(),
        "phone": TextEditingController(),
        "relation": TextEditingController(),
        "email": TextEditingController(),
      });
    });
  }

  void removeContact(int index) {
    if (contacts.length > 1) {
      setState(() {
        contacts[index]["name"]?.dispose();
        contacts[index]["phone"]?.dispose();
        contacts[index]["relation"]?.dispose();
        contacts[index]["email"]?.dispose();
        contacts.removeAt(index);
      });
    } else {
      Fluttertoast.showToast(msg: "You must add at least one emergency contact.");
    }
  }

  @override
  void initState() {
    super.initState();
    addContact();
  }

  @override
  void dispose() {
    for (var contact in contacts) {
      contact["name"]?.dispose();
      contact["phone"]?.dispose();
      contact["relation"]?.dispose();
      contact["email"]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme palette constants matching profile setup
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
              // Clean Integrated Navigation Top Bar
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
                      "Emergency Contacts",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Scrollable Guardians Workspace Area
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: surfaceContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: surfaceContainer.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Guardian #${index + 1}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: accentPink,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (contacts.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                  onPressed: () => removeContact(index),
                                )
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Input Fields inside card context
                          _buildInnerField(
                            controller: contacts[index]["name"]!,
                            labelText: "Trusted Guardian Name",
                            icon: Icons.person_outline_rounded,
                            accentColor: accentPink,
                          ),
                          const SizedBox(height: 16),
                          _buildInnerField(
                            controller: contacts[index]["phone"]!,
                            labelText: "Mobile Number",
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            accentColor: accentPink,
                          ),
                          const SizedBox(height: 16),
                          _buildInnerField(
                            controller: contacts[index]["relation"]!,
                            labelText: "Relationship (e.g., Mother, Friend)",
                            icon: Icons.family_restroom_outlined,
                            accentColor: accentPink,
                          ),
                          const SizedBox(height: 16),
                          _buildInnerField(
                            controller: contacts[index]["email"]!,
                            labelText: "Email Address",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            accentColor: accentPink,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Dynamic Actions Layout Bar
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Styled Dynamic Contact Append Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentPink,
                        side: const BorderSide(color: accentPink, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                      onPressed: addContact,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        "Add Another Guardian",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Final Submit Configuration CTA Panel
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: accentPink))
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
                                  List<Map<String, String>> contactDataList = [];

                                  for (var contact in contacts) {
                                    String name = contact["name"]!.text.trim();
                                    String phone = contact["phone"]!.text.trim();
                                    String relation = contact["relation"]!.text.trim();
                                    String email = contact["email"]!.text.trim();

                                    if (name.isEmpty || phone.isEmpty || relation.isEmpty || email.isEmpty) {
                                      Fluttertoast.showToast(msg: "Fill all fields");
                                      return;
                                    }

                                    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                                      Fluttertoast.showToast(msg: "Phone number must be 10 digits");
                                      return;
                                    }

                                    contactDataList.add({
                                      "name": name,
                                      "phone": phone,
                                      "relation": relation,
                                      "email": email,
                                    });
                                  }

                                  setState(() => _isLoading = true);
                                  final user = FirebaseAuth.instance.currentUser;

                                  if (user != null) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .update({
                                      'emergencyContacts': contactDataList,
                                      'contactsConfigured': true,
                                    });
                                  }

                                  setState(() => _isLoading = false);
                                  if (!mounted) return;

                                  Fluttertoast.showToast(msg: "Setup Complete!");
                                  Navigator.pushReplacementNamed(context, '/home');
                                },
                                child: Text(
                                  "Finish Setup",
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
            ],
          ),
        ),
      ),
    );
  }

  // Individual field component nested cleanly inside the dark frosted contact block
  Widget _buildInnerField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required Color accentColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF090D22).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
        cursorColor: accentColor,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.35), fontSize: 13),
          floatingLabelStyle: GoogleFonts.inter(color: accentColor, fontWeight: FontWeight.w600),
          prefixIcon: Icon(icon, color: accentColor, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 4.0),
        ),
      ),
    );
  }
}