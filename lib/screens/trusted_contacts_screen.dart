import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_screen.dart';
import 'live_location_screen.dart';
import 'profile_screen.dart';

class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Fluttertoast.showToast(msg: "Could not initialize standard voice connection.");
    }
  }

  void _showContactDialog({
    required BuildContext context,
    required User user,
    Map<String, dynamic>? existingContact,
    int? index,
    List<dynamic>? fullContactList,
  }) {
    final isEditing = existingContact != null;
    final nameController = TextEditingController(text: isEditing ? existingContact['name'] : '');
    final phoneController = TextEditingController(text: isEditing ? existingContact['phone'] : '');
    final emailController = TextEditingController(text: isEditing ? existingContact['email'] : '');
    final relationController = TextEditingController(text: isEditing ? existingContact['relation'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? "Edit Contact" : "Add Secure Contact"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name", hintText: "John Doe"),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone", hintText: "+1234567890"),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email Address", hintText: "mother@gmail.com"),
                ),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(labelText: "Relation", hintText: "Spouse, Friend, etc."),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final String name = nameController.text.trim();
                final String phone = phoneController.text.trim();
                final String email = emailController.text.trim();
                final String relation = relationController.text.trim();

                if (name.isEmpty || phone.isEmpty || email.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Name, Phone, and Email cannot be empty.",
                  );
                  return;
                }

                if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                  Fluttertoast.showToast(
                    msg: "Enter valid 10 digit phone number",
                  );
                  return;
                }

                final contactMap = {
                  'name': name,
                  'phone': phone,
                  'email': email,
                  'relation': relation.isEmpty ? 'Friend' : relation,
                };

                final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

                if (isEditing && index != null && fullContactList != null) {
                  List<dynamic> updatedContacts = List.from(fullContactList);
                  updatedContacts[index] = contactMap;
                  await userDocRef.update({'emergencyContacts': updatedContacts});
                  Fluttertoast.showToast(msg: "Contact Updated");
                } else {
                  await userDocRef.update({
                    'emergencyContacts': FieldValue.arrayUnion([contactMap])
                  }).catchError((error) async {
                    await userDocRef.set({
                      'emergencyContacts': [contactMap]
                    }, SetOptions(merge: true));
                  });
                  Fluttertoast.showToast(msg: "Secure Contact Added");
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFE91E63);
    final user = FirebaseAuth.instance.currentUser;

    final List<Color> avatarColors = [
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050B2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Trusted Contacts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please sign in to configure trusted profiles.", style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryPink));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyState(context, user);
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final List<dynamic> rawContacts = userData?['emergencyContacts'] ?? [];

          if (rawContacts.isEmpty) {
            return _buildEmptyState(context, user);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: rawContacts.length,
                  itemBuilder: (context, index) {
                    final contact = rawContacts[index] as Map<String, dynamic>;
                    final String name = contact['name'] ?? 'Named Guardian';
                    final String phone = contact['phone'] ?? '';
                    final String email = contact['email'] ?? 'No Email Added';
                    final String relation = contact['relation'] ?? 'Friend';

                    final Color assignedThemeColor = avatarColors[index % avatarColors.length];

                    return buildContactCard(
                      name: name,
                      phone: phone,
                      email: email,
                      relation: relation,
                      color: assignedThemeColor,
                      onEdit: () => _showContactDialog(
                        context: context,
                        user: user,
                        existingContact: contact,
                        index: index,
                        fullContactList: rawContacts,
                      ),
                      onDelete: () async {
                        List<dynamic> contacts = List.from(rawContacts);
                        contacts.removeAt(index);

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({'emergencyContacts': contacts});

                        Fluttertoast.showToast(msg: "Contact Deleted");
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B33),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _showContactDialog(context: context, user: user),
                      icon: const Icon(Icons.add_moderator_outlined, color: Colors.white),
                      label: const Text(
                        "Add Secure Contact",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161B33),
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiveLocationScreen()));
          }
          if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled),
            label: "Timer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 70, color: Colors.grey.shade600),
          const SizedBox(height: 15),
          const Text(
            "Your Trusted Circles are Empty",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
            onPressed: () => _showContactDialog(context: context, user: user),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Primary Contact", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget buildContactCard({
    required String name,
    required String phone,
    required String email,
    required String relation,
    required Color color,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E4B),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(Icons.person, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  relation,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.call,
              color: Color(0xFFE91E63),
            ),
            onPressed: () {
              if (phone.isNotEmpty) _makePhoneCall(phone);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white70,
            ),
            onSelected: (action) {
              if (action == 'edit') onEdit();
              if (action == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))]),
              ),
            ],
          )
        ],
      ),
    );
  }
}