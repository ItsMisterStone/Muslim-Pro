import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the current position, or throws an Exception with a
  /// readable message if location can't be obtained.
  Future<Position> getCurrentPosition() async {
    // 1. Is the phone's location switch turned on?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are turned off. Please enable GPS.');
    }

    // 2. Do we have permission?
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it in app settings.',
      );
    }

    // 3. Get the coordinates
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}