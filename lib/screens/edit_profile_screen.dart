import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController medicalNotesController = TextEditingController();
  final TextEditingController safetyPinController = TextEditingController();

  bool hidePin = true;
  
  String? selectedGender;
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadExistingProfileData();
  }

  Future<void> _loadExistingProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            ageController.text = data['age'] ?? '';
            bloodGroupController.text = data['bloodGroup'] ?? '';
            addressController.text = data['address'] ?? '';
            medicalNotesController.text = data['medicalNotes'] ?? '';
            safetyPinController.text = data['safetyPin'] ?? '';
            if (data['gender'] != null) {
              selectedGender = data['gender'];
            }
          });
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error loading profile metrics.");
      } finally {
        setState(() => _isFetching = false);
      }
    }
  }

  @override
  void dispose() {
    ageController.dispose();
    bloodGroupController.dispose();
    addressController.dispose();
    medicalNotesController.dispose();
    safetyPinController.dispose();
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Vital Parameters",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Medical & Vital Metrics",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryPink),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "This medical profile data will be instantly visible to responders during emergency triggers.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 25),

                    // Age Field
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Age",
                        prefixIcon: const Icon(Icons.cake_outlined, color: primaryPink),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Gender Field Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: "Gender",
                        prefixIcon: const Icon(Icons.people_outline, color: primaryPink),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ["Male", "Female", "Other"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Blood Group Field
                    TextFormField(
                      controller: bloodGroupController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: "Blood Group (e.g., O+, A-)",
                        prefixIcon: const Icon(Icons.bloodtype_outlined, color: primaryPink),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Home Address Field
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Residential Address",
                        prefixIcon: const Icon(Icons.home_outlined, color: primaryPink),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Medical Notes Field
                    TextFormField(
                      controller: medicalNotesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Allergies or Critical Medical Notes",
                        prefixIcon: const Icon(Icons.medical_services_outlined, color: primaryPink),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Security Configurations Section
                    const Divider(height: 32, thickness: 1.2),
                    const Text(
                      "Security Settings",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryPink),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Set a 4-digit safety PIN required to deactivate emergency SOS signals manually.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Fully Formatted Safety PIN Field
                    TextFormField(
                      controller: safetyPinController,
                      obscureText: hidePin,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: "Safety SOS PIN",
                        counterText: "", // Removes standard length text counter label banner
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: primaryPink),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePin = !hidePin;
                            });
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please configure a safety PIN";
                        }
                        if (value.trim().length != 4 || int.tryParse(value) == null) {
                          return "PIN must be exactly 4 numbers";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),

                    // Save Action Button
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
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  final user = FirebaseAuth.instance.currentUser;

                                  if (user != null) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .update({
                                        'age': ageController.text.trim(),
                                        'gender': selectedGender,
                                        'bloodGroup': bloodGroupController.text.trim(),
                                        'address': addressController.text.trim(),
                                        'medicalNotes': medicalNotesController.text.trim(),
                                        'safetyPin': safetyPinController.text.trim(),
                                      });
                                      
                                      Fluttertoast.showToast(msg: "Vitals Updated Successfully!");
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                    } catch (error) {
                                      Fluttertoast.showToast(msg: "Failed to update profile data.");
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  } else {
                                    setState(() => _isLoading = false);
                                    Fluttertoast.showToast(msg: "User session expired.");
                                  }
                                }
                              },
                              child: const Text(
                                "Save Parameters",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}