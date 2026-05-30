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

  // FIXED BUG 1: Accessing the first contact element from the list safely
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

  // Fast2SMS Send Function with Response Tracking Loggers
  Future<void> sendSMS(
    String phone,
    String message,
  ) async {
    // ⚠️ Remember to paste your REGENERATED Fast2SMS key here
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

    } catch (e) {
      print("FAST2SMS HTTP ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to send SMS via API");
    }
  }

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
    if (contacts.isEmpty) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String locationLink =
        "https://maps.google.com/?q=${position.latitude},${position.longitude}";

    String message =
        "🚨 EMERGENCY ALERT 🚨\n\n"
        "I need help.\n\n"
        "Live Location:\n$locationLink";

    // FIXED BUG 2: Correctly reading target map values element-by-element inside the iteration
    for (var contact in contacts) {
      String phone = contact['phone'] ?? "";

      if (phone.isNotEmpty) {
        await sendSMS(
          phone,
          message,
        );
      }
    }

    Fluttertoast.showToast(
      msg: "Emergency SMS Sent",
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