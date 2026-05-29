import 'package:flutter/material.dart';
import 'home_screen.dart';

class EmergencyContactsSetupScreen
    extends StatefulWidget {

  const EmergencyContactsSetupScreen({
    super.key,
  });

  @override
  State<EmergencyContactsSetupScreen>
  createState() =>
      _EmergencyContactsSetupScreenState();
}

class _EmergencyContactsSetupScreenState
    extends State<EmergencyContactsSetupScreen> {

  final List<Map<String, TextEditingController>>
      contacts = [];

  void addContact() {

    setState(() {

      contacts.add({

        "name":
        TextEditingController(),

        "phone":
        TextEditingController(),

        "relation":
        TextEditingController(),
      });
    });
  }

  @override
  void initState() {

    super.initState();

    addContact();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFE91E63),

        title: const Text(
          "Emergency Contacts",
          style:
          TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Expanded(

              child: ListView.builder(

                itemCount: contacts.length,

                itemBuilder:
                    (context, index) {

                  return Card(

                    child: Padding(

                      padding:
                      const EdgeInsets.all(10),

                      child: Column(

                        children: [

                          TextField(
                            controller:
                            contacts[index]
                            ["name"],
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Name",
                            ),
                          ),

                          TextField(
                            controller:
                            contacts[index]
                            ["phone"],
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Phone",
                            ),
                          ),

                          TextField(
                            controller:
                            contacts[index]
                            ["relation"],
                            decoration:
                            const InputDecoration(
                              labelText:
                              "Relationship",
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(

              onPressed: addContact,

              child: const Text(
                "+ Add Contact",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: () {

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const HomeScreen(),
                    ),
                  );
                },

                child: const Text(
                  "Finish Setup",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}