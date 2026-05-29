import 'dart:async';

import 'package:flutter/material.dart';

class EmergencyScreen extends StatefulWidget {

  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() =>
      _EmergencyScreenState();
}

class _EmergencyScreenState
    extends State<EmergencyScreen> {

  int countdown = 10;

  Timer? timer;

  bool emergencyActivated = false;

  @override
  void initState() {
    super.initState();

    startCountdown();
  }

  void startCountdown() {

    timer = Timer.periodic(

      const Duration(seconds: 1),

          (timer) {

        if (countdown > 0) {

          setState(() {

            countdown--;
          });

        } else {

          timer.cancel();

          activateEmergency();
        }
      },
    );
  }

  void activateEmergency() {

    setState(() {

      emergencyActivated = true;
    });
  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      emergencyActivated
          ? Colors.red.shade900
          : Colors.black,

      body: SafeArea(

        child: Center(

          child: Padding(

            padding: const EdgeInsets.all(25),

            child: Column(

              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                Icon(

                  Icons.warning_amber_rounded,

                  color: Colors.red,

                  size: 120,
                ),

                const SizedBox(height: 30),

                Text(

                  emergencyActivated

                      ? "EMERGENCY ALERT ACTIVATED"

                      : "DISTRESS DETECTED",

                  textAlign: TextAlign.center,

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 32,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(

                  emergencyActivated

                      ? "GuardianBot AI has activated "
                      "emergency protection mode."

                      : "Sending emergency alerts in "
                      "$countdown seconds",

                  textAlign: TextAlign.center,

                  style: const TextStyle(

                    color: Colors.white70,

                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 50),

                if (!emergencyActivated)

                  SizedBox(

                    width: double.infinity,

                    height: 60,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(

                        backgroundColor: Colors.white,

                        shape: RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),

                      onPressed: () {

                        timer?.cancel();

                        Navigator.pop(context);
                      },

                      child: const Text(

                        "Cancel Alert",

                        style: TextStyle(

                          color: Colors.red,

                          fontSize: 20,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (emergencyActivated)

                  Container(

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(

                      color: Colors.white24,

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: const Column(

                      children: [

                        Row(

                          children: [

                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(

                              "Live location tracking started",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(

                          children: [

                            Icon(
                              Icons.people,
                              color: Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(

                              "Trusted contacts notified",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(

                          children: [

                            Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(

                              "Voice monitoring active",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}