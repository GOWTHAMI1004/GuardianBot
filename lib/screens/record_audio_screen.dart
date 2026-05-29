import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({super.key});

  @override
  State<RecordAudioScreen> createState() =>
      _RecordAudioScreenState();
}

class _RecordAudioScreenState
    extends State<RecordAudioScreen> {

  final AudioRecorder audioRecorder =
      AudioRecorder();

  bool isRecording = false;

  String status =
      "Press button to record";

  String audioPath = "";

  // START RECORDING

  Future<void> startRecording() async {

    if (await audioRecorder.hasPermission()) {

      final dir =
          await getApplicationDocumentsDirectory();

      audioPath =
          "${dir.path}/emergency_audio.m4a";

      await audioRecorder.start(

        const RecordConfig(),

        path: audioPath,
      );

      setState(() {

        isRecording = true;

        status = "Recording Started...";
      });
    }
  }

  // STOP RECORDING

  Future<void> stopRecording() async {

    final path =
        await audioRecorder.stop();

    setState(() {

      isRecording = false;

      audioPath = path ?? "";

      status =
      "Audio Saved Successfully";
    });

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(
          "Recording Saved:\n$audioPath",
        ),
      ),
    );

    print("Saved Audio Path: $audioPath");
  }

  @override
  void dispose() {

    audioRecorder.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        backgroundColor:
        const Color(0xffE91E63),

        title: const Text(

          "Record Audio",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              // RECORD BUTTON

              AnimatedContainer(

                duration:
                const Duration(milliseconds: 300),

                width:
                isRecording ? 180 : 160,

                height:
                isRecording ? 180 : 160,

                decoration: BoxDecoration(

                  shape: BoxShape.circle,

                  color: isRecording
                      ? Colors.red.shade100
                      : Colors.pink.shade100,
                ),

                child: IconButton(

                  iconSize: 80,

                  icon: Icon(

                    isRecording
                        ? Icons.stop
                        : Icons.mic,

                    color: Colors.pink,
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

              const SizedBox(height: 40),

              // STATUS TEXT

              Text(

                status,

                textAlign: TextAlign.center,

                style: const TextStyle(

                  fontSize: 24,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // SAVED FILE PATH

              Text(

                audioPath.isEmpty
                    ? "No recording saved yet"
                    : "Saved File:\n$audioPath",

                textAlign: TextAlign.center,

                style: const TextStyle(

                  fontSize: 14,

                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}