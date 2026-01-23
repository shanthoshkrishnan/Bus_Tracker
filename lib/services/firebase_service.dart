// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/bus_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user with email and password
  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String year,
    required String department,
    required int age,
    required String dob,
    required String address,
    required String role,
    required String gender,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'year': year,
        'department': department,
        'age': age,
        'dob': dob,
        'address': address,
        'role': role,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If user is a driver, create a driver record
      if (role.toLowerCase() == 'driver') {
        await _firestore.collection('drivers').add({
          'driverId': userCredential.user!.uid,
          'driverName': '$firstName $lastName',
          'driverEmail': email,
          'driverPhone': '',
          'assignedBusNumber': '',
          'assignedRoute': '',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('User registered successfully: ${userCredential.user!.email}');
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user exists
  Future<bool> userExists(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Bus-related methods
  
  // Get all buses assigned to a student
  Future<List<BusModel>> getBusesForStudent(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('buses')
          .where('assignedStudents', arrayContains: studentId)
          .get();

      return querySnapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching buses for student: $e');
      return [];
    }
  }

  // Get bus by ID
  Future<BusModel?> getBusById(String busId) async {
    try {
      final doc = await _firestore.collection('buses').doc(busId).get();
      if (doc.exists) {
        return BusModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching bus: $e');
      return null;
    }
  }

  // Add a new bus
  Future<String> addBus(BusModel bus) async {
    try {
      final docRef = await _firestore.collection('buses').add(bus.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding bus: $e');
      rethrow;
    }
  }

  // Update bus
  Future<void> updateBus(String busId, BusModel bus) async {
    try {
      await _firestore.collection('buses').doc(busId).update(bus.toMap());
    } catch (e) {
      print('Error updating bus: $e');
      rethrow;
    }
  }

  // Get all buses
  Future<List<BusModel>> getAllBuses() async {
    try {
      final querySnapshot = await _firestore.collection('buses').get();
      return querySnapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching all buses: $e');
      return [];
    }
  }

  // Assign student to bus
  Future<void> assignStudentToBus(String busId, String studentId) async {
    try {
      await _firestore.collection('buses').doc(busId).update({
        'assignedStudents': FieldValue.arrayUnion([studentId])
      });
    } catch (e) {
      print('Error assigning student to bus: $e');
      rethrow;
    }
  }

  // Remove student from bus
  Future<void> removeStudentFromBus(String busId, String studentId) async {
    try {
      await _firestore.collection('buses').doc(busId).update({
        'assignedStudents': FieldValue.arrayRemove([studentId])
      });
    } catch (e) {
      print('Error removing student from bus: $e');
      rethrow;
    }
  }

  // Get all drivers from users collection
  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    try {
      QuerySnapshot driverDocs = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .get();

      return driverDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
        };
      }).toList();
    } catch (e) {
      // If index error, fallback to fetching all users and filtering
      if (e.toString().contains('index') || e.toString().contains('requires an index')) {
        try {
          QuerySnapshot allUsers = await _firestore.collection('users').get();
          return allUsers.docs
              .where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return data['role'] == 'driver';
              })
              .map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return {
                  'uid': doc.id,
                  'firstName': data['firstName'] ?? '',
                  'lastName': data['lastName'] ?? '',
                  'email': data['email'] ?? '',
                  'phone': data['phone'] ?? '',
                };
              })
              .toList();
        } catch (fallbackError) {
          print('Error in fallback: $fallbackError');
          rethrow;
        }
      }
      print('Error fetching drivers: $e');
      rethrow;
    }
  }

  // Add or Update Bus
  Future<String> addOrUpdateBus({
    String? busId,
    required String busNumber,
    required String busRoute,
    required String departureLocation,
    required String arrivalLocation,
    required double departureLatitude,
    required double departureLongitude,
    required double arrivalLatitude,
    required double arrivalLongitude,
    required String driverName,
    required String driverPhone,
    required String vehicleNumber,
    required String status,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    try {
      final busData = {
        'busNumber': busNumber,
        'busRoute': busRoute,
        'departureLocation': departureLocation,
        'arrivalLocation': arrivalLocation,
        'departureLatitude': departureLatitude,
        'departureLongitude': departureLongitude,
        'arrivalLatitude': arrivalLatitude,
        'arrivalLongitude': arrivalLongitude,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'vehicleNumber': vehicleNumber,
        'status': status,
        'assignedStudents': [],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add current location if provided
      if (currentLatitude != null && currentLongitude != null) {
        busData['currentLatitude'] = currentLatitude;
        busData['currentLongitude'] = currentLongitude;
        busData['lastUpdated'] = FieldValue.serverTimestamp();
      }

      if (busId != null && busId.isNotEmpty) {
        // Update existing bus
        await _firestore.collection('buses').doc(busId).update(busData);
        print('Bus updated successfully: $busId');
        return busId;
      } else {
        // Add new bus
        busData['createdAt'] = FieldValue.serverTimestamp();
        DocumentReference docRef = await _firestore.collection('buses').add(busData);
        print('Bus added successfully: ${docRef.id}');
        return docRef.id;
      }
    } catch (e) {
      print('Error adding/updating bus: $e');
      rethrow;
    }
  }

  // Delete bus
  Future<void> deleteBus(String busId) async {
    try {
      await _firestore.collection('buses').doc(busId).delete();
      print('Bus deleted successfully: $busId');
    } catch (e) {
      print('Error deleting bus: $e');
      rethrow;
    }
  }

  // Update driver with assigned bus information
  Future<void> updateDriverWithBusAssignment({
    required String driverEmail,
    required String busNumber,
    required String busRoute,
    required String vehicleNumber,
  }) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: driverEmail)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final driverId = userQuery.docs.first.id;
        await _firestore.collection('users').doc(driverId).update({
          'assignedBus': busNumber,
          'assignedRoute': busRoute,
          'assignedVehicle': vehicleNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Driver updated with bus assignment: $driverEmail');
      }
    } catch (e) {
      print('Error updating driver with bus assignment: $e');
      rethrow;
    }
  }

  // Get driver's assigned bus
  Future<Map<String, dynamic>?> getDriverAssignedBus(String driverEmail) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: driverEmail)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        return {
          'busNumber': userData['assignedBus'] ?? 'Not Assigned',
          'busRoute': userData['assignedRoute'] ?? '',
          'vehicleNumber': userData['assignedVehicle'] ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Error getting driver assigned bus: $e');
      return null;
    }
  }

  // Update bus location
  Future<void> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('buses').doc(busId).update({
        'currentLatitude': latitude,
        'currentLongitude': longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('Bus location updated: $busId');
    } catch (e) {
      print('Error updating bus location: $e');
      rethrow;
    }
  }

  // Get nearby buses for a student (within 5km)
  Future<List<Map<String, dynamic>>> getNearbyBuses({
    required double studentLat,
    required double studentLng,
    double radiusKm = 5.0,
  }) async {
    try {
      final allBuses = await getAllBuses();
      final nearbyBuses = <Map<String, dynamic>>[];

      for (var bus in allBuses) {
        // Use current location if available, otherwise use arrival location
        final busLat = bus.currentLatitude ?? bus.arrivalLatitude;
        final busLng = bus.currentLongitude ?? bus.arrivalLongitude;

        final distance = _calculateDistance(
          studentLat,
          studentLng,
          busLat,
          busLng,
        );

        if (distance <= radiusKm) {
          nearbyBuses.add({
            'busNumber': bus.busNumber,
            'busRoute': bus.busRoute,
            'driverName': bus.driverName,
            'distance': distance.toStringAsFixed(2),
            'status': bus.status,
            'latitude': busLat,
            'longitude': busLng,
          });
        }
      }

      return nearbyBuses;
    } catch (e) {
      print('Error getting nearby buses: $e');
      return [];
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * asin(sqrt(a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Create or update a bus route with schedule
  Future<String> createOrUpdateRoute({
    String? routeId,
    required String routeName,
    required String busNumber,
    required String departureFrom,
    required String arrivalAt,
    required double departureLatitude,
    required double departureLongitude,
    required double arrivalLatitude,
    required double arrivalLongitude,
    required String departureTime,
    required String arrivalTime,
    required List<Map<String, dynamic>> waypoints, // [{location, lat, lon}, ...]
    required String routeType, // 'morning' or 'evening'
  }) async {
    try {
      final routeData = {
        'routeName': routeName,
        'busNumber': busNumber,
        'departureFrom': departureFrom,
        'arrivalAt': arrivalAt,
        'departureLatitude': departureLatitude,
        'departureLongitude': departureLongitude,
        'arrivalLatitude': arrivalLatitude,
        'arrivalLongitude': arrivalLongitude,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'waypoints': waypoints,
        'routeType': routeType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (routeId != null && routeId.isNotEmpty) {
        await _firestore.collection('routes').doc(routeId).update(routeData);
        print('Route updated: $routeId');
        return routeId;
      } else {
        routeData['createdAt'] = FieldValue.serverTimestamp();
        DocumentReference docRef = await _firestore.collection('routes').add(routeData);
        print('Route created: ${docRef.id}');
        return docRef.id;
      }
    } catch (e) {
      print('Error creating/updating route: $e');
      rethrow;
    }
  }

  // Get route by bus number
  Future<Map<String, dynamic>?> getRouteByBusNumber(String busNumber) async {
    try {
      final query = await _firestore
          .collection('routes')
          .where('busNumber', isEqualTo: busNumber)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  // Update user's home location (for notifications)
  Future<void> updateUserLocation({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'homeLocation': locationName,
        'homeLatitude': latitude,
        'homeLongitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User location updated: $userId');
    } catch (e) {
      print('Error updating user location: $e');
      rethrow;
    }
  }

  // Create location-based notification
  Future<void> createNotification({
    required String userId,
    required String busNumber,
    required String message,
    required String notificationType, // 'bus_approaching', 'bus_arrived', 'bus_near'
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'busNumber': busNumber,
        'message': message,
        'type': notificationType,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Notification created for user: $userId');
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final query = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Check if bus is at user's location and notify
  Future<void> checkAndNotifyBusArrival({
    required String busNumber,
    required double busLatitude,
    required double busLongitude,
    double radiusKm = 1.0, // 1 km proximity for arrival notification
  }) async {
    try {
      // Get all users with home location
      final usersQuery = await _firestore
          .collection('users')
          .where('homeLatitude', isNotEqualTo: null)
          .get();

      for (var userDoc in usersQuery.docs) {
        final userData = userDoc.data();
        final userLat = userData['homeLatitude'] as double?;
        final userLng = userData['homeLongitude'] as double?;
        final userLocation = userData['homeLocation'] as String?;

        if (userLat != null && userLng != null) {
          final distance = _calculateDistance(busLatitude, busLongitude, userLat, userLng);

          // Notify user if bus is very close (arrival)
          if (distance <= radiusKm) {
            await createNotification(
              userId: userDoc.id,
              busNumber: busNumber,
              message: 'Bus #$busNumber has arrived at $userLocation',
              notificationType: 'bus_arrived',
            );
          }
          // Also check for approaching (within 5 km but not arrived)
          else if (distance <= 5.0) {
            await createNotification(
              userId: userDoc.id,
              busNumber: busNumber,
              message: 'Bus #$busNumber is approaching. ${distance.toStringAsFixed(1)} km away',
              notificationType: 'bus_approaching',
            );
          }
        }
      }
    } catch (e) {
      print('Error checking bus arrival: $e');
    }
  }

  // Get all routes
  Future<List<Map<String, dynamic>>> getAllRoutes() async {
    try {
      final query = await _firestore.collection('routes').get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting routes: $e');
      return [];
    }
  }

  // Get pending notifications for a user (unread)
  Future<List<Map<String, dynamic>>> getPendingNotifications(String userId) async {
    try {
      final query = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get all drivers from drivers collection
  Future<List<Map<String, dynamic>>> getDriversFromCollection() async {
    try {
      QuerySnapshot driverDocs = await _firestore
          .collection('drivers')
          .where('status', isEqualTo: 'active')
          .get();

      return driverDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'documentId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching drivers from drivers collection: $e');
      return [];
    }
  }

  // Update driver assignment (bus and route)
  Future<void> updateDriverAssignment({
    required String driverId,
    required String assignedBusNumber,
    required String assignedRoute,
  }) async {
    try {
      // Update driver record in drivers collection
      QuerySnapshot driverDocs = await _firestore
          .collection('drivers')
          .where('driverId', isEqualTo: driverId)
          .get();

      for (var doc in driverDocs.docs) {
        await doc.reference.update({
          'assignedBusNumber': assignedBusNumber,
          'assignedRoute': assignedRoute,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Driver assignment updated successfully');
    } catch (e) {
      print('Error updating driver assignment: $e');
      rethrow;
    }
  }

  // Update driver phone
  Future<void> updateDriverPhone({
    required String driverId,
    required String phone,
  }) async {
    try {
      QuerySnapshot driverDocs = await _firestore
          .collection('drivers')
          .where('driverId', isEqualTo: driverId)
          .get();

      for (var doc in driverDocs.docs) {
        await doc.reference.update({
          'driverPhone': phone,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Driver phone updated successfully');
    } catch (e) {
      print('Error updating driver phone: $e');
      rethrow;
    }
  }

  // Deactivate driver
  Future<void> deactivateDriver(String driverId) async {
    try {
      QuerySnapshot driverDocs = await _firestore
          .collection('drivers')
          .where('driverId', isEqualTo: driverId)
          .get();

      for (var doc in driverDocs.docs) {
        await doc.reference.update({
          'status': 'inactive',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Driver deactivated successfully');
    } catch (e) {
      print('Error deactivating driver: $e');
      rethrow;
    }
  }

  // Reactivate driver
  Future<void> reactivateDriver(String driverId) async {
    try {
      QuerySnapshot driverDocs = await _firestore
          .collection('drivers')
          .where('driverId', isEqualTo: driverId)
          .get();

      for (var doc in driverDocs.docs) {
        await doc.reference.update({
          'status': 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Driver reactivated successfully');
    } catch (e) {
      print('Error reactivating driver: $e');
      rethrow;
    }
  }

  // Update user profile AND sync driver record if needed
  // This is called when user updates their profile
  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required String role,
  }) async {
    try {
      // Get current user data to track role changes
      final currentUserDoc = await _firestore.collection('users').doc(userId).get();
      final currentData = currentUserDoc.data() ?? {};
      final previousRole = currentData['role'] ?? '';

      // Update user profile
      await _firestore.collection('users').doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'address': address,
        'role': role,
        'previousRole': previousRole, // Track for sync purposes
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Trigger driver sync if user role is or was 'driver'
      await _syncDriverAfterProfileUpdate(userId, firstName, lastName, phone, role, previousRole);

      print('User profile updated: $userId');
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Internal method: Handle driver sync on profile update
  Future<void> _syncDriverAfterProfileUpdate(
    String userId,
    String firstName,
    String lastName,
    String phone,
    String newRole,
    String previousRole,
  ) async {
    try {
      final normalizedRole = newRole.toLowerCase();
      final normalizedPrevRole = previousRole.toLowerCase();

      // Case 1: User became a driver
      if (normalizedRole == 'driver' && normalizedPrevRole != 'driver') {
        await _createDriverRecord(
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );
        print('✓ Driver record created on profile update');
        return;
      }

      // Case 2: User is still a driver - sync details
      if (normalizedRole == 'driver') {
        await _updateDriverDetails(userId, firstName, lastName, phone);
        print('✓ Driver details synced on profile update');
        return;
      }

      // Case 3: User is no longer a driver - mark as inactive
      if (normalizedRole != 'driver' && normalizedPrevRole == 'driver') {
        await _markDriverInactiveByUserId(userId);
        print('✓ Driver marked inactive on role change');
      }
    } catch (e) {
      print('Error syncing driver on profile update: $e');
      // Don't rethrow - profile update should still succeed even if driver sync fails
    }
  }

  // Internal: Create driver record
  Future<void> _createDriverRecord({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final existingDriver = await _firestore
          .collection('drivers')
          .where('driverId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingDriver.docs.isNotEmpty) {
        return; // Already exists
      }

      await _firestore.collection('drivers').add({
        'driverId': userId,
        'driverName': '$firstName $lastName'.trim(),
        'driverEmail': _auth.currentUser?.email ?? '',
        'driverPhone': phone,
        'assignedBusNumber': '',
        'assignedRoute': '',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating driver record: $e');
      throw e;
    }
  }

  // Internal: Update driver details
  Future<void> _updateDriverDetails(
    String userId,
    String firstName,
    String lastName,
    String phone,
  ) async {
    try {
      final driverDocs = await _firestore
          .collection('drivers')
          .where('driverId', isEqualTo: userId)
          .get();

      for (var doc in driverDocs.docs) {
        await doc.reference.update({
          'driverName': '$firstName $lastName'.trim(),
          'driverPhone': phone,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating driver details: $e');
      throw e;
    }
  }

  // Internal: Mark driver as inactive
  Future<void> _markDriverInactiveByUserId(String userId) async {
    try {
      final driverDocs = await _firestore
          .collection('drivers')
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
      throw e;
    }
  }
}

