import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class DriverPage extends StatefulWidget {
  final String driverEmail;
  final String driverName;

  const DriverPage({
    super.key,
    required this.driverEmail,
    required this.driverName,
  });

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Map<String, dynamic>?> _assignedBusFuture;

  @override
  void initState() {
    super.initState();
    _assignedBusFuture = _firebaseService.getDriverAssignedBus(widget.driverEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B6F47),
        elevation: 0,
        title: const Text(
          'My Vehicle Assignment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _assignedBusFuture,
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
                    onPressed: () {
                      setState(() {
                        _assignedBusFuture =
                            _firebaseService.getDriverAssignedBus(widget.driverEmail);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final busData = snapshot.data;
          final isAssigned = busData != null &&
              (busData['busNumber'] != null && busData['busNumber'] != 'Not Assigned');

          return SingleChildScrollView(
            child: Column(
              children: [
                // Driver Info Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.driverName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C4A3D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Driver',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.driverEmail,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Assignment Status
                if (isAssigned)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withOpacity(0.1),
                          const Color(0xFF4CAF50).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Bus Assigned',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9800).withOpacity(0.1),
                          const Color(0xFFFF9800).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Color(0xFFFF9800),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'No Bus Assigned Yet',
                          style: TextStyle(
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Bus Details Card
                if (isAssigned)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bus Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C4A3D),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          icon: Icons.directions_bus,
                          label: 'Bus Number',
                          value: busData['busNumber'] ?? 'N/A',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.route,
                          label: 'Route',
                          value: busData['busRoute'] ?? 'N/A',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.directions_car,
                          label: 'Vehicle Number',
                          value: busData['vehicleNumber'] ?? 'N/A',
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_bus_filled,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Vehicle Assigned',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait for the admin to assign you a bus',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B6F47).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF8B6F47),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C4A3D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
