// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'bus_management_page.dart';
import 'route_management_page.dart';
import 'driver_management_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<int> _getBusCount() async {
    final buses = await _firebaseService.getAllBuses();
    return buses.length;
  }

  Future<int> _getDriverCount() async {
    final drivers =
        await FirebaseFirestore.instance.collection('drivers').get();
    return drivers.docs.length;
  }

  Future<int> _getRouteCount() async {
    final routes =
        await FirebaseFirestore.instance.collection('routes').get();
    return routes.docs.length;
  }

  Future<int> _getActiveBusCount() async {
    final buses = await _firebaseService.getAllBuses();
    return buses.where((bus) => bus.status == 'active').length;
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
        setState(() {});
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
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating routes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage buses, drivers & routes',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Management Options
            Text(
              'Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              icon: Icons.directions_bus_outlined,
              title: 'Bus Management',
              subtitle: 'Add, edit, and manage buses',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BusManagementPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              icon: Icons.person_outline,
              title: 'Driver Management',
              subtitle: 'Assign and manage drivers',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DriverManagementPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              icon: Icons.route_outlined,
              title: 'Route Management',
              subtitle: 'Create and manage routes',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RouteManagementPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getBusCount(),
                    builder: (context, snapshot) {
                      final value = snapshot.data?.toString() ?? '0';
                      return _buildStatCard(
                        icon: Icons.directions_bus,
                        value: value,
                        label: 'Total Buses',
                        color: const Color(0xFF18181B),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getDriverCount(),
                    builder: (context, snapshot) {
                      final value = snapshot.data?.toString() ?? '0';
                      return _buildStatCard(
                        icon: Icons.person,
                        value: value,
                        label: 'Drivers',
                        color: const Color(0xFF18181B),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getRouteCount(),
                    builder: (context, snapshot) {
                      final value = snapshot.data?.toString() ?? '0';
                      return _buildStatCard(
                        icon: Icons.route,
                        value: value,
                        label: 'Routes',
                        color: const Color(0xFF18181B),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getActiveBusCount(),
                    builder: (context, snapshot) {
                      final value = snapshot.data?.toString() ?? '0';
                      return _buildStatCard(
                        icon: Icons.check_circle,
                        value: value,
                        label: 'Active',
                        color: const Color(0xFF16A34A),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Demo Controls Section
            Text(
              'Demo Controls',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDemoButton(
                    icon: Icons.add_location,
                    label: 'Demo Routes',
                    onPressed: _createDemoRoutes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDemoButton(
                    icon: Icons.download,
                    label: 'Demo Buses',
                    onPressed: _createDummyBuses,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF18181B), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF71717A),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFF71717A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF71717A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: const Color(0xFF18181B), size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF18181B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
