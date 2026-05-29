import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        title: const Text(
          "Trusted Contacts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(

        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {

            return const Center(
              child: Text(
                "No Contacts Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(

            child: Column(

              children: [

                const SizedBox(height: 20),

                buildContactCard(
                  name: data['contact1Name'] ?? "",
                  phone: data['contact1Phone'] ?? "",
                  relation: data['contact1Relation'] ?? "",
                  color: Colors.pink,
                ),

                buildContactCard(
                  name: data['contact2Name'] ?? "",
                  phone: data['contact2Phone'] ?? "",
                  relation: data['contact2Relation'] ?? "",
                  color: Colors.blue,
                ),

                buildContactCard(
                  name: data['contact3Name'] ?? "",
                  phone: data['contact3Phone'] ?? "",
                  relation: data['contact3Relation'] ?? "",
                  color: Colors.green,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildContactCard({

    required String name,
    required String phone,
    required String relation,
    required Color color,

  }) {

    return Container(

      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

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
            radius: 28,
            backgroundColor: color.withOpacity(0.1),

            child: Icon(
              Icons.person,
              color: color,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  relation,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  phone,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.call,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}