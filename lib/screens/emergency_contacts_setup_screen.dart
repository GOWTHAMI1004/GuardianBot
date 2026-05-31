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

class _EmergencyContactsSetupScreenState extends State<EmergencyContactsSetupScreen> {
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
        "email": TextEditingController(), // Added email controller
      });
    });
  }

  void removeContact(int index) {
    if (contacts.length > 1) {
      setState(() {
        contacts[index]["name"]?.dispose();
        contacts[index]["phone"]?.dispose();
        contacts[index]["relation"]?.dispose();
        contacts[index]["email"]?.dispose(); // Disposed email controller
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
      contact["email"]?.dispose(); // Disposed email controller
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryPink,
        elevation: 0,
        title: Text(
          "Emergency Contacts",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                  color: primaryPink,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => removeContact(index),
                              )
                            ],
                          ),
                          TextField(
                            controller: contacts[index]["name"],
                            decoration: const InputDecoration(
                              labelText: "Trusted Guardian Name",
                              prefixIcon: Icon(Icons.person, size: 20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contacts[index]["phone"],
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Mobile Number",
                              prefixIcon: Icon(Icons.phone, size: 20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Added Email TextField here
                          TextField(
                            controller: contacts[index]["email"],
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(Icons.email, size: 20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contacts[index]["relation"],
                            decoration: const InputDecoration(
                              labelText: "Relationship (e.g., Mother, Friend)",
                              prefixIcon: Icon(Icons.family_restroom, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryPink,
                side: const BorderSide(color: primaryPink, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: addContact,
              icon: const Icon(Icons.add),
              label: Text("Add Another Guardian", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryPink))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        List<Map<String, String>> contactDataList = [];
                        
                        for (var contact in contacts) {
                          String name = contact["name"]!.text.trim();
                          String phone = contact["phone"]!.text.trim();
                          String relation = contact["relation"]!.text.trim();
                          String email = contact["email"]!.text.trim(); // Gathered email value

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
                            "email": email, // Added email field map update
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
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}