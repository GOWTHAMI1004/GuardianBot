import 'package:flutter/material.dart';

class SelfDefenseScreen extends StatelessWidget {
  const SelfDefenseScreen({super.key});

  Widget techniqueCard({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
          ),
        ],
      ),

      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(18),

            child: Image.asset(
              image,
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,

                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xfff7f7f7),

      appBar: AppBar(
        backgroundColor: const Color(0xffE91E63),

        title: const Text(
          "Self Defense",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              "Self Defense Techniques",

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Learn practical techniques to protect yourself in unsafe situations.",

              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            techniqueCard(
              image:
              "assets/images/wrist_grab.png",

              title:
              "Escape from Wrist Grab",

              subtitle:
              "Learn how to free yourself from a wrist grab.",
            ),

            techniqueCard(
              image:
              "assets/images/front_choke.png",

              title:
              "Front Choke Escape",

              subtitle:
              "Step-by-step technique to escape front choke.",
            ),

            techniqueCard(
              image:
              "assets/images/back_hold.png",

              title:
              "Back Hold Escape",

              subtitle:
              "Effective moves to get out from behind back hold.",
            ),

            techniqueCard(
              image:
              "assets/images/punch_nose.png",

              title:
              "Punch to Nose",

              subtitle:
              "Use your fist effectively to defend yourself.",
            ),

            techniqueCard(
              image:
              "assets/images/knee_strike.png",

              title:
              "Knee Strike to Groin",

              subtitle:
              "A powerful move to create distance and stay safe.",
            ),

            techniqueCard(
              image:
              "assets/images/hair_pull.png",

              title:
              "Hair Pull Defense",

              subtitle:
              "Use hair pull defense to escape from danger.",
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.08),

                borderRadius:
                BorderRadius.circular(25),
              ),

              child: Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Safety Tips",

                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                            FontWeight.bold,

                            color: Colors.pink,
                          ),
                        ),

                        const SizedBox(height: 15),

                        tip("Trust your instincts"),
                        tip("Stay alert always"),
                        tip("Stay calm and confident"),
                        tip("Shout for help when needed"),
                        tip("Use nearby objects for safety"),
                      ],
                    ),
                  ),

                  Image.asset(
                    "assets/images/safety_girl.png",

                    height: 140,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: 0,

        selectedItemColor: Colors.pink,

        unselectedItemColor: Colors.grey,

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

  Widget tip(String text) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [

          const Icon(
            Icons.check_circle,
            color: Colors.pink,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
            ),
          ),
        ],
      ),
    );
  }
}