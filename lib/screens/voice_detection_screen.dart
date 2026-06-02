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

  Future<void> sendSMS(String phone, String message) async {
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
    } catch (e) {
      print("FAST2SMS HTTP ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to send SMS via API");

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
      String phone = contact['phone'] ?? "";
      if (phone.isNotEmpty) {
        await sendSMS(phone, message);
      }
    }

    Fluttertoast.showToast(msg: "Emergency SMS Sent");
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

  void stopListening() {
    speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

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

        Fluttertoast.showToast(msg: "Emergency Alert Activated");
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
    // Theme design systems
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
              // Navigation Header Row
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

                      // Radar Pulsing Circle Element Layout
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

                      // State Label Status Header
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

                      // Frosted dynamic telemetry transcription container box
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

                      // Current status indicator layout
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: status.contains("🚨") ? accentPink : const Color(0xFF4DEEEA), // Cyan when idle/waiting
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const Spacer(),

                      // System Toggle Control CTA Bar Panel
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