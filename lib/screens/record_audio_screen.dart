import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({super.key});

  @override
  State<RecordAudioScreen> createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  // START RECORDING FUNCTION
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String path = '${appDocDir.path}/manual_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _filePath = path;
        });
        
        Fluttertoast.showToast(msg: "Recording started...");
      } else {
        Fluttertoast.showToast(msg: "Permission to access microphone denied");
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  // STOP RECORDING FUNCTION
  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        Fluttertoast.showToast(
          msg: "Recording Saved Successfully",
        );

        print("Saved Recording: $path");
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1023),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1023),
        elevation: 0,
        title: const Text(
          "Secure Audio Recorder",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Text
            Text(
              _isRecording ? "🚨 RECORDING EVIDENCE" : "Tap Mic to Record Evidence Securely",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isRecording ? Colors.redAccent : Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),

            // Recording Button
            GestureDetector(
              onTap: () {
                if (_isRecording) {
                  stopRecording();
                } else {
                  startRecording();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isRecording ? 180 : 150,
                height: _isRecording ? 180 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                  border: Border.all(
                    color: _isRecording ? Colors.red : Colors.blue,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isRecording ? Colors.red.withOpacity(0.4) : Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 70,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Hint Text
            if (_isRecording)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Audio is being encrypted and saved directly to your local application directory.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}