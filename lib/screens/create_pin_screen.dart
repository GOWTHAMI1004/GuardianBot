import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final TextEditingController pinController =
      TextEditingController();

  bool hidePin = true;
  bool loading = false;

  Future<void> savePin() async {
    String pin = pinController.text.trim();

    if (pin.length != 4) {
      Fluttertoast.showToast(
        msg: "PIN must be exactly 4 digits",
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      loading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'safetyPin': pin,
      },
      SetOptions(merge: true),
    );

    setState(() {
      loading = false;
    });

    Fluttertoast.showToast(
      msg: "Safety PIN Created Successfully",
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Safety PIN"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: hidePin,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "Enter 4 Digit PIN",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePin
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePin = !hidePin;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : savePin,
              child: const Text(
                "Save PIN",
              ),
            ),
          ],
        ),
      ),
    );
  }
}