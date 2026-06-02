import 'package:flutter/material.dart';
import 'recordings_screen.dart';

class RecordingsMenuScreen extends StatelessWidget {
  const RecordingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B2C),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B2C),
        title: const Text(
          "Recordings",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecordingsScreen(
                      recordingType: "manual",
                    ),
                  ),
                );
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E4B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Manual Recordings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecordingsScreen(
                      recordingType: "emergency",
                    ),
                  ),
                );
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E4B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Emergency Recordings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}