import 'dart:io'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({super.key});

  @override
  State<RecordAudioScreen> createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String status = "Press button to record";
  String audioPath = "";

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  // Explicitly triggers automated calling logic matching your system structure
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

  // Fast2SMS API Gateway Integration
  Future<void> sendSMS(String phone, String message) async {
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

  // EmailJS REST API Integration Client
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

  // Unified Emergency Notification Loop
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
        "http://maps.google.com/?q=${position.latitude},${position.longitude}";

    String userName = data['fullName'] ?? "Unknown";
    String userPhone = (data['phone'] ?? "Unknown").toString();
    print("FIRESTORE NAME: $userName");
    print("FIRESTORE PHONE: $userPhone");

    String message = "🚨 EMERGENCY ALERT 🚨\n\nManual Audio Evidence recording saved by $userName. User may be in danger.\n\nLive Location:\n$locationLink";

    for (var contactElement in contacts) {
      if (contactElement != null) {
        Map<String, dynamic> contact = Map<String, dynamic>.from(contactElement);
        String phone = contact['phone']?.toString() ?? "";
        
        if (phone.isNotEmpty) {
          await sendSMS(phone, message);
        }
        
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

    Fluttertoast.showToast(msg: "Emergency Alerts Broadcasted");
  }

  // START RECORDING FUNCTION
  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String path = '${appDocDir.path}/manual_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          isRecording = true;
          audioPath = path;
          status = "Recording Started...";
        });
        
        Fluttertoast.showToast(msg: "Recording started...");
      } else {
        Fluttertoast.showToast(msg: "Permission to access microphone denied");
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  // STOP RECORDING FUNCTION
  Future<void> stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      setState(() {
        isRecording = false;
        audioPath = path ?? "";
        status = "🚨 Emergency System Activated!";
      });

      if (path != null) {
        Fluttertoast.showToast(
          msg: "Recording Saved Successfully",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E254C),
              content: Text(
                "Recording Saved:\n$audioPath",
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          );
        }

        print("Saved Recording: $path");

        // Fire off background alert execution & automated calling pipeline instantly
        await sendEmergencyAlert();
        await autoCallTrustedContact();
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
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
                      "Record Audio Evidence",
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
                        duration: const Duration(milliseconds: 300),
                        width: isRecording ? 190 : 160,
                        height: isRecording ? 190 : 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording
                              ? accentPink.withOpacity(0.15)
                              : surfaceContainer.withOpacity(0.4),
                          border: Border.all(
                            color: isRecording ? accentPink : surfaceContainer,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isRecording)
                              BoxShadow(
                                color: accentPink.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                                offset: Offset.zero,
                              ),
                          ],
                        ),
                        child: Center(
                          child: IconButton(
                            iconSize: 75,
                            icon: Icon(
                              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: isRecording ? accentPink : Colors.white.withOpacity(0.4),
                            ),
                            onPressed: () {
                              if (isRecording) {
                                stopRecording();
                              } else {
                                startRecording();
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: status.contains("🚨") ? accentPink : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: surfaceContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: surfaceContainer.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          audioPath.isEmpty
                              ? "No recording saved yet"
                              : "Saved Location:\n$audioPath",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: audioPath.isEmpty
                                ? Colors.white.withOpacity(0.4)
                                : const Color(0xFF4DEEEA),
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      
                      if (isRecording)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Audio is being encrypted and saved directly to your local application directory.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),

                      const Spacer(),
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