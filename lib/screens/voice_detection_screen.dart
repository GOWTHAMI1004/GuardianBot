import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceDetectionScreen extends StatefulWidget {
  const VoiceDetectionScreen({super.key});

  @override
  State<VoiceDetectionScreen> createState() => _VoiceDetectionScreenState();
}

class _VoiceDetectionScreenState extends State<VoiceDetectionScreen> {
  final SpeechToText speechToText = SpeechToText();
  final AudioRecorder emergencyRecorder = AudioRecorder();

  bool emergencyTriggered = false;
  bool emergencyRecording = false;

  String emergencyAudioPath = "";
  bool isListening = false;
  String spokenText = "Listening for voice triggers...";
  String status = "AI is monitoring for keywords";

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

    Map<String, dynamic> firstContact =
        Map<String, dynamic>.from(contacts.first);

    String phone = firstContact["phone"].toString();

    if (phone.isEmpty) return;

    await FlutterPhoneDirectCaller.callNumber(phone);
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
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

    String userName = data['fullName'] ?? "Unknown";
    String userPhone = (data['phone'] ?? "Unknown").toString();
    print("FIRESTORE NAME: $userName");
    print("FIRESTORE PHONE: $userPhone");

    // Replicated matching strict map conversion inside the loop context
    for (var contactElement in contacts) {
      if (contactElement != null) {
        Map<String, dynamic> contact =
            Map<String, dynamic>.from(contactElement);

        String email = contact['email']?.toString() ?? "";
        if (email.isNotEmpty) {
          await sendEmergencyEmail(
            email,
            userName,
            userPhone,
            locationLink,
          );
        }
      }
    }

    Fluttertoast.showToast(msg: "Emergency Email Sent");
  }

  // START EMERGENCY AUDIO RECORDING
  Future<void> startEmergencyRecording() async {
    if (await emergencyRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();

      emergencyAudioPath =
          "${dir.path}/emergency_${DateTime.now().millisecondsSinceEpoch}.m4a";

      await emergencyRecorder.start(
        const RecordConfig(),
        path: emergencyAudioPath,
      );

      setState(() {
        emergencyRecording = true;
        status = "🎙 Emergency Recording Started";
      });

      print("Emergency Recording Started");
    }
  }

  // STOP EMERGENCY AUDIO RECORDING
  Future<void> stopEmergencyRecording() async {
    try {
      final path = await emergencyRecorder.stop();

      setState(() {
        emergencyRecording = false;
        status = "✅ Emergency Recording Saved";
      });

      print("Emergency Recording Saved: $path");

      Fluttertoast.showToast(
        msg: "Emergency Evidence Saved",
      );
    } catch (e) {
      print(e);
    }
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
        onResult: (result) async {
          setState(() {
            spokenText = result.recognizedWords;
          });
          await detectDanger(result.recognizedWords);
        },
      );
    }
  }

  void stopListening() {
    speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  Future<void> detectDanger(String text) async {
    if (emergencyTriggered) return;

    List<String> dangerWords = [
      "help",
      "help me",
      "save me",
      "emergency",
      "danger",
      "please help",
      "someone is following me",
      "someone is chasing me",
      "i am scared",
      "i am afraid",
      "i am in danger",
      "call my parents",
      "call my mother",
      "call my father",
      "i feel unsafe",
      "i need help",
      "please save me",
      "there is a stranger",
      "someone is behind me",
      "he is following me",
    ];

    for (String word in dangerWords) {
      if (text.toLowerCase().contains(word)) {
        emergencyTriggered = true;

        await startEmergencyRecording();
        await sendEmergencyAlert();

        setState(() {
          status = "🚨 Distress Voice Detected!";
        });

        Fluttertoast.showToast(
          msg: "Emergency Alert Activated",
        );

        Future.delayed(
          const Duration(seconds: 30),
          () async {
            await stopEmergencyRecording();
            await autoCallTrustedContact();
            emergencyTriggered = false;
          },
        );

        break;
      }
    }
  }

  @override
  void dispose() {
    speechToText.stop();
    emergencyRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      "Distress Voice Detection",
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

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: isListening ? 190 : 160,
                        height: isListening ? 190 : 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening
                              ? accentPink.withOpacity(0.15)
                              : surfaceContainer.withOpacity(0.4),
                          border: Border.all(
                            color: isListening ? accentPink : surfaceContainer,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isListening)
                              BoxShadow(
                                color: accentPink.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                                offset: Offset.zero,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mic_rounded,
                            size: 75,
                            color: isListening ? accentPink : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      Text(
                        isListening ? "AI Monitoring Active" : "AI Monitoring Stopped",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: surfaceContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: surfaceContainer.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          spokenText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: status.contains("🚨") || status.contains("🎙") ? accentPink : const Color(0xFF4DEEEA),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isListening ? Colors.redAccent : accentPink).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isListening ? const Color(0xFFD32F2F) : accentPink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (isListening) {
                                stopListening();
                              } else {
                                startListening();
                              }
                            },
                            icon: Icon(
                              isListening ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            label: Text(
                              isListening ? "Stop Monitoring" : "Start Monitoring",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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