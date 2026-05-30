import 'package:flutter/material.dart';

class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B2C),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B2C),
        title: const Text(
          "My Recordings",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [

          RecordingTile(
            title: "Emergency Recording",
            time: "30 May 2026 • 5:45 PM",
          ),

          RecordingTile(
            title: "Safety Recording",
            time: "29 May 2026 • 8:10 PM",
          ),
        ],
      ),
    );
  }
}

class RecordingTile extends StatelessWidget {
  final String title;
  final String time;

  const RecordingTile({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E4B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mic,
            color: Colors.pink,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}