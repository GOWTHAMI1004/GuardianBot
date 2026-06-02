import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Preserving intact navigation schemas - updated broken import reference
import 'emergency_contacts_setup_screen.dart';
import 'trusted_contacts_screen.dart';
import 'profile_screen.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  bool _isTimerActive = false;
  final int _maxDuration = 3600; // 1 Hour limit max

  // Hardcoded safety PIN for checking in (1234)
  static const String _correctPIN = "1234";

  void _toggleTimer() {
    if (_isTimerActive) {
      _showPinVerificationDialog();
    } else {
      if (_secondsRemaining == 0) {
        Fluttertoast.showToast(msg: "Please add time to your journey first.");
        return;
      }
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() {
      _isTimerActive = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _handleTimerExpiry();
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerActive = false;
      _secondsRemaining = 0;
    });
  }

  void _addMinutes(int minutes) {
    if (_isTimerActive) return; // Lock adjustments while tracking is running
    setState(() {
      _secondsRemaining = (_secondsRemaining + (minutes * 60)).clamp(0, _maxDuration);
    });
  }

  void _handleTimerExpiry() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerActive = false;
    });
    _triggerAutomatedEmergencyAlert();
  }

  // Captures and prints high-accuracy location details automatically if timeout occurs
  Future<void> _triggerAutomatedEmergencyAlert() async {
    Fluttertoast.showToast(
      msg: "🚨 Safety Check-In Failed! Deploying SOS Alerts...",
      toastLength: Toast.LENGTH_LONG,
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("TIMER EXPIRY SOS DEPLOYED - LAT: ${position.latitude}, LNG: ${position.longitude}");
    } catch (e) {
      print("AUTOMATED SOS ERROR: $e");
    }
  }

  // Secure Material PIN prompt dialog box
  void _showPinVerificationDialog() {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1E4B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Enter Safety PIN",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Verify your 4-digit PIN to safely cancel this journey tracking window.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, letterSpacing: 8),
                cursorColor: const Color(0xffE91E63),
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE91E63))),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE91E63),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (pinController.text == _correctPIN) {
                  Navigator.pop(context);
                  _stopCountdown();
                  Fluttertoast.showToast(msg: "Journey ended safely.");
                } else {
                  Fluttertoast.showToast(msg: "Incorrect PIN. Try again.");
                }
              },
              child: Text("Verify", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xffE91E63);
    const Color cardBackground = Color(0xFF1B1E4B);

    double progressPercentage = _secondsRemaining > 0 ? _secondsRemaining / _maxDuration : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF050B2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Safe Journey Tracker",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Upper branding card matching your dashboard row profile headers
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/girl.png"),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GuardianBot AI",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isTimerActive ? "Status: Monitoring Route..." : "Status: Waiting to launch",
                        style: GoogleFonts.inter(
                          color: _isTimerActive ? const Color(0xFF4DEEEA) : Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyContactsSetupScreen()),
                    );
                  },
                  child: const Text("Track", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Central Countdown Progress Hub Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBackground.withOpacity(0.4),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: cardBackground.withOpacity(0.6), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: CircularProgressIndicator(
                          value: progressPercentage,
                          strokeWidth: 8,
                          valueColor: const AlwaysStoppedAnimation<Color>(primaryPink),
                          backgroundColor: cardBackground.withOpacity(0.5),
                        ),
                      ),
                      Container(
                        width: 185,
                        height: 185,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cardBackground.withOpacity(0.3),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isTimerActive ? Icons.shield_rounded : Icons.shield_outlined,
                              color: _isTimerActive ? const Color(0xFF4DEEEA) : Colors.white.withOpacity(0.2),
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDuration(_secondsRemaining),
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _isTimerActive ? "TRACKING ROUTE" : "STANDBY",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isTimerActive ? const Color(0xFF4DEEEA) : Colors.white.withOpacity(0.3),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Incremental Time Padding Selector Row Pad
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isTimerActive ? 0.3 : 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimePad("+5m", () => _addMinutes(5), cardBackground),
                        _buildTimePad("+10m", () => _addMinutes(10), cardBackground),
                        _buildTimePad("+15m", () => _addMinutes(15), cardBackground),
                        _buildTimePad("+30m", () => _addMinutes(30), cardBackground),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Core System Action Execution Toggle Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTimerActive ? const Color(0xFF0F1235) : primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: _isTimerActive ? const BorderSide(color: Color(0xFF4DEEEA), width: 1.5) : BorderSide.none,
                  ),
                ),
                onPressed: _toggleTimer,
                icon: Icon(
                  _isTimerActive ? Icons.lock_open_rounded : Icons.timer_outlined,
                  color: _isTimerActive ? const Color(0xFF4DEEEA) : Colors.white,
                ),
                label: Text(
                  _isTimerActive ? "Safe Check-In (Stop Tracker)" : "Activate Safety Timer",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _isTimerActive ? const Color(0xFF4DEEEA) : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),

      // Bottom Navigation Core with intact routing index structures
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161B33),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: primaryPink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrustedContactsScreen()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Location"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Contacts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildTimePad(String label, VoidCallback onTap, Color bgColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}