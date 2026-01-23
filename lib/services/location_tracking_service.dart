// ignore_for_file: avoid_print
import 'package:firebase_database/firebase_database.dart';
import '../models/location_model.dart';

class LocationTrackingService {
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;

  // References
  late DatabaseReference _busLocationsRef;
  late DatabaseReference _driverLocationsRef;
  late DatabaseReference _busRoutesRef;

  late DatabaseReference _studentAssignmentsRef;
  late DatabaseReference _routeTablesRef;

  LocationTrackingService() {
    _busLocationsRef = _realtimeDb.ref('bus_locations');
    _driverLocationsRef = _realtimeDb.ref('driver_locations');
    _busRoutesRef = _realtimeDb.ref('bus_routes');
    _studentAssignmentsRef = _realtimeDb.ref('student_bus_assignments');
    _routeTablesRef = _realtimeDb.ref('route_tables');
  }

  // ==================== BUS LOCATION OPERATIONS ====================

  /// Update bus location in real-time (from sensor)
  Future<void> updateBusLocation(BusLocation busLocation) async {
    try {
      await _busLocationsRef.child(busLocation.busId).set(busLocation.toJson());
      print('✅ Bus location updated: ${busLocation.busNumber}');
    } catch (e) {
      print('❌ Error updating bus location: $e');
      rethrow;
    }
  }

  /// Get all buses with their current locations
  Future<List<BusLocation>> getAllBusLocations() async {
    try {
      final snapshot = await _busLocationsRef.get();
      if (snapshot.exists) {
        List<BusLocation> buses = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((busId, busData) {
          buses.add(
            BusLocation.fromJson(busId, Map<String, dynamic>.from(busData)),
          );
        });

        return buses;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching bus locations: $e');
      return [];
    }
  }

  /// Get specific bus location by ID
  Future<BusLocation?> getBusLocation(String busId) async {
    try {
      final snapshot = await _busLocationsRef.child(busId).get();
      if (snapshot.exists) {
        return BusLocation.fromJson(
          busId,
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>),
        );
      }
      return null;
    } catch (e) {
      print('❌ Error fetching bus location: $e');
      return null;
    }
  }

  /// Stream real-time bus locations
  Stream<List<BusLocation>> streamAllBusLocations() {
    return _busLocationsRef.onValue.map((event) {
      if (event.snapshot.exists) {
        List<BusLocation> buses = [];
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((busId, busData) {
          buses.add(
            BusLocation.fromJson(busId, Map<String, dynamic>.from(busData)),
          );
        });

        return buses;
      }
      return [];
    });
  }

