import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shake/shake.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

import 'create_pin_screen.dart';
import 'self_defense_screen.dart';
import 'live_location_screen.dart';
import 'voice_detection_screen.dart';
import 'sound_detection_screen.dart';
import 'record_audio_screen.dart';
import 'trusted_contacts_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer player = AudioPlayer();
  ShakeDetector? detector;
  String _currentUserName = "User";
  bool _isLoadingName = true;

  Future<bool> checkSecuritySetup() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return false;

    final data = doc.data();

    List<dynamic> contacts = data?['emergencyContacts'] ?? [];
    String safetyPin = data?['safetyPin'] ?? "";

    if (contacts.isEmpty || safetyPin.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1B1E4B),
            title: const Text(
              "Complete Security Setup",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: const Text(
              "Please complete:\n\n1. Emergency Contacts\n2. Safety PIN\n\nbefore using GuardianBot features.",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrustedContactsScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Emergency Contacts",
                  style: TextStyle(color: Colors.pink),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatePinScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Create PIN",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        },
      );

      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();

    detector = ShakeDetector.autoStart(
      shakeThresholdGravity: 2.0,
      onPhoneShake: (ShakeEvent event) async {
        print("PHONE SHAKEN");

        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 3000);
        }

        await player.play(
          AssetSource('siren.mp3'),
        );

        await flutterTts.speak("Emergency Alert. Please Help Me.");
      },
    );

    Future.delayed(
      const Duration(milliseconds: 800),
          () {
        if (mounted) {
          speakWelcome();
        }
      },
    );
  }

  Future<void> speakWelcome() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String name = "User";

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data();
          name = data?['fullName'] ?? "User";
        }
      }

      if (mounted) {
        setState(() {
          _currentUserName = name;
          _isLoadingName = false;
        });
      }

      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.45);
      await flutterTts.setVolume(1.0);

      await flutterTts.speak(

        "Hello $name. "
        "I am Your Guardian Bot."

          "Hello $name. "
              "I am Guardian Bot. "
              "Your safety monitoring is active. "
              "If you are in danger, say help me, save me, emergency, or I am in danger. "
              "I will immediately alert your trusted contacts."

      );
    } catch (e) {
      debugPrint("Error loading name or initializing TTS: $e");
      if (mounted) {
        setState(() {
          _isLoadingName = false;
        });
      }
      await flutterTts.speak("Hello. I am Guardian Bot. I am protecting you.");
    }
  }

  // FEATURE CARD
  Widget featureCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2140),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // QUICK ACCESS CARD
  Widget quickAccessCard({
    required String image,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OPEN URL
  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1023),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1023),
        elevation: 4,
        shadowColor: Colors.black54,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Guardian",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "Bot",
                style: TextStyle(
                  color: Color(0xFFFF4D8D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              print("BUTTON PRESSED");
              await flutterTts.setLanguage("en-US");
              await flutterTts.setVolume(1.0);
              await flutterTts.setSpeechRate(0.5);
              await flutterTts.speak("Testing Guardian Bot voice");
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP WELCOME CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E2545),
                    Color(0xFF2B3568),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF4D8D),
                          Color(0xFFFF7EB3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingName ? "Syncing Systems..." : "Active: $_currentUserName",
                          style: const TextStyle(
                            color: Color(0xFFFF7EB3),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "AI is monitoring your safety 24x7",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    "assets/images/girl.png",
                    height: 90,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "How can we help you?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.78,
              children: [
                // VOICE DETECTION
                featureCard(
                  color: Colors.pink,
                  icon: Icons.mic,
                  title: "Voice Detection",
                  subtitle: "Detect distress voices automatically",
                  onTap: () async {
                    bool allowed = await checkSecuritySetup();
                    if (!allowed) return;

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceDetectionScreen(),
                      ),
                    );
                  },
                ),
                // SOUND DETECTION
                featureCard(
                  color: Colors.deepPurple,
                  icon: Icons.graphic_eq,
                  title: "Sound Detection",
                  subtitle: "Detect screams or loud sounds",
                  onTap: () async {
                    bool allowed = await checkSecuritySetup();
                    if (!allowed) return;

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SoundDetectionScreen(),
                      ),
                    );
                  },
                ),
                // RECORD AUDIO
                featureCard(
                  color: Colors.blue,
                  icon: Icons.mic_none,
                  title: "Record Audio",
                  subtitle: "Record evidence securely",
                  onTap: () async {
                    bool allowed = await checkSecuritySetup();
                    if (!allowed) return;

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecordAudioScreen(),
                      ),
                    );
                  },
                ),
                // SELF DEFENSE
                featureCard(
                  color: Colors.green,
                  icon: Icons.security,
                  title: "Self Defense",
                  subtitle: "Learn techniques & stay safe",
                  onTap: () async {
                    bool allowed = await checkSecuritySetup();
                    if (!allowed) return;

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelfDefenseScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF161B33),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  quickAccessCard(
                    image: "assets/images/uber.jpeg",
                    title: "Uber",
                    onTap: () {
                      openUrl("https://m.uber.com/");
                    },
                  ),
                  quickAccessCard(
                    image: "assets/images/ola.jpeg",
                    title: "Ola",
                    onTap: () {
                      openUrl("https://book.olacabs.com/");
                    },
                  ),
                  quickAccessCard(
                    image: "assets/images/rapido.jpeg",
                    title: "Rapido",
                    onTap: () {
                      openUrl("https://www.rapido.bike/");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Explore LiveSafe",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF161B33),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  quickAccessCard(
                    image: "assets/images/hospital.jpeg",
                    title: "Hospitals",
                    onTap: () {
                      openUrl("https://www.google.com/maps/search/nearest+hospitals/");
                    },
                  ),
                  quickAccessCard(
                    image: "assets/images/police.jpeg",
                    title: "Police",
                    onTap: () {
                      openUrl("https://www.google.com/maps/search/nearest+police+station/");
                    },
                  ),
                  quickAccessCard(
                    image: "assets/images/bus.png",
                    title: "Bus",
                    onTap: () {
                      openUrl("https://www.google.com/maps/search/nearest+bus+station/");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161B33),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/robot.jpeg",
                    height: 80,
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Guardian is Always Watching",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7EB3),
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "We'll alert trusted contacts instantly if danger is detected.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161B33),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: 0,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 1) {
            bool allowed = await checkSecuritySetup();
            if (!allowed) return;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LiveLocationScreen(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TrustedContactsScreen(),
              ),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled),
            label: "Timer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    detector?.stopListening();
    player.dispose();
    flutterTts.stop();
    super.dispose();
  }
}