import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({super.key});

  @override
  State<RecordAudioScreen> createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String status = "Press button to record";
  String audioPath = "";

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  // START RECORDING FUNCTION
  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String path = '${appDocDir.path}/manual_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          isRecording = true;
          audioPath = path;
          status = "Recording Started...";
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
      final path = await audioRecorder.stop();
      setState(() {
        isRecording = false;
        audioPath = path ?? "";
        status = "Audio Saved Successfully";
      });

      if (path != null) {
        Fluttertoast.showToast(
          msg: "Recording Saved Successfully",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E254C),
              content: Text(
                "Recording Saved:\n$audioPath",
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          );
        }

        print("Saved Recording: $path");
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
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
              // Clean Integrated Navigation Top Bar
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
                      "Record Audio Evidence",
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Animated Pulse Recording Trigger Ring
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isRecording ? 190 : 160,
                        height: isRecording ? 190 : 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording
                              ? accentPink.withOpacity(0.15)
                              : surfaceContainer.withOpacity(0.4),
                          border: Border.all(
                            color: isRecording ? accentPink : surfaceContainer,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isRecording)
                              BoxShadow(
                                color: accentPink.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                          ],
                        ),
                        child: Center(
                          child: IconButton(
                            iconSize: 75,
                            icon: Icon(
                              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: isRecording ? accentPink : Colors.white.withOpacity(0.4),
                            ),
                            onPressed: () {
                              if (isRecording) {
                                stopRecording();
                              } else {
                                startRecording();
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Execution Progress State Text
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isRecording ? accentPink : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Saved Directory Location Card Panel
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: surfaceContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: surfaceContainer.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          audioPath.isEmpty
                              ? "No recording saved yet"
                              : "Saved Location:\n$audioPath",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: audioPath.isEmpty
                                ? Colors.white.withOpacity(0.4)
                                : const Color(0xFF4DEEEA), // High tech neon cyan when file exists
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      
                      if (isRecording)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Audio is being encrypted and saved directly to your local application directory.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}