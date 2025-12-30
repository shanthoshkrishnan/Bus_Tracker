import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/bus_model.dart';
import 'bus_management_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<BusModel>> _busesFuture;

  @override
  void initState() {
    super.initState();
    _busesFuture = _firebaseService.getAllBuses();
  }

  void _refreshBuses() {
    setState(() {
      _busesFuture = _firebaseService.getAllBuses();
    });
  }

  void _createDummyBuses() async {
    try {
      // Create demo data in a separate collection for showcasing
      // All buses use the SAME vehicle number (TN01AB1234) but different bus numbers
      final dummyBuses = [
        {
          'busNumber': '125',
          'busRoute': 'Panimalar Engineering College to Chengalpattu',
          'departureLocation': 'Panimalar Engineering College',
          'arrivalLocation': 'Chengalpattu',
          'departureLatitude': 12.8234,
          'departureLongitude': 79.9619,
          'arrivalLatitude': 12.6789,
          'arrivalLongitude': 79.9608,
          'currentLatitude': 12.7850, // At Urapakkam (Student pickup location)
          'currentLongitude': 79.9585,
          'driverName': 'John Anderson',
          'driverPhone': '+91-98765-43210',
          'vehicleNumber': 'TN01AB1234', // SAME vehicle
          'status': 'active',
        },
        {
          'busNumber': '123',
          'busRoute': 'Panimalar Engineering College to Chengalpattu',
          'departureLocation': 'Panimalar Engineering College',
          'arrivalLocation': 'Chengalpattu',
          'departureLatitude': 12.8234,
          'departureLongitude': 79.9619,
          'arrivalLatitude': 12.6789,
          'arrivalLongitude': 79.9608,
          'currentLatitude': 12.7900, // Slightly ahead
          'currentLongitude': 79.9590,
          'driverName': 'Sarah Martinez',
          'driverPhone': '+91-98765-43211',
          'vehicleNumber': 'TN01AB1234', // SAME vehicle
          'status': 'active',
        },
        {
          'busNumber': '154',
          'busRoute': 'Panimalar Engineering College to Chengalpattu',
          'departureLocation': 'Panimalar Engineering College',
          'arrivalLocation': 'Chengalpattu',
          'departureLatitude': 12.8234,
          'departureLongitude': 79.9619,
          'arrivalLatitude': 12.6789,
          'arrivalLongitude': 79.9608,
          'currentLatitude': 12.7820, // At Urapakkam area
          'currentLongitude': 79.9580,
          'driverName': 'Michael Chen',
          'driverPhone': '+91-98765-43212',
          'vehicleNumber': 'TN01AB1234', // SAME vehicle
          'status': 'active',
        },
        {
          'busNumber': '115',
          'busRoute': 'Panimalar Engineering College to Chengalpattu',
          'departureLocation': 'Panimalar Engineering College',
          'arrivalLocation': 'Chengalpattu',
          'departureLatitude': 12.8234,
          'departureLongitude': 79.9619,
          'arrivalLatitude': 12.6789,
          'arrivalLongitude': 79.9608,
          'currentLatitude': 12.7880, // Close to Urapakkam
          'currentLongitude': 79.9592,
          'driverName': 'David Kumar',
          'driverPhone': '+91-98765-43213',
          'vehicleNumber': 'TN01AB1234', // SAME vehicle
          'status': 'active',
        },
      ];

      // First, store in demo_data collection for showcasing
      for (var bus in dummyBuses) {
        await FirebaseFirestore.instance.collection('demo_data').add({
          ...bus,
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'bus_demo',
        });
      }

      // Then create actual buses for the system
      // Only create one bus for actual tracking to avoid duplicates
      await _firebaseService.addOrUpdateBus(
        busNumber: '125',
        busRoute: 'Panimalar Engineering College to Chengalpattu',
        departureLocation: 'Panimalar Engineering College',
        arrivalLocation: 'Chengalpattu',
        departureLatitude: 12.8234,
        departureLongitude: 79.9619,
        arrivalLatitude: 12.6789,
        arrivalLongitude: 79.9608,
        driverName: 'John Anderson',
        driverPhone: '+91-98765-43210',
        vehicleNumber: 'TN01AB1234',
        status: 'active',
        currentLatitude: 12.7850,
        currentLongitude: 79.9585,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data created! 4 buses in demo collection, 1 live bus created.')),
        );
        _refreshBuses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating dummy data: $e')),
        );
      }
    }
  }

  void _createDemoRoutes() async {
    try {
      // Evening route: Panimalar to Chengalpattu (3:07 PM start)
      final eveningRoute = {
        'routeName': 'Panimalar to Chengalpattu (Evening)',
        'busNumber': '125',
        'departureFrom': 'Panimalar Engineering College',
        'arrivalAt': 'Chengalpattu',
        'departureLatitude': 12.8234,
        'departureLongitude': 79.9619,
        'arrivalLatitude': 12.6789,
        'arrivalLongitude': 79.9608,
        'departureTime': '15:07', // 3:07 PM
        'arrivalTime': '16:30',
        'waypoints': [
          {'location': 'Panimalar Engineering College', 'latitude': 12.8234, 'longitude': 79.9619},
          {'location': 'Urapakkam', 'latitude': 12.7850, 'longitude': 79.9585},
          {'location': 'Chengalpattu', 'latitude': 12.6789, 'longitude': 79.9608},
        ],
        'routeType': 'evening',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Morning route: Chengalpattu to Panimalar (7:00 AM start)
      final morningRoute = {
        'routeName': 'Chengalpattu to Panimalar (Morning)',
        'busNumber': '125',
        'departureFrom': 'Chengalpattu',
        'arrivalAt': 'Panimalar Engineering College',
        'departureLatitude': 12.6789,
        'departureLongitude': 79.9608,
        'arrivalLatitude': 12.8234,
        'arrivalLongitude': 79.9619,
        'departureTime': '07:00', // 7:00 AM
        'arrivalTime': '08:30',
        'waypoints': [
          {'location': 'Chengalpattu', 'latitude': 12.6789, 'longitude': 79.9608},
          {'location': 'Urapakkam', 'latitude': 12.7850, 'longitude': 79.9585},
          {'location': 'Panimalar Engineering College', 'latitude': 12.8234, 'longitude': 79.9619},
        ],
        'routeType': 'morning',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Create routes in Firestore
      await FirebaseFirestore.instance.collection('routes').add(eveningRoute);
      await FirebaseFirestore.instance.collection('routes').add(morningRoute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo routes created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating routes: $e')),
        );
      }
    }
  }

  void _navigateToBusManagement({String? busId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusManagementPage(busId: busId),
      ),
    ).then((_) => _refreshBuses());
  }

  void _deleteBus(String busId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firebaseService.deleteBus(busId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bus deleted successfully')),
                  );
                  _refreshBuses();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B6F47),
        elevation: 0,
        title: const Text(
          'Bus Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton.icon(
              onPressed: _createDemoRoutes,
              icon: const Icon(Icons.route_outlined, size: 18),
              label: const Text('Routes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8B6F47),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton.icon(
              onPressed: _createDummyBuses,
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: const Text('Demo Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8B6F47),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<BusModel>>(
        future: _busesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshBuses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final buses = snapshot.data ?? [];

          if (buses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No buses yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new bus to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToBusManagement(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Bus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6F47),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: buses.length + 1,
            itemBuilder: (context, index) {
              if (index == buses.length) {
                // Add new bus button
                return GestureDetector(
                  onTap: () => _navigateToBusManagement(),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add Bus',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final bus = buses[index];
              return _buildBusCard(bus);
            },
          );
        },
      ),
    );
  }

  Widget _buildBusCard(BusModel bus) {
    final status = bus.status;
    final statusColor = status == 'active' ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: () => _navigateToBusManagement(busId: bus.id),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B6F47).withOpacity(0.1),
                const Color(0xFF8B6F47).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6F47).withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus.busNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5C4A3D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bus.busRoute,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Driver info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Color(0xFF8B6F47),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  bus.driverName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5C4A3D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Color(0xFF8B6F47),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  bus.driverPhone,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7A6B60),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Vehicle info
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 14,
                            color: Color(0xFF8B6F47),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              bus.vehicleNumber,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7A6B60),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToBusManagement(busId: bus.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF8B6F47),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _deleteBus(bus.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
