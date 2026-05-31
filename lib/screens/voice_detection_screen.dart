import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VoiceDetectionScreen extends StatefulWidget {
  const VoiceDetectionScreen({super.key});

  @override
  State<VoiceDetectionScreen> createState() => _VoiceDetectionScreenState();
}

class _VoiceDetectionScreenState extends State<VoiceDetectionScreen> {
  final SpeechToText speechToText = SpeechToText();

  bool isListening = false;
  String spokenText = "AI is monitoring voice continuously";
  String status = "Waiting for voice...";

  @override
  void initState() {
    super.initState();
    startListening();
  }

  // Calls the first trusted contact explicitly using index 0
  Future<void> autoCallTrustedContact() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    List<dynamic> contacts = data['emergencyContacts'] ?? [];
    if (contacts.isEmpty) return;

    String phone = contacts[0]['phone'] ?? "";
    if (phone.isEmpty) return;

    await FlutterPhoneDirectCaller.callNumber(phone);
  }

  // Fast2SMS Send Function
  Future<void> sendSMS(
    String phone,
    String message,
  ) async {
    const String apiKey = "j2ZnO0eWSClGYc8T8xkbRArpy61KZDSCIRq4kXGYRGJOoEfbqD7mzpbOuUGR";

    try {
      print("SENDING SMS TO: $phone");
      final response = await http.post(
        Uri.parse("https://www.fast2sms.com/dev/bulkV2"),
        headers: {
          "authorization": apiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "route": "q",
          "message": message,
          "language": "english",
          "numbers": phone,
        }),
      );

      print("FAST2SMS STATUS: ${response.statusCode}");
      print("FAST2SMS BODY: ${response.body}");

    } catch (e, s) {
      print("SMS ERROR FULL: $e");
      print("STACK TRACE: $s");
    }
  }

  // Clean EmailJS Send via Direct REST API
  Future<void> sendEmergencyEmail(
    String recipientEmail,
    String userName,
    String userPhone,
    String location,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {
          "origin": "http://localhost",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "service_id": "service_w1qsadz",
          "template_id": "template_zoqvluj",
          "user_id": "MDc5uTaB1QnGevaid",
          "template_params": {
            "user_name": userName,
            "user_phone": userPhone,
            "location": location,
            "time": DateTime.now().toString(),
            "to_email": recipientEmail,
          }
        }),
      );

      print("EMAIL STATUS: ${response.statusCode}");
      print("EMAIL BODY: ${response.body}");

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Emergency Email Sent Successfully",
        );
      }
    } catch (e) {
      print("EMAIL FAILED: $e");
    }
  }

  // Completely Re-Assembled Emergency Alert Loop
  Future<void> sendEmergencyAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    List<dynamic> contacts = data['emergencyContacts'] ?? [];

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String locationLink =
        "https://maps.google.com/?q=${position.latitude},${position.longitude}";

String userName = data['fullName'] ?? "Unknown";
String userPhone = data['phone'] ?? "Unknown";
print("FIRESTORE NAME: $userName");
print("FIRESTORE PHONE: $userPhone");

    for (var contact in contacts) {
      String email = contact['email'] ?? "";

      if (email.isNotEmpty) {
        await sendEmergencyEmail(
          email,
          userName,
          userPhone,
          locationLink,
        );
      }
    }

    Fluttertoast.showToast(
      msg: "Emergency Email Sent",
    );
  }

  // START LISTENING
  Future<void> startListening() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        isListening = true;
      });

      speechToText.listen(
        listenMode: ListenMode.confirmation,
        onResult: (result) {
          setState(() {
            spokenText = result.recognizedWords;
          });
          detectDanger(result.recognizedWords);
        },
      );
    }
  }

  // STOP LISTENING
  void stopListening() {
    speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  // DETECT DANGER KEYWORDS
  void detectDanger(String text) {
    List<String> dangerWords = [
      "help",
      "save me",
      "emergency",
      "stop",
      "danger",
      "please help",
    ];

    for (String word in dangerWords) {
      if (text.toLowerCase().contains(word)) {
        autoCallTrustedContact();
        sendEmergencyAlert();

        setState(() {
          status = "🚨 Distress Voice Detected!";
        });

        Fluttertoast.showToast(
          msg: "Emergency Alert Activated",
        );
        break;
      }
    }
  }

  @override
  void dispose() {
    speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffE91E63),
        title: const Text(
          "Distress Voice Detection",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isListening ? 180 : 160,
              height: isListening ? 180 : 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? Colors.red.shade100 : Colors.pink.shade100,
              ),
              child: const Icon(
                Icons.mic,
                size: 90,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              isListening ? "AI Monitoring Active" : "AI Monitoring Stopped",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                spokenText,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                if (isListening) {
                  stopListening();
                } else {
                  startListening();
                }
              },
              icon: Icon(
                isListening ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
              label: Text(
                isListening ? "Stop Monitoring" : "Start Monitoring",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}