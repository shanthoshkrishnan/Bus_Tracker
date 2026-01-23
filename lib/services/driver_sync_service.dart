// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Driver Sync Service - Client-side sync (No Cloud Functions needed!)
/// Syncs driver records automatically when app opens or user profile updates
class DriverSyncService {
  static final DriverSyncService _instance = DriverSyncService._internal();

  factory DriverSyncService() {
    return _instance;
  }

  DriverSyncService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Call this when app starts (in main.dart or after login)
  /// Syncs current user if they are a driver
  Future<void> syncCurrentUserDriver() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      // Get user data from Firestore
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final role = (userData['role'] ?? '').toString().toLowerCase();

      if (role == 'driver') {
        await _syncDriverRecord(user.uid, userData);
        print('✓ Driver synced on app start: ${userData['email']}');
      }
    } catch (e) {
      print('Error syncing driver on startup: $e');
    }
  }

  /// Call this after user profile is updated
  /// Auto-detects if they're a driver and syncs
  Future<void> syncOnProfileUpdate(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final role = (userData['role'] ?? '').toString().toLowerCase();
      final previousRole = userData['previousRole'] ?? '';

      // Case 1: User just became a driver
      if (role == 'driver' && previousRole != 'driver') {
        await _syncDriverRecord(userId, userData);
        print('✓ Driver record created: ${userData['email']}');
      }

      // Case 2: User is still a driver - sync any updates
      if (role == 'driver') {
        await _syncDriverRecord(userId, userData);
        print('✓ Driver details synced: ${userData['email']}');
      }

      // Case 3: User is no longer a driver - mark as inactive
      if (role != 'driver' && previousRole == 'driver') {
        await _markDriverInactive(userId);
        print('✓ Driver marked inactive: ${userData['email']}');
      }
    } catch (e) {
      print('Error syncing on profile update: $e');
    }
  }

  /// Internal: Create or update driver record
  Future<void> _syncDriverRecord(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final driverRef = _db.collection('drivers');

      // Check if driver record already exists
      final existingDriver = await driverRef
          .where('driverId', isEqualTo: userId)
          .limit(1)
          .get();

      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();

      final driverData = {
        'driverId': userId,
        'driverName': fullName,
        'driverEmail': userData['email'] ?? '',
        'driverPhone': userData['phone'] ?? '',
        'assignedBusNumber': userData['assignedBusNumber'] ?? '',
        'assignedRoute': userData['assignedRoute'] ?? '',
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existingDriver.docs.isEmpty) {
        // Create new driver record
        driverData['createdAt'] = FieldValue.serverTimestamp();
        await driverRef.add(driverData);
      } else {
        // Update existing driver record
        await existingDriver.docs.first.reference.update(driverData);
      }
    } catch (e) {
      print('Error syncing driver record: $e');
      rethrow;
    }
  }

  /// Internal: Mark driver as inactive
  Future<void> _markDriverInactive(String userId) async {
    try {
      final driverRef = _db.collection('drivers');
      final driverDocs = await driverRef
          .where('driverId', isEqualTo: userId)
          .get();

      for (var doc in driverDocs.docs) {
        await doc.reference.update({
          'status': 'inactive',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error marking driver inactive: $e');
    }
  }

  /// Manual sync: Call updateDriverAssignment to assign bus/route
  /// Call this from admin page when assigning buses to drivers
  Future<bool> updateDriverAssignment({
    required String driverId,
    String? assignedBusNumber,
    String? assignedRoute,
  }) async {
    try {
      final driverRef = _db.collection('drivers');
      final driverDocs = await driverRef
          .where('driverId', isEqualTo: driverId)
          .get();

      if (driverDocs.docs.isEmpty) {
        print('Driver not found: $driverId');
        return false;
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (assignedBusNumber != null) {
        updateData['assignedBusNumber'] = assignedBusNumber;
      }
      if (assignedRoute != null) {
        updateData['assignedRoute'] = assignedRoute;
      }

      for (var doc in driverDocs.docs) {
        await doc.reference.update(updateData);
      }

      print('✓ Driver assignment updated');
      return true;
    } catch (e) {
      print('Error updating driver assignment: $e');
      return false;
    }
  }

  /// Get all active drivers (for Active Drivers page)
  Future<List<Map<String, dynamic>>> getActiveDrivers() async {
    try {
      final snapshot = await _db
          .collection('drivers')
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('Error getting active drivers: $e');
      return [];
    }
  }

  /// Get driver by userId
  Future<Map<String, dynamic>?> getDriverByUserId(String userId) async {
    try {
      final snapshot = await _db
          .collection('drivers')
          .where('driverId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id};
    } catch (e) {
      print('Error getting driver: $e');
      return null;
    }
  }
}
