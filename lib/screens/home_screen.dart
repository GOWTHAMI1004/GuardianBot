import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'self_defense_screen.dart';
import 'live_location_screen.dart';
import 'voice_detection_screen.dart';
import 'sound_detection_screen.dart';
import 'record_audio_screen.dart';
import 'trusted_contacts_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

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

          color: Colors.white,

          borderRadius: BorderRadius.circular(25),

          boxShadow: [

            BoxShadow(

              color: Colors.grey.shade200,

              blurRadius: 10,
            ),
          ],
        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            CircleAvatar(

              radius: 28,

              backgroundColor:
              color.withOpacity(0.15),

              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(height: 10),

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
                  color: Colors.black54,
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
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

      backgroundColor: const Color(0xfff7f7f7),

      appBar: AppBar(

        backgroundColor: const Color(0xffE91E63),

        elevation: 0,

        title: const Text(

          "GuardianBot",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // TOP CARD

            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(25),
              ),

              child: Row(

                children: [

                  CircleAvatar(

                    radius: 30,

                    backgroundColor:
                    Colors.pink.withOpacity(0.1),

                    child: const Icon(
                      Icons.shield,
                      color: Colors.pink,
                      size: 35,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(

                          "Guardian is Active",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "AI is monitoring your safety 24x7",
                          style: TextStyle(
                            color: Colors.black54,
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

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

                  subtitle:
                  "Detect distress voices automatically",

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const VoiceDetectionScreen(),
                      ),
                    );
                  },
                ),

                // SOUND DETECTION

                featureCard(

                  color: Colors.deepPurple,

                  icon: Icons.graphic_eq,

                  title: "Sound Detection",

                  subtitle:
                  "Detect screams or loud sounds",

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const SoundDetectionScreen(),
                      ),
                    );
                  },
                ),

                // RECORD AUDIO

                featureCard(

                  color: Colors.blue,

                  icon: Icons.mic_none,

                  title: "Record Audio",

                  subtitle:
                  "Record evidence securely",

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const RecordAudioScreen(),
                      ),
                    );
                  },
                ),

                // SELF DEFENSE

                featureCard(

                  color: Colors.green,

                  icon: Icons.security,

                  title: "Self Defense",

                  subtitle:
                  "Learn techniques & stay safe",

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const SelfDefenseScreen(),
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
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(

                color:
                Colors.pink.withOpacity(0.05),

                borderRadius:
                BorderRadius.circular(25),
              ),

              child: Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceAround,

                children: [

                  quickAccessCard(

                    image:
                    "assets/images/uber.jpeg",

                    title: "Uber",

                    onTap: () {
                      openUrl("https://m.uber.com/");
                    },
                  ),

                  quickAccessCard(

                    image:
                    "assets/images/ola.jpeg",

                    title: "Ola",

                    onTap: () {
                      openUrl("https://book.olacabs.com/");
                    },
                  ),

                  quickAccessCard(

                    image:
                    "assets/images/rapido.jpeg",

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
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(

                color:
                Colors.pink.withOpacity(0.05),

                borderRadius:
                BorderRadius.circular(25),
              ),

              child: Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceAround,

                children: [

                  quickAccessCard(

                    image:
                    "assets/images/hospital.jpeg",

                    title: "Hospitals",

                    onTap: () {

                      openUrl(
                        "https://www.google.com/maps/search/nearest+hospitals/",
                      );
                    },
                  ),

                  quickAccessCard(

                    image:
                    "assets/images/police.jpeg",

                    title: "Police",

                    onTap: () {

                      openUrl(
                        "https://www.google.com/maps/search/nearest+police+station/",
                      );
                    },
                  ),

                  quickAccessCard(

                    image:
                    "assets/images/bus.png",

                    title: "Bus",

                    onTap: () {

                      openUrl(
                        "https://www.google.com/maps/search/nearest+bus+station/",
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color:
                Colors.pink.withOpacity(0.08),

                borderRadius:
                BorderRadius.circular(25),
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

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(

                          "AI Guardian is Always Watching",

                          style: TextStyle(

                            fontWeight:
                            FontWeight.bold,

                            color: Colors.pink,

                            fontSize: 18,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "We'll alert trusted contacts if danger is detected.",
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

      bottomNavigationBar:
      BottomNavigationBar(

        currentIndex: 0,

        selectedItemColor:
        Colors.pink,

        unselectedItemColor:
        Colors.grey,

        onTap: (index) {

          // LIVE LOCATION

          if (index == 1) {

            Navigator.push(

              context,

              MaterialPageRoute(
                builder: (_) =>
                LiveLocationScreen(),
              ),
            );
          }

          // CONTACTS

          if (index == 2) {

            Navigator.push(

              context,

              MaterialPageRoute(
                builder: (_) =>
                const TrustedContactsScreen(),
              ),
            );
          }

          // PROFILE

          if (index == 3) {

            Navigator.push(

              context,

              MaterialPageRoute(
                builder: (_) =>
                const ProfileScreen(),
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
            icon: Icon(Icons.location_on),
            label: "Live Location",
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
}