  /// Stream specific bus location
  Stream<BusLocation?> streamBusLocation(String busId) {
    return _busLocationsRef.child(busId).onValue.map((event) {
      if (event.snapshot.exists) {
        return BusLocation.fromJson(
          busId,
          Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>,
          ),
        );
      }
      return null;
    });
  }

  /// Update bus status (departed, in-transit, arrived, delayed)
  Future<void> updateBusStatus(
    String busId,
    String status, {
    String? delayReason,
    int? delayMinutes,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      if (delayReason != null) {
        updates['delayReason'] = delayReason;
      }
      if (delayMinutes != null) {
        updates['delayMinutes'] = delayMinutes;
      }

      await _busLocationsRef.child(busId).update(updates);
      print('✅ Bus status updated: $status');
    } catch (e) {
      print('❌ Error updating bus status: $e');
      rethrow;
    }
  }

  /// Report delay with reason
  Future<void> reportBusDelay(
    String busId,
    String delayReason,
    int delayMinutes,
  ) async {
    try {
      await _busLocationsRef.child(busId).update({
        'status': 'delayed',
        'delayReason': delayReason,
        'delayMinutes': delayMinutes,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print('✅ Delay reported: $delayReason ($delayMinutes mins)');
    } catch (e) {
      print('❌ Error reporting delay: $e');
      rethrow;
    }
  }

  // ==================== DRIVER LOCATION OPERATIONS ====================

  /// Update driver location in real-time (from GPS)
  Future<void> updateDriverLocation(DriverLocation driverLocation) async {
    try {
      await _driverLocationsRef
          .child(driverLocation.driverId)
          .set(driverLocation.toJson());
      print('✅ Driver location updated: ${driverLocation.driverName}');
    } catch (e) {
      print('❌ Error updating driver location: $e');
      rethrow;
    }
  }

  /// Get all driver locations
  Future<List<DriverLocation>> getAllDriverLocations() async {
    try {
      final snapshot = await _driverLocationsRef.get();
      if (snapshot.exists) {
        List<DriverLocation> drivers = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((driverId, driverData) {
          drivers.add(
            DriverLocation.fromJson(
              driverId,
              Map<String, dynamic>.from(driverData),
            ),
          );
        });

        return drivers;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching driver locations: $e');
      return [];
    }
  }

  /// Get specific driver location
  Future<DriverLocation?> getDriverLocation(String driverId) async {
    try {
      final snapshot = await _driverLocationsRef.child(driverId).get();
      if (snapshot.exists) {
        return DriverLocation.fromJson(
          driverId,
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>),
        );
      }
      return null;
    } catch (e) {
      print('❌ Error fetching driver location: $e');
      return null;
    }
  }

  /// Stream all driver locations
  Stream<List<DriverLocation>> streamAllDriverLocations() {
    return _driverLocationsRef.onValue.map((event) {
      if (event.snapshot.exists) {
        List<DriverLocation> drivers = [];
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((driverId, driverData) {
          drivers.add(
            DriverLocation.fromJson(
              driverId,
              Map<String, dynamic>.from(driverData),
            ),
          );
        });

        return drivers;
      }
      return [];
    });
  }

  /// Stream specific driver location
  Stream<DriverLocation?> streamDriverLocation(String driverId) {
    return _driverLocationsRef.child(driverId).onValue.map((event) {
      if (event.snapshot.exists) {
        return DriverLocation.fromJson(
          driverId,
          Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>,
          ),
        );
      }
      return null;
    });
  }

  /// Update driver status (online, offline, on-break)
  Future<void> updateDriverStatus(String driverId, String status) async {
    try {
      await _driverLocationsRef.child(driverId).update({
        'status': status,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print('✅ Driver status updated: $status');
    } catch (e) {
      print('❌ Error updating driver status: $e');
      rethrow;
    }
  }

  // ==================== BUS ROUTE OPERATIONS ====================

  /// Create new bus route (Admin only)
  Future<void> createBusRoute(BusRoute route) async {
    try {
      await _busRoutesRef.child(route.routeId).set(route.toJson());
      print('✅ Route created: ${route.routeName}');
    } catch (e) {
      print('❌ Error creating route: $e');
      rethrow;
    }
  }

  /// Get all bus routes
  Future<List<BusRoute>> getAllBusRoutes() async {
    try {
      final snapshot = await _busRoutesRef.get();
      if (snapshot.exists) {
        List<BusRoute> routes = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((routeId, routeData) {
          routes.add(
            BusRoute.fromJson(routeId, Map<String, dynamic>.from(routeData)),
          );
        });

        return routes;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching routes: $e');
      return [];
    }
  }

  /// Get specific route by ID
  Future<BusRoute?> getBusRoute(String routeId) async {
    try {
      final snapshot = await _busRoutesRef.child(routeId).get();
      if (snapshot.exists) {
        return BusRoute.fromJson(
          routeId,
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>),
        );
      }
      return null;
    } catch (e) {
      print('❌ Error fetching route: $e');
      return null;
    }
  }

  /// Stream all bus routes
  Stream<List<BusRoute>> streamAllBusRoutes() {
    return _busRoutesRef.onValue.map((event) {
      if (event.snapshot.exists) {
        List<BusRoute> routes = [];
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((routeId, routeData) {
          routes.add(
            BusRoute.fromJson(routeId, Map<String, dynamic>.from(routeData)),
          );
        });

        return routes;
      }
      return [];
    });
  }

  /// Update bus route (Admin only)
  Future<void> updateBusRoute(BusRoute route) async {
    try {
      await _busRoutesRef.child(route.routeId).update(route.toJson());
      print('✅ Route updated: ${route.routeName}');
    } catch (e) {
      print('❌ Error updating route: $e');
      rethrow;
    }
  }

  /// Assign bus to route
  Future<void> assignBusToRoute(String routeId, String busId) async {
    try {
      final route = await getBusRoute(routeId);
      if (route != null) {
        List<String> assignedBuses = List.from(route.assignedBuses);
        if (!assignedBuses.contains(busId)) {
          assignedBuses.add(busId);
          await _busRoutesRef.child(routeId).update({
            'assignedBuses': assignedBuses,
          });
          print('✅ Bus assigned to route');
        }
      }
    } catch (e) {
      print('❌ Error assigning bus to route: $e');
      rethrow;
    }
  }

  /// Remove bus from route
  Future<void> removeBusFromRoute(String routeId, String busId) async {
    try {
      final route = await getBusRoute(routeId);
      if (route != null) {
        List<String> assignedBuses = List.from(route.assignedBuses);
        assignedBuses.remove(busId);
        await _busRoutesRef.child(routeId).update({
          'assignedBuses': assignedBuses,
        });
        print('✅ Bus removed from route');
      }
    } catch (e) {
      print('❌ Error removing bus from route: $e');
      rethrow;
    }
  }

  /// Delete bus route (Admin only)
  Future<void> deleteBusRoute(String routeId) async {
    try {
      await _busRoutesRef.child(routeId).remove();
      print('✅ Route deleted');
    } catch (e) {
      print('❌ Error deleting route: $e');
      rethrow;
    }
  }

  /// Get buses by route
  Future<List<BusLocation>> getBusesByRoute(String routeId) async {
    try {
      final route = await getBusRoute(routeId);
      if (route == null) return [];

      List<BusLocation> buses = [];
      for (String busId in route.assignedBuses) {
        final bus = await getBusLocation(busId);
        if (bus != null) {
          buses.add(bus);
        }
      }
      return buses;
    } catch (e) {
      print('❌ Error fetching buses by route: $e');
      return [];
    }
  }

  // ==================== STUDENT BUS ASSIGNMENT OPERATIONS ====================

  /// Assign a bus to a student
  Future<void> assignBusToStudent(StudentBusAssignment assignment) async {
    try {
      await _studentAssignmentsRef
          .child(assignment.assignmentId)
          .set(assignment.toJson());
      print('✅ Bus assigned to student: ${assignment.studentName}');
    } catch (e) {
      print('❌ Error assigning bus to student: $e');
      rethrow;
    }
  }

  /// Get all student bus assignments
  Future<List<StudentBusAssignment>> getAllStudentAssignments() async {
    try {
      final snapshot = await _studentAssignmentsRef.get();
      if (snapshot.exists) {
        List<StudentBusAssignment> assignments = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((assignmentId, assignmentData) {
          assignments.add(
            StudentBusAssignment.fromJson(
              assignmentId,
              Map<String, dynamic>.from(assignmentData),
            ),
          );
        });

        return assignments;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching student assignments: $e');
      return [];
    }
  }

  /// Get assignment for a specific student
  Future<StudentBusAssignment?> getStudentAssignment(String studentId) async {
    try {
      final query = await _studentAssignmentsRef
          .orderByChild('studentId')
          .equalTo(studentId)
          .get();

      if (query.exists) {
        Map<dynamic, dynamic> data = query.value as Map<dynamic, dynamic>;
        final assignmentId = data.keys.first;
        return StudentBusAssignment.fromJson(
          assignmentId,
          Map<String, dynamic>.from(data[assignmentId]),
        );
      }
      return null;
    } catch (e) {
      print('❌ Error fetching student assignment: $e');
      return null;
    }
  }

  /// Get only the assigned bus location for a student (for map display)
  Future<BusLocation?> getStudentAssignedBusLocation(String studentId) async {
    try {
      final assignment = await getStudentAssignment(studentId);
      if (assignment != null) {
        return await getBusLocation(assignment.assignedBusId);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching student assigned bus location: $e');
      return null;
    }
  }

  /// Stream real-time bus location updates for a specific student (single bus)
  Stream<BusLocation?> streamStudentAssignedBusLocation(
    String studentId,
  ) async* {
    try {
      final assignment = await getStudentAssignment(studentId);
      if (assignment != null) {
        yield* streamBusLocation(assignment.assignedBusId);
      }
    } catch (e) {
      print('❌ Error streaming student bus location: $e');
    }
  }

  /// Stream all student assignments in real-time
  Stream<List<StudentBusAssignment>> streamAllStudentAssignments() {
    return _studentAssignmentsRef.onValue.map((event) {
      if (event.snapshot.exists) {
        List<StudentBusAssignment> assignments = [];
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((assignmentId, assignmentData) {
          assignments.add(
            StudentBusAssignment.fromJson(
              assignmentId,
              Map<String, dynamic>.from(assignmentData),
            ),
          );
        });

        return assignments;
      }
      return [];
    });
  }

  /// Get assignments by route ID (all students on a specific route)
  Future<List<StudentBusAssignment>> getStudentAssignmentsByRoute(
    String routeId,
  ) async {
    try {
      final query = await _studentAssignmentsRef
          .orderByChild('routeId')
          .equalTo(routeId)
          .get();

      if (query.exists) {
        List<StudentBusAssignment> assignments = [];
        Map<dynamic, dynamic> data = query.value as Map<dynamic, dynamic>;

        data.forEach((assignmentId, assignmentData) {
          assignments.add(
            StudentBusAssignment.fromJson(
              assignmentId,
              Map<String, dynamic>.from(assignmentData),
            ),
          );
        });

        return assignments;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching assignments by route: $e');
      return [];
    }
  }

  /// Remove student bus assignment
  Future<void> removeStudentAssignment(String assignmentId) async {
    try {
      await _studentAssignmentsRef.child(assignmentId).remove();
      print('✅ Student assignment removed');
    } catch (e) {
      print('❌ Error removing student assignment: $e');
      rethrow;
    }
  }

  /// Update student bus assignment
  Future<void> updateStudentAssignment(StudentBusAssignment assignment) async {
    try {
      await _studentAssignmentsRef
          .child(assignment.assignmentId)
          .update(assignment.toJson());
      print('✅ Student assignment updated');
    } catch (e) {
      print('❌ Error updating student assignment: $e');
      rethrow;
    }
  }

  // ==================== ROUTE TABLE OPERATIONS ====================

  /// Create or update a route in the route table (admin only)
  Future<void> createOrUpdateRouteTable(RouteTable route) async {
    try {
      await _routeTablesRef.child(route.routeId).set(route.toJson());
      print('✅ Route updated: ${route.routeName}');
    } catch (e) {
      print('❌ Error creating/updating route: $e');
      rethrow;
    }
  }

  /// Get all routes from route table
  Future<List<RouteTable>> getAllRoutesFromTable() async {
    try {
      final snapshot = await _routeTablesRef.get();
      if (snapshot.exists) {
        List<RouteTable> routes = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((routeId, routeData) {
          routes.add(
            RouteTable.fromJson(routeId, Map<String, dynamic>.from(routeData)),
          );
        });

        return routes;
      }
      return [];
    } catch (e) {
      print('❌ Error fetching routes: $e');
      return [];
    }
  }

  /// Get a specific route from route table
  Future<RouteTable?> getRouteFromTable(String routeId) async {
    try {
      final snapshot = await _routeTablesRef.child(routeId).get();
      if (snapshot.exists) {
        return RouteTable.fromJson(
          routeId,
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>),
        );
      }
      return null;
    } catch (e) {
      print('❌ Error fetching route: $e');
      return null;
    }
  }

  /// Stream all route table updates in real-time
  /// This allows all subscribers to get updates whenever admin updates routes
  Stream<List<RouteTable>> streamAllRoutesFromTable() {
    return _routeTablesRef.onValue.map((event) {
      if (event.snapshot.exists) {
        List<RouteTable> routes = [];
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((routeId, routeData) {
          routes.add(
            RouteTable.fromJson(routeId, Map<String, dynamic>.from(routeData)),
          );
        });

        return routes;
      }
      return [];
    });
  }

  /// Stream updates for a specific route
  /// Students/drivers on this route will get real-time updates
  Stream<RouteTable?> streamRouteFromTable(String routeId) {
    return _routeTablesRef.child(routeId).onValue.map((event) {
      if (event.snapshot.exists) {
        return RouteTable.fromJson(
          routeId,
          Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>,
          ),
        );
      }
      return null;
    });
  }

  /// Subscribe to route changes (for any listener/subscriber)
  /// This is useful for both drivers and students to get notified of route updates
  Stream<RouteTable?> subscribeToRouteChanges(String routeId) {
    return streamRouteFromTable(routeId);
  }

  /// Delete a route from route table
  Future<void> deleteRouteFromTable(String routeId) async {
    try {
      await _routeTablesRef.child(routeId).remove();
      print('✅ Route deleted: $routeId');
    } catch (e) {
      print('❌ Error deleting route: $e');
      rethrow;
    }
  }

  /// Get all students subscribed to a specific route
  /// Useful for broadcasting route updates to all students
  Future<List<StudentBusAssignment>> getStudentsSubscribedToRoute(
    String routeId,
  ) async {
    return await getStudentAssignmentsByRoute(routeId);
  }

  /// Get all buses on a route (from route table)
  Future<List<String>> getBusesOnRoute(String routeId) async {
    try {
      final route = await getRouteFromTable(routeId);
      return route?.assignedBuses ?? [];
    } catch (e) {
      print('❌ Error fetching buses on route: $e');
      return [];
    }
  }

  /// Get all route stops for navigation
  Future<List<RouteStop>> getRouteStops(String routeId) async {
    try {
      final route = await getRouteFromTable(routeId);
      return route?.stops ?? [];
    } catch (e) {
      print('❌ Error fetching route stops: $e');
      return [];
    }
  }
}
