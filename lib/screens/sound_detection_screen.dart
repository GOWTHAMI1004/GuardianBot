import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SoundDetectionScreen extends StatefulWidget {
  const SoundDetectionScreen({super.key});

  @override
  State<SoundDetectionScreen> createState() =>
      _SoundDetectionScreenState();
}

class _SoundDetectionScreenState
    extends State<SoundDetectionScreen> {

  NoiseMeter? noiseMeter;

  StreamSubscription<NoiseReading>? noiseSubscription;

  bool isListening = false;

  double decibel = 0;

  String status =
      "Waiting for loud sound...";

  bool alertSent = false;

  // AUTO START DETECTION

  @override
  void initState() {

    super.initState();

    startDetection();
  }

  // START SOUND DETECTION

  void startDetection() async {

    noiseMeter = NoiseMeter();

    noiseSubscription =
        noiseMeter!.noise.listen(

      (NoiseReading noiseReading) {

        setState(() {

          decibel =
              noiseReading.meanDecibel;
        });

        // DETECT LOUD SOUND

        if (decibel > 85 &&
            alertSent == false) {

          alertSent = true;

          setState(() {

            status =
            "🚨 Loud Scream Detected!";
          });

          sendEmergencyAlert();
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

  // STOP DETECTION

  void stopDetection() {

    noiseSubscription?.cancel();

    setState(() {

      isListening = false;
    });
  }

  // SEND WHATSAPP ALERT

  Future<void> sendEmergencyAlert() async {

    bool serviceEnabled;
    LocationPermission permission;

    // CHECK LOCATION SERVICE

    serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    // CHECK PERMISSION

    permission =
        await Geolocator
            .checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();
    }

    // GET CURRENT LOCATION

    Position position =
        await Geolocator
            .getCurrentPosition(
      desiredAccuracy:
      LocationAccuracy.high,
    );

    String locationLink =
        "https://maps.google.com/?q="
        "${position.latitude},${position.longitude}";

    // EMERGENCY MESSAGE

    String message =
        "🚨 EMERGENCY ALERT 🚨\n\n"
        "Loud scream detected.\n"
        "User may be in danger.\n\n"
        "Live Location:\n"
        "$locationLink";

    // OPEN WHATSAPP

    final Uri whatsapp = Uri.parse(

      "https://wa.me/?text="
      "${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      whatsapp,
      mode:
      LaunchMode.externalApplication,
    );

    // SHOW ALERT POPUP

    showDialog(
      context: context,

      builder: (_) => AlertDialog(

        title: const Text(
          "Emergency Alert",
        ),

        content: const Text(
          "Loud scream detected.\nEmergency alert activated.",
        ),

        actions: [

          TextButton(
            onPressed: () {

              Navigator.pop(context);
            },

            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {

    noiseSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor:
        const Color(0xffE91E63),

        title: const Text(
          "Sound Detection",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            // SOUND ANIMATION

            AnimatedContainer(
              duration:
              const Duration(
                  milliseconds: 300),

              width: isListening
                  ? 190
                  : 160,

              height: isListening
                  ? 190
                  : 160,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: isListening
                    ? Colors.red.shade100
                    : Colors.pink.shade100,
              ),

              child: const Icon(

                Icons.graphic_eq,

                size: 90,

                color: Colors.pink,
              ),
            ),

            const SizedBox(height: 40),

            // AI STATUS

            Text(

              isListening
                  ? "Listening for danger sounds..."
                  : "Detection Stopped",

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // SOUND LEVEL BOX

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(25),

                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.grey.shade300,
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Column(
                children: [

                  const Text(
                    "Current Sound Level",

                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${decibel.toStringAsFixed(2)} dB",

                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight:
                      FontWeight.bold,

                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // STATUS

            Text(
              status,

              textAlign:
              TextAlign.center,

              style: const TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // STOP BUTTON

            ElevatedButton.icon(

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.pink,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
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

                isListening
                    ? Icons.stop
                    : Icons.play_arrow,

                color: Colors.white,
              ),

              label: Text(

                isListening
                    ? "Stop Detection"
                    : "Start Detection",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}