import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/alert_service.dart';

class AlertScreen extends StatefulWidget {

  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState()
      => _AlertScreenState();
}

class _AlertScreenState
    extends State<AlertScreen> {

  String locationLink =
      "Fetching live location...";

  @override
  void initState() {

    super.initState();

    fetchLocation();
  }

  // FETCH LIVE LOCATION
  Future<void> fetchLocation() async {

    String link =
    await LocationService.getLocationLink();

    setState(() {

      locationLink = link;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(25),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              // ALERT ICON
              Container(

                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(

                  color: Colors.red.shade50,

                  shape: BoxShape.circle,
                ),

                child: Icon(

                  Icons.warning_rounded,

                  size: 90,

                  color: Colors.red.shade400,
                ),
              ),

              const SizedBox(height: 40),

              // TITLE
              const Text(

                "Distress Detected!",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              // SUBTITLE
              const Text(

                "Emergency alert ready\nfor trusted contacts",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // LOCATION LINK
              Text(

                locationLink,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // LOADING ICON
              const CircularProgressIndicator(
                color: Color(0xFFE91E63),
              ),

              const SizedBox(height: 50),

              // WHATSAPP BUTTON
              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.green,

                    shape: RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(30),
                    ),
                  ),

                  onPressed: () async {

                    await AlertService().sendAlert();
                  },

                  child: const Text(

                    "Send WhatsApp Alert",

                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CANCEL BUTTON
              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.red,

                    shape: RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(30),
                    ),
                  ),

                  onPressed: () {

                    Navigator.pop(context);
                  },

                  child: const Text(

                    "Cancel Alert",

                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
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