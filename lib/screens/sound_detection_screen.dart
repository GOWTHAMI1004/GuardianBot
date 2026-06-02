import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SoundDetectionScreen extends StatefulWidget {
  const SoundDetectionScreen({super.key});

  @override
  State<SoundDetectionScreen> createState() => _SoundDetectionScreenState();
}

class _SoundDetectionScreenState extends State<SoundDetectionScreen> {
  NoiseMeter? noiseMeter;
  StreamSubscription<NoiseReading>? noiseSubscription;

  bool isListening = false;
  double decibel = 0;
  String status = "Waiting for loud sound...";
  bool alertSent = false;

  @override
  void initState() {
    super.initState();
    startDetection();
  }

  void startDetection() async {
    noiseMeter = NoiseMeter();
    noiseSubscription = noiseMeter!.noise.listen(
          (NoiseReading noiseReading) {
        setState(() {
          decibel = noiseReading.meanDecibel;
        });

        if (decibel > 85 && alertSent == false) {
          alertSent = true;

          setState(() {
            status = "🚨 Loud Scream Detected!";
          });

          autoCallTrustedContact();
          sendEmergencyAlert();

          Fluttertoast.showToast(
            msg: "Emergency Alert Activated",
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

  Future<void> sendEmergencyAlert() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String locationLink = "https://maps.google.com/?q="
        "${position.latitude},${position.longitude}";

    String message = "🚨 EMERGENCY ALERT 🚨\n\n"
        "Loud scream detected.\n"
        "User may be in danger.\n\n"
        "Live Location:\n"
        "$locationLink";

    final Uri whatsapp = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      whatsapp,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void dispose() {
    noiseSubscription?.cancel();
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
              // Clean Navigation Action Top Header
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

                      // Animated Equalizer Audio Visual Ring
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
                            Icons.graphic_eq_rounded,
                            size: 75,
                            color: isListening ? accentPink : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Active Label Text Header
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

                      // Telemetry Decibel Tracking Board Panel
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

                      // Status Tracking Response Element
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: status.contains("🚨") ? accentPink : const Color(0xFF4DEEEA),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const Spacer(),

                      // Dynamic Execution Core Switch Toggle Card
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