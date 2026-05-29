import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final PageController _controller =
      PageController();

  int currentIndex = 0;

  List onboardingData = [

    {
      "image": "assets/images/onboard1.jpeg",

      "title": "Stay Protected,\nStay Secure",

      "subtitle":
      "AI powered protection for\n every woman, every moment.",
    },

    {
      "image": "assets/images/onboard2.jpeg",

      "title": "Detect Distress",

      "subtitle":
      "Our AI detects distress voice\n and loud sounds.",
    },

    {
      "image": "assets/images/onboard3.jpeg",

      "title": "Instant Alerts",

      "subtitle":
      "Send emergency alerts with your\n live location to trusted contacts.",
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

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

                    padding: const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        const SizedBox(height: 30),

                        Text(

                          onboardingData[index]['title'],

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(

                          onboardingData[index]['subtitle'],

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Expanded(

                          child: Image.asset(

                            onboardingData[index]['image'],

                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(

                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                          children: [

                            GestureDetector(

                              onTap: () async {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setBool(
      'hasSeenOnboarding', true);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ),
  );
},

                              child: const Text(

                                "Skip",

                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Row(

                              children: List.generate(

                                onboardingData.length,

                                    (index) =>
                                    buildDot(index),
                              ),
                            ),

                            ElevatedButton(

                              style:
                              ElevatedButton.styleFrom(

                                backgroundColor:
                                const Color(0xFFE91E63),

                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 12,
                                ),

                                shape:
                                RoundedRectangleBorder(

                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),
                              ),

                             onPressed: () async {

                               if (currentIndex ==
    onboardingData.length - 1) {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setBool(
      'hasSeenOnboarding', true);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context)
      => LoginScreen(),
    ),
  );
}
                                else {

                                  _controller.nextPage(

                                    duration:
                                    const Duration(
                                        milliseconds: 300),

                                    curve: Curves.easeIn,
                                  );
                                }
                              },

                              child: const Text(

                                "Next",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {

    return Container(

      margin: const EdgeInsets.only(right: 5),

      height: 10,

      width: currentIndex == index ? 25 : 10,

      decoration: BoxDecoration(

        color: currentIndex == index
            ? const Color(0xFFE91E63)
            : Colors.grey.shade300,

        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}