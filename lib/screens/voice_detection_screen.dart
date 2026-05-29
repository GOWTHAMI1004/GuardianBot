import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class VoiceDetectionScreen extends StatefulWidget {
  const VoiceDetectionScreen({super.key});

  @override
  State<VoiceDetectionScreen> createState() =>
      _VoiceDetectionScreenState();
}

class _VoiceDetectionScreenState
    extends State<VoiceDetectionScreen> {

  final SpeechToText speechToText =
      SpeechToText();

  bool isListening = false;

  String spokenText =
      "AI is monitoring voice continuously";

  String status =
      "Waiting for voice...";

  // AUTO START LISTENING

  @override
  void initState() {

    super.initState();

    startListening();
  }

  // EMERGENCY ALERT FUNCTION

  Future<void> sendEmergencyAlert() async {

    bool serviceEnabled;
    LocationPermission permission;

    // CHECK LOCATION SERVICE

    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    // CHECK LOCATION PERMISSION

    permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();
    }

    // GET CURRENT LOCATION

    Position position =
        await Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );

    String locationLink =
        "https://maps.google.com/?q="
        "${position.latitude},${position.longitude}";

    // EMERGENCY MESSAGE

    String message =
        "🚨 EMERGENCY ALERT 🚨\n\n"
        "Danger keyword detected.\n"
        "I need help.\n\n"
        "Live Location:\n"
        "$locationLink";

    // OPEN WHATSAPP

    final Uri whatsapp = Uri.parse(

      "https://wa.me/?text="
      "${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      whatsapp,
      mode: LaunchMode.externalApplication,
    );
  }

  // START LISTENING

  Future<void> startListening() async {

    bool available =
        await speechToText.initialize();

    if (available) {

      setState(() {

        isListening = true;
      });

      speechToText.listen(

        listenMode: ListenMode.confirmation,

        onResult: (result) {

          setState(() {

            spokenText =
                result.recognizedWords;
          });

          detectDanger(
              result.recognizedWords);
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

      if (text
          .toLowerCase()
          .contains(word)) {

        // SEND ALERT

        sendEmergencyAlert();

        setState(() {

          status =
          "🚨 Distress Voice Detected!";
        });

        // SHOW ALERT POPUP

        showDialog(
          context: context,

          builder: (_) => AlertDialog(

            title: const Text(
              "Emergency Alert",
            ),

            content: const Text(
              "Danger keyword detected.\nEmergency alert activated.",
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
        backgroundColor:
        const Color(0xffE91E63),

        title: const Text(
          "Distress Voice Detection",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            // MIC ANIMATION

            AnimatedContainer(
              duration:
              const Duration(
                  milliseconds: 300),

              width: isListening
                  ? 180
                  : 160,

              height: isListening
                  ? 180
                  : 160,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: isListening
                    ? Colors.red.shade100
                    : Colors.pink.shade100,
              ),

              child: Icon(

                Icons.mic,

                size: 90,

                color: Colors.pink,
              ),
            ),

            const SizedBox(height: 40),

            // AI STATUS

            Text(

              isListening
                  ? "AI Monitoring Active"
                  : "AI Monitoring Stopped",

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // SPOKEN TEXT BOX

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

              child: Text(
                spokenText,

                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // STATUS

            Text(
              status,

              textAlign: TextAlign.center,

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

              style: ElevatedButton.styleFrom(
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
                  stopListening();
                } else {
                  startListening();
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
                    ? "Stop Monitoring"
                    : "Start Monitoring",

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