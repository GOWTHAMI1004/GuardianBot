import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'contact_selection_screen.dart';
import 'trusted_contacts_screen.dart';
import 'profile_screen.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E4B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF050B2C),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B2C),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Live Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          Container(
            margin: const EdgeInsets.all(15),

            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: const Color(0xFF1B1E4B),

              borderRadius:
                  BorderRadius.circular(25),


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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        currentLocation,

                        style: const TextStyle(
                          color: Colors.white70,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: actionButton(
              icon: Icons.location_on,
              title: "Track Me",
              subtitle: "Track my live location",
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
          ),
          const SizedBox(height: 20),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161B33),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Location selected
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,

        onTap: (index) {

          if (index == 0) {
            Navigator.pop(context);
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TrustedContactsScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Location",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Contacts",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}