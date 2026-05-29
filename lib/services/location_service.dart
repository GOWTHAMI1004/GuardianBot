import 'package:geolocator/geolocator.dart';

class LocationService {

  static Future<String> getLocationLink() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {

      return "Location services are disabled.";
    }

    permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission =
      await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {

        return "Location permission denied";
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {

      return "Location permissions permanently denied";
    }

    Position position =
    await Geolocator.getCurrentPosition(

      desiredAccuracy: LocationAccuracy.high,
    );

    String googleMapsLink =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

    return googleMapsLink;
  }
}