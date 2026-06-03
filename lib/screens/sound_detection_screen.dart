import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class SoundDetectionScreen extends StatefulWidget {
  const SoundDetectionScreen({super.key});

  @override
  State<SoundDetectionScreen> createState() => _SoundDetectionScreenState();
}

class _SoundDetectionScreenState extends State<SoundDetectionScreen> {
  NoiseMeter? noiseMeter;
  StreamSubscription<NoiseReading>? noiseSubscription;
  final AudioRecorder emergencyRecorder = AudioRecorder();

  bool isListening = false;
  double decibel = 0;
  String status = "Waiting for loud sound...";
  bool alertSent = false;
  bool emergencyRecording = false;
  String emergencyAudioPath = "";

  @override
  void initState() {
    super.initState();
    startDetection();
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

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String locationLink =
        "http://maps.google.com/?q=${position.latitude},${position.longitude}";

    String userName = data['fullName'] ?? "Unknown";
    String userPhone = (data['phone'] ?? "Unknown").toString();
    print("FIRESTORE NAME: $userName");
    print("FIRESTORE PHONE: $userPhone");

    String message = "EMERGENCY! Loud sound detected near $userName. Location: $locationLink";

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

  // Active Microscopic Evidence Track Start
  Future<void> startEmergencyRecording() async {
    if (await emergencyRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();

      emergencyAudioPath =
          "${dir.path}/sound_emergency_${DateTime.now().millisecondsSinceEpoch}.m4a";

      await emergencyRecorder.start(
        const RecordConfig(),
        path: emergencyAudioPath,
      );

      setState(() {
        emergencyRecording = true;
        status = "🎙 Emergency Recording Started";
      });

      print("Sound Emergency Recording Started");
    }
  }

  // Active Microscopic Evidence Track Stop
  Future<void> stopEmergencyRecording() async {
    try {
      final path = await emergencyRecorder.stop();

      setState(() {
        emergencyRecording = false;
        status = "✅ Emergency Recording Saved";
      });

      print("Sound Emergency Recording Saved: $path");

      Fluttertoast.showToast(
        msg: "Emergency Evidence Saved",
      );
    } catch (e) {
      print(e);
    }
  }

  void startDetection() async {
    noiseMeter = NoiseMeter();
    noiseSubscription = noiseMeter!.noise.listen(
      (NoiseReading noiseReading) async {
        setState(() {
          decibel = noiseReading.meanDecibel;
        });

        if (decibel > 85 && !alertSent) {
          alertSent = true;

          setState(() {
            status = "🚨 Loud Scream Detected!";
          });

          await startEmergencyRecording();
          await sendEmergencyAlert();

          Fluttertoast.showToast(
            msg: "Emergency Alert Activated",
          );

          Future.delayed(
            const Duration(seconds: 30),
            () async {
              await stopEmergencyRecording();
              await autoCallTrustedContact();
              alertSent = false;
            },
          );
        }
      },
      onError: (error) {
        print(error);
      },
    );

    setState(() {
      isListening = true;
    });
  }

  void stopDetection() {
    noiseSubscription?.cancel();
    setState(() {
      isListening = false;
    });
  }

  @override
  void dispose() {
    noiseSubscription?.cancel();
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
                      "Sound Detection",
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
                            Icons.graphic_eq_rounded,
                            size: 75,
                            color: isListening ? accentPink : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      Text(
                        isListening ? "Listening for danger sounds..." : "Detection Stopped",
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        decoration: BoxDecoration(
                          color: surfaceContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: surfaceContainer.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Current Sound Level",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${decibel.toStringAsFixed(2)} dB",
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: decibel > 85 ? Colors.redAccent : accentPink,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
                                stopDetection();
                              } else {
                                alertSent = false;
                                startDetection();
                              }
                            },
                            icon: Icon(
                              isListening ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            label: Text(
                              isListening ? "Stop Detection" : "Start Detection",
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