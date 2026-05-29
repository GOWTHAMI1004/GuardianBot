import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'contact_selection_screen.dart';

class LiveLocationScreen extends StatefulWidget {

  LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() =>
      _LiveLocationScreenState();
}

class _LiveLocationScreenState
    extends State<LiveLocationScreen> {

  GoogleMapController? mapController;

  LatLng currentLatLng =
      const LatLng(17.3850, 78.4867);

  String currentLocation =
      "Sharing live location with you";

  Future<void> getCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();
    }

    Position position =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {

      currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      currentLocation =
          "${position.latitude}, ${position.longitude}";
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(currentLatLng),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {

    return Expanded(
      child: GestureDetector(

        onTap: onTap,

        child: Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 5),

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(25),

            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
              ),
            ],
          ),

          child: Column(
            children: [

              CircleAvatar(
                radius: 28,

                backgroundColor:
                    color.withOpacity(0.15),

                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,

                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xffE91E63),

        title: const Text(
          "Live Location",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Column(
        children: [

          Container(
            margin: const EdgeInsets.all(15),

            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(25),

              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                ),
              ],
            ),

            child: Row(
              children: [

                const CircleAvatar(
                  radius: 30,

                  backgroundImage: AssetImage(
                    "assets/images/girl.png",
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "GuardianBot",

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        currentLocation,

                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xffE91E63),
                  ),

                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ContactSelectionScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    "Track",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 15),

              clipBehavior: Clip.hardEdge,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(25),
              ),

              child: GoogleMap(

                initialCameraPosition:
                    CameraPosition(
                  target: currentLatLng,
                  zoom: 14,
                ),

                myLocationEnabled: true,

                myLocationButtonEnabled: true,

                onMapCreated:
                    (GoogleMapController controller) {

                  mapController = controller;

                  getCurrentLocation();
                },

                markers: {

                  Marker(
                    markerId:
                        const MarkerId("current"),

                    position: currentLatLng,
                  ),
                },
              ),
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10),

            child: Row(
              children: [

                actionButton(
                  icon: Icons.location_on,

                  title: "Track Me",

                  subtitle:
                      "Track my live location",

                  color: Colors.pink,

                  onTap: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ContactSelectionScreen(),
                      ),
                    );
                  },
                ),

                actionButton(
                  icon:
                      Icons.notifications_active,

                  title: "Panic",

                  subtitle:
                      "Emergency alert",

                  color: Colors.red,

                  onTap: () {},
                ),

                actionButton(
                  icon: Icons.mic,

                  title: "Record",

                  subtitle:
                      "Record audio",

                  color: Colors.deepPurple,

                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}