import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSelectionScreen extends StatefulWidget {
  ContactSelectionScreen({super.key});

  @override
  State<ContactSelectionScreen> createState() =>
      _ContactSelectionScreenState();
}

class _ContactSelectionScreenState
    extends State<ContactSelectionScreen> {

  List<Map<String, dynamic>> contacts = [

    {
      "name": "Mom",
      "number": "917756788172",
      "selected": false,
    },

    {
      "name": "Dad",
      "number": "919234567891",
      "selected": false,
    },

    {
      "name": "Sister",
      "number": "919823152634",
      "selected": false,
    },

    {
      "name": "Best Friend",
      "number": "92345679726",
      "selected": false,
    },
  ];

  Future<void> sendWhatsApp() async {

    List selectedContacts = contacts
        .where((c) => c["selected"] == true)
        .toList();

    if (selectedContacts.isEmpty) {
      return;
    }

    String numbers = selectedContacts
        .map((c) => c["number"])
        .join(",");

    String message =
        "🚨 EMERGENCY ALERT 🚨\n\n"
        "I need help.\n\n"
        "My Live Location:\n"
        "https://maps.google.com";

    final Uri whatsapp = Uri.parse(
      "https://wa.me/$numbers?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      whatsapp,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.pink,

        title: const Text(
          "Select Contacts",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(

              itemCount: contacts.length,

              itemBuilder: (context, index) {

                return CheckboxListTile(

                  activeColor: Colors.pink,

                  value: contacts[index]["selected"],

                  title: Text(contacts[index]["name"]),

                  subtitle: Text(contacts[index]["number"]),

                  onChanged: (value) {

                    setState(() {

                      contacts[index]["selected"] = value;
                    });
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),

            child: SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),

                onPressed: sendWhatsApp,

                child: const Text(
                  "Share Live Location",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}