// ignore_for_file: avoid_print
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        print('⚠️ Location services are disabled on device');
      }
      return enabled;
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      print('📍 Checking location permission...');
      
      // First check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled. Opening settings...');
        await Geolocator.openLocationSettings();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        print('📍 Permission denied. Requesting...');
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('❌ Permission permanently denied. Opening app settings...');
        await Geolocator.openAppSettings();
        return false;
      }
      
      final hasPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      
      print(hasPermission ? '✅ Location permission granted' : '❌ Permission not granted');
      return hasPermission;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Get current location with timeout and fallback
  Future<LatLng?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      print('📍 Getting current location...');
      
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied');
        return null;
      }

      // Get position with timeout
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ).timeout(
          timeout,
          onTimeout: () {
            print('⚠️ Location request timed out, retrying with lower accuracy...');
            throw TimeoutException('Location request timed out');
          },
        );

        print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
        return LatLng(position.latitude, position.longitude);
      } on TimeoutException {
        // Retry with medium accuracy
        print('🔄 Retrying with medium accuracy...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
        
        print('✅ Location obtained (medium accuracy): ${position.latitude}, ${position.longitude}');
        return LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      print('Error type: ${e.runtimeType}');
      
      // Last resort: return default location (San Francisco)
      print('⚠️ Using default location as fallback');
      return LatLng(37.7749, -122.4194);
    }
  }

  // Get location updates stream with error handling
  Stream<LatLng> getLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    print('📍 Starting location stream with accuracy: $accuracy, distance filter: ${distanceFilter}m');
    
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: const Duration(seconds: 5),
      ),
    ).map((Position position) {
      print('📍 Location update: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)');
      return LatLng(position.latitude, position.longitude);
    }).handleError((error, stackTrace) {
      print('❌ Location stream error: $error');
      print('Stack trace: $stackTrace');
      // Error handled but stream continues
      return null;
    });
  }

  // Get last known location (faster, less accurate)
  Future<LatLng?> getLastKnownLocation() async {
    try {
      print('📍 Getting last known location...');
      
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        print('✅ Last known location: ${position.latitude}, ${position.longitude}');
        return LatLng(position.latitude, position.longitude);
      }
      
      print('⚠️ No last known location available');
      return null;
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  // Calculate distance between two points (in meters)
  static double calculateDistance(LatLng start, LatLng end) {
    try {
      final distance = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      print('📏 Distance: ${(distance / 1000).toStringAsFixed(2)} km');
      return distance;
    } catch (e) {
      print('Error calculating distance: $e');
      return 0;
    }
  }

  // Get bearing between two points
  static double calculateBearing(LatLng start, LatLng end) {
    try {
      final bearing = Geolocator.bearingBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      return bearing;
    } catch (e) {
      print('Error calculating bearing: $e');
      return 0;
    }
  }
}
