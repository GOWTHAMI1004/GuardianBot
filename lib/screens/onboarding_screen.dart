import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboard1.jpeg",
      "title": "Stay Protected,\nStay Secure",
      "subtitle": "AI powered protection for\nevery woman, every moment.",
    },
    {
      "image": "assets/images/onboard2.jpeg",
      "title": "Detect Distress",
      "subtitle": "Our AI detects distress voice\nand loud sounds.",
    },
    {
      "image": "assets/images/onboard3.jpeg",
      "title": "Instant Alerts",
      "subtitle": "Send emergency alerts with your\nlive location to trusted contacts.",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Modern Typography Header Title
                          Text(
                            onboardingData[index]['title']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtle Subtitle Description text
                          Text(
                            onboardingData[index]['subtitle']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.55),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Elegant image frame to blend JPEG background shapes seamlessly
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: surfaceContainer.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: surfaceContainer.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  onboardingData[index]['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Footer Navigation Bar Controller Layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Modern Skip Option Button Link - FIXED alignment issue here
                              GestureDetector(
                                onTap: _completeOnboarding,
                                child: Container(
                                  height: 48,
                                  width: 60,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Skip",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),

                              // Smooth dynamic indicator navigation tracking dots
                              Row(
                                children: List.generate(
                                  onboardingData.length,
                                      (dotIndex) => buildDot(dotIndex, accentPink),
                                ),
                              ),

                              // Elevated Accent Navigation Trigger Option
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentPink.withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentPink,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (currentIndex == onboardingData.length - 1) {
                                      await _completeOnboarding();
                                    } else {
                                      _controller.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Text(
                                    currentIndex == onboardingData.length - 1 ? "Get Started" : "Next",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDot(int index, Color activeColor) {
    final bool isActive = currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : const Color(0xFF1E254C),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: activeColor.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }
}