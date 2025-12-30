import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  // Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Open app settings if permission is permanently denied
      await Geolocator.openLocationSettings();
      return false;
    }
    
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Get current location
  Future<LatLng?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get location updates stream
  Stream<LatLng> getLocationUpdates() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update when moved 10 meters
      ),
    ).map((Position position) => LatLng(position.latitude, position.longitude));
  }
}
