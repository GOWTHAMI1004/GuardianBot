import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

class RecordingsScreen extends StatefulWidget {
  final String recordingType;

  const RecordingsScreen({
    super.key,
    required this.recordingType,
  });

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  List<FileSystemEntity> recordings = [];
  final AudioPlayer player = AudioPlayer();
  String currentlyPlaying = "";

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    loadRecordings();
  }

  Future<void> loadRecordings() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();

    recordings = files.where((file) {
      final fileName = file.path.split("/").last;
      return fileName.startsWith(widget.recordingType) &&
          fileName.endsWith(".m4a");
    }).toList();

    recordings.sort(
      (a, b) => b.path.compareTo(a.path),
    );

    setState(() {});
  }

  Future<void> playRecording(String path) async {
    try {
      if (currentlyPlaying == path) {
        await player.stop();
        setState(() {
          currentlyPlaying = "";
          currentPosition = Duration.zero;
          totalDuration = Duration.zero;
        });
        return;
      }

      await player.stop();
      
      // STEP 1 MODIFICATION: Set path with processing delay buffer setup
      await player.setFilePath(path);

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      setState(() {
        totalDuration = player.duration ?? Duration.zero;
      });

      print("TOTAL DURATION = $totalDuration");

      player.durationStream.listen((duration) {
        if (duration != null && mounted) {
          setState(() {
            totalDuration = duration;
          });
        }
      });

      player.positionStream.listen((position) {
        print("POSITION = $position");

        if (mounted) {
          setState(() {
            currentPosition = position;
          });
        }
      });

      await player.play();

      setState(() {
        currentlyPlaying = path;
      });

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              currentlyPlaying = "";
              currentPosition = Duration.zero;
            });
          }
        }
      });
    } catch (e) {
      print("Error playing recording: $e");
    }
  }

  Future<void> deleteRecording(String path) async {
    try {
      if (currentlyPlaying == path) {
        await player.stop();
        setState(() {
          currentlyPlaying = "";
          currentPosition = Duration.zero;
          totalDuration = Duration.zero;
        });
      }

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      loadRecordings();
    } catch (e) {
      print("Error deleting recording: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B2C),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.recordingType == "manual"
              ? "Manual Recordings"
              : "Emergency Recordings",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: recordings.isEmpty
          ? const Center(
              child: Text(
                "No Recordings Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final file = recordings[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E4B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.recordingType == "manual"
                                ? Icons.mic
                                : Icons.warning_amber_rounded,
                            color: widget.recordingType == "manual"
                                ? Colors.pink
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.recordingType == "manual"
                                      ? "Manual Recording"
                                      : "Emergency Recording",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat("dd MMM yyyy • hh:mm a").format(
                                    File(file.path).lastModifiedSync(),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              bool? confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFF1B1E4B),
                                    title: const Text(
                                      "Delete Recording",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      "Are you sure?",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                deleteRecording(file.path);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Slider(
                        activeColor: widget.recordingType == "manual"
                            ? Colors.pink
                            : Colors.red,
                        inactiveColor: Colors.white12,
                        value: currentlyPlaying == file.path
                            ? currentPosition.inMilliseconds.toDouble()
                            : 0,
                        max: currentlyPlaying == file.path &&
                                totalDuration.inMilliseconds > 0
                            ? totalDuration.inMilliseconds.toDouble()
                            : 1,
                        onChanged: (value) async {
                          if (currentlyPlaying == file.path) {
                            await player.seek(
                              Duration(milliseconds: value.toInt()),
                            );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentlyPlaying == file.path
                                ? "${currentPosition.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentPosition.inSeconds.remainder(60).toString().padLeft(2, '0')}"
                                : "00:00",
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              currentlyPlaying == file.path
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              playRecording(file.path);
                            },
                          ),
                          // STEP 2 MODIFICATION: Streamlined asset duration text panel layout block
                          Text(
                            "${totalDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:"
                            "${totalDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}