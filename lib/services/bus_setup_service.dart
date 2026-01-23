// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';

class BusSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all sample buses
  static List<BusModel> getSampleBuses() {
    return [
      BusModel(
        id: '',
        busNumber: 'BUS-A-001',
        busRoute: 'Route A - Campus to City Center',
        departureLocation: 'Main Campus Gate',
        arrivalLocation: 'City Center Bus Station',
        departureLatitude: 40.7128,
        departureLongitude: -74.0060,
        arrivalLatitude: 40.7489,
        arrivalLongitude: -73.9680,
        driverName: 'John Anderson',
        driverPhone: '+1-800-123-4567',
        vehicleNumber: 'DL01AB1234',
        assignedStudents: [],
        status: 'active',
      ),
      BusModel(
        id: '',
        busNumber: 'BUS-B-002',
        busRoute: 'Route B - Residential to Campus',
        departureLocation: 'Residential Area A',
        arrivalLocation: 'University Main Building',
        departureLatitude: 40.8088,
        departureLongitude: -73.9282,
        arrivalLatitude: 40.8075,
        arrivalLongitude: -73.8740,
        driverName: 'Sarah Martinez',
        driverPhone: '+1-800-234-5678',
        vehicleNumber: 'DL02CD5678',
        assignedStudents: [],
        status: 'active',
      ),
      BusModel(
        id: '',
        busNumber: 'BUS-C-003',
        busRoute: 'Route C - Mall to Sports Complex',
        departureLocation: 'Mall Junction',
        arrivalLocation: 'Sports Complex',
        departureLatitude: 40.7282,
        departureLongitude: -73.7949,
        arrivalLatitude: 40.7614,
        arrivalLongitude: -73.9776,
        driverName: 'Michael Chen',
        driverPhone: '+1-800-345-6789',
        vehicleNumber: 'DL03EF9012',
        assignedStudents: [],
        status: 'active',
      ),
      BusModel(
        id: '',
        busNumber: 'BUS-D-004',
        busRoute: 'Route D - Downtown to Suburbs',
        departureLocation: 'Downtown Metro Station',
        arrivalLocation: 'Suburban College Campus',
        departureLatitude: 40.7614,
        departureLongitude: -73.9776,
        arrivalLatitude: 40.7282,
        arrivalLongitude: -73.7949,
        driverName: 'Emily Rodriguez',
        driverPhone: '+1-800-456-7890',
        vehicleNumber: 'DL04GH3456',
        assignedStudents: [],
        status: 'active',
      ),
      BusModel(
        id: '',
        busNumber: 'BUS-E-005',
        busRoute: 'Route E - Airport Express',
        departureLocation: 'Airport Terminal 1',
        arrivalLocation: 'Main City Center',
        departureLatitude: 40.6413,
        departureLongitude: -73.7781,
        arrivalLatitude: 40.7128,
        arrivalLongitude: -74.0060,
        driverName: 'David Wilson',
        driverPhone: '+1-800-567-8901',
        vehicleNumber: 'DL05IJ7890',
        assignedStudents: [],
        status: 'active',
      ),
    ];
  }

  // Add all sample buses to Firestore
  Future<List<String>> initializeSampleBuses() async {
    try {
      final sampleBuses = getSampleBuses();
      final busIds = <String>[];

      for (final bus in sampleBuses) {
        final docRef = await _firestore.collection('buses').add(bus.toMap());
        busIds.add(docRef.id);
        print('Added bus: ${bus.busNumber} with ID: ${docRef.id}');
      }

      return busIds;
    } catch (e) {
      print('Error initializing sample buses: $e');
      rethrow;
    }
  }

  // Check if buses collection exists and has data
  Future<bool> hasBuses() async {
    try {
      final snapshot = await _firestore.collection('buses').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking buses: $e');
      return false;
    }
  }

  // Delete all buses (use with caution!)
  Future<void> deleteAllBuses() async {
    try {
      final snapshot = await _firestore.collection('buses').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('All buses deleted');
    } catch (e) {
      print('Error deleting buses: $e');
      rethrow;
    }
  }

  // Get specific sample bus data (for manual assignment)
  static BusModel getSampleBusA() => getSampleBuses()[0];
  static BusModel getSampleBusB() => getSampleBuses()[1];
  static BusModel getSampleBusC() => getSampleBuses()[2];
}
