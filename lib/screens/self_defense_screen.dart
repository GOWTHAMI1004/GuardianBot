import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Import your actual screen destinations here
// import 'home_screen.dart';
// import 'live_location_screen.dart';
// import 'contacts_screen.dart';
// import 'profile_screen.dart';

class SelfDefenseScreen extends StatefulWidget {
  const SelfDefenseScreen({super.key});

  @override
  State<SelfDefenseScreen> createState() => _SelfDefenseScreenState();
}

class _SelfDefenseScreenState extends State<SelfDefenseScreen> {
  // Keeps track of the currently selected bottom navigation index
  int _currentIndex = 0;

  // Dynamic launcher function executing safe URL parsing strings
  Future<void> _playVideoInstruction(BuildContext context, String urlString) async {
    if (urlString.isEmpty) {
      Fluttertoast.showToast(msg: "Video tutorial coming soon!");
      return;
    }

    final Uri videoUri = Uri.parse(urlString);

    try {
      // Launches video in external app (YouTube/Browser) for optimal performance
      await launchUrl(
        videoUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print("URL LAUNCH ERROR: $e");
      Fluttertoast.showToast(msg: "Could not open video link");
    }
  }

  // Handle bottom navigation item selection switching logic
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Implement navigation or tab index updates here:
    switch (index) {
      case 0:
        // Already on home/self-defense component workspace context
        break;
      case 1:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LiveLocationScreen()));
        Fluttertoast.showToast(msg: "Navigating to Live Location...");
        break;
      case 2:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ContactsScreen()));
        Fluttertoast.showToast(msg: "Navigating to Contacts...");
        break;
      case 3:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        Fluttertoast.showToast(msg: "Navigating to Profile...");
        break;
    }
  }

  // Modern interactive card responsive to click states
  Widget techniqueCard({
    required BuildContext context,
    required String image,
    required String title,
    required String subtitle,
    required String videoUrl,
    required Color surfaceColor,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: surfaceColor.withOpacity(0.35),
          child: InkWell(
            splashColor: accentColor.withOpacity(0.2),
            highlightColor: accentColor.withOpacity(0.1),
            onTap: () => _playVideoInstruction(context, videoUrl),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: surfaceColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      color: surfaceColor.withOpacity(0.6),
                      child: Image.asset(
                        image,
                        height: 95,
                        width: 95,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.fitness_center_rounded, color: accentColor, size: 40);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  Icon(
                    Icons.play_circle_outline_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(String text, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
                      "Self Defense",
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Self Defense Techniques",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Learn practical techniques to protect yourself in unsafe situations. Tap cards to watch tutorials.",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      techniqueCard(
                        context: context,
                        image: "assets/images/wrist_grab.png",
                        title: "Escape from Wrist Grab",
                        subtitle: "Learn how to free yourself from a wrist grab.",
                        videoUrl: "https://www.youtube.com/watch?v=6bExlWzkIHU",
                        surfaceColor: surfaceContainer,
                        accentColor: accentPink,
                      ),
                      techniqueCard(
                        context: context,
                        image: "assets/images/front_choke.png",
                        title: "Front Choke Escape",
                        subtitle: "Step-by-step technique to escape front choke.",
                        videoUrl: "https://www.youtube.com/watch?v=v2Rzhr1OtN4",
                        surfaceColor: surfaceContainer,
                        accentColor: accentPink,
                      ),
                      techniqueCard(
                        context: context,
                        image: "assets/images/back_hold.png",
                        title: "Back Hold Escape",
                        subtitle: "Effective moves to get out from behind back hold.",
                        videoUrl: "https://www.youtube.com/watch?v=7XI1uAdr_s4",
                        surfaceColor: surfaceContainer,
                        accentColor: accentPink,
                      ),
                      techniqueCard(
                        context: context,
                        image: "assets/images/punch_nose.png",
                        title: "Punch to Nose",
                        subtitle: "Use your fist effectively to defend yourself.",
                        videoUrl: "https://www.youtube.com/watch?v=9Rfg57ZPffg",
                        surfaceColor: surfaceContainer,
                        accentColor: accentPink,
                      ),
                      techniqueCard(
                        context: context,
                        image: "assets/images/knee_strike.png",
                        title: "Knee Strike to Groin",
                        subtitle: "A powerful move to create distance and stay safe.",
                        videoUrl: "https://www.youtube.com/watch?v=IPORkNzhwbY",
                        surfaceColor: surfaceContainer,
                        accentColor: accentPink,
                      ),
                      techniqueCard(
                        context: context,
                        image: "assets/images/hair_pull.png",
                        title: "Hair Pull Defense",
                        subtitle: "Use hair pull defense to escape from danger.",
                        videoUrl: "https://www.youtube.com/watch?v=gHmj-MhvFdc",
                        surfaceColor: surfaceContainer,
                        accentColor: accentPink,
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceContainer.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: accentPink.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Safety Tips",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: accentPink,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTipRow("Trust your instincts", accentPink),
                                  _buildTipRow("Stay alert always", accentPink),
                                  _buildTipRow("Stay calm and confident", accentPink),
                                  _buildTipRow("Shout for help when needed", accentPink),
                                  _buildTipRow("Use nearby objects for safety", accentPink),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.asset(
                                "assets/images/safety_girl.png",
                                height: 110,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.shield_outlined, color: accentPink.withOpacity(0.4), size: 60),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E254C), width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF090D22),
          selectedItemColor: accentPink,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_rounded),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.location_on_rounded),
              ),
              label: "Live Location",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people_alt_rounded),
              ),
              label: "Contacts",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_rounded),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}