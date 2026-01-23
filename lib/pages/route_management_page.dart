import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_model.dart';
import '../services/location_tracking_service.dart';

class RouteManagementPage extends StatefulWidget {
  const RouteManagementPage({super.key});

  @override
  State<RouteManagementPage> createState() => _RouteManagementPageState();
}

class _RouteManagementPageState extends State<RouteManagementPage> {
  final LocationTrackingService _trackingService = LocationTrackingService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _routeNameController = TextEditingController();
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();
  final _durationController = TextEditingController();
  final _stopsController = TextEditingController();

  List<BusRoute> _routes = [];
  List<String> _stops = [];
  List<String> _selectedBuses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('routes').get();
      final routes = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Extract waypoints as stops
        final waypoints = data['waypoints'] as List<dynamic>? ?? [];
        final stops = waypoints
            .map((wp) => (wp as Map<String, dynamic>)['location'] as String? ?? '')
            .where((stop) => stop.isNotEmpty)
            .toList();
        
        return BusRoute(
          routeId: doc.id,
          routeName: data['routeName'] ?? '',
          departurePlace: data['departureFrom'] ?? '',
          arrivalPlace: data['arrivalAt'] ?? '',
          departureTime: data['departureTime'] ?? '',
          arrivalTime: data['arrivalTime'] ?? '',
          stops: stops,
          estimatedDurationMinutes: _calculateDuration(
            data['departureTime'] ?? '',
            data['arrivalTime'] ?? '',
          ),
          assignedBuses: data['busNumber'] != null ? [data['busNumber'].toString()] : [],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      setState(() => _routes = routes);
      print('✓ Loaded ${routes.length} routes from Firebase');
    } catch (e) {
      print('Error loading routes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading routes: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _calculateDuration(String departureTime, String arrivalTime) {
    try {
      final depParts = departureTime.split(':');
      final arrParts = arrivalTime.split(':');
      
      final depMinutes = int.parse(depParts[0]) * 60 + int.parse(depParts[1]);
      final arrMinutes = int.parse(arrParts[0]) * 60 + int.parse(arrParts[1]);
      
      int duration = arrMinutes - depMinutes;
      if (duration < 0) {
        duration += 24 * 60; // Add 24 hours if arrival is next day
      }
      return duration;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _createRoute() async {
    if (_routeNameController.text.isEmpty ||
        _departureController.text.isEmpty ||
        _arrivalController.text.isEmpty ||
        _departureTimeController.text.isEmpty ||
        _arrivalTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final waypoints = _stops
          .map((stop) => {
                'location': stop,
                'latitude': 0.0,
                'longitude': 0.0,
              })
          .toList();

      // Save to Firebase with new structure
      await _firestore.collection('routes').add({
        'routeName': _routeNameController.text,
        'departureFrom': _departureController.text,
        'arrivalAt': _arrivalController.text,
        'departureTime': _departureTimeController.text,
        'arrivalTime': _arrivalTimeController.text,
        'departureLatitude': 0.0,
        'departureLongitude': 0.0,
        'arrivalLatitude': 0.0,
        'arrivalLongitude': 0.0,
        'busNumber': _selectedBuses.isNotEmpty ? _selectedBuses[0] : '',
        'routeType': 'custom',
        'waypoints': waypoints,
        'createdAt': Timestamp.now(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Route created successfully'), backgroundColor: Colors.green),
      );

      // Clear form
      _clearForm();
      await _loadRoutes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating route: $e')),
      );
    }
  }

  void _clearForm() {
    _routeNameController.clear();
    _departureController.clear();
    _arrivalController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
    _durationController.clear();
    _stopsController.clear();
    setState(() {
      _stops = [];
      _selectedBuses = [];
    });
  }

  Future<void> _deleteRoute(String routeId) async {
    try {
      await _firestore.collection('routes').doc(routeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Route deleted'), backgroundColor: Colors.green),
      );
      await _loadRoutes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting route: $e')),
      );
    }
  }

  void _showTimePickerDialog(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _durationController.dispose();
    _stopsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Management',
              style: TextStyle(
                color: const Color(0xFF18181B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Create and manage bus routes',
              style: TextStyle(
                color: const Color(0xFF71717A),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF18181B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create New Route Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Route',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_routeNameController, 'Route Name (e.g., Morning Express)'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(_departureController, 'Departure Place'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(_arrivalController, 'Arrival Place'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showTimePickerDialog(_departureTimeController),
                                child: _buildTextField(
                                  _departureTimeController,
                                  'Departure Time',
                                  readOnly: true,
                                  suffixIcon: Icons.access_time,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showTimePickerDialog(_arrivalTimeController),
                                child: _buildTextField(
                                  _arrivalTimeController,
                                  'Arrival Time',
                                  readOnly: true,
                                  suffixIcon: Icons.access_time,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _durationController,
                          'Estimated Duration (minutes)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        // Add stops
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _stopsController,
                                'Add Stop',
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_stopsController.text.isNotEmpty) {
                                  setState(() {
                                    _stops.add(_stopsController.text);
                                    _stopsController.clear();
                                  });
                                }
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF18181B),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Display stops
                        if (_stops.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: _stops
                                .map(
                                  (stop) => Chip(
                                    label: Text(stop, style: const TextStyle(fontSize: 12)),
                                    onDeleted: () {
                                      setState(() => _stops.remove(stop));
                                    },
                                    backgroundColor: const Color(0xFF18181B).withOpacity(0.1),
                                    labelStyle: const TextStyle(color: Color(0xFF18181B)),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 16),
                        // Create button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _createRoute,
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text('Create Route'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF18181B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Routes List
                  Text(
                    'Active Routes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _routes.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4E4E7)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.route,
                                  size: 48,
                                  color: const Color(0xFF71717A),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No routes created yet',
                                  style: TextStyle(
                                    color: const Color(0xFF71717A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: _routes
                              .map((route) => _buildRouteCard(route))
                              .toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildRouteCard(BusRoute route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.routeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: const Color(0xFF71717A)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${route.departurePlace} → ${route.arrivalPlace}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF71717A),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteRoute(route.routeId),
                icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE4E4E7), height: 1),
          const SizedBox(height: 12),
          
          // Time Info
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: const Color(0xFF18181B)),
              const SizedBox(width: 6),
              Text(
                'Depart: ${route.departureTime}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.flag, size: 16, color: const Color(0xFF18181B)),
              const SizedBox(width: 6),
              Text(
                'Arrive: ${route.arrivalTime}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF18181B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: const Color(0xFF71717A)),
              const SizedBox(width: 6),
              Text(
                'Duration: ${route.estimatedDurationMinutes} minutes',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF71717A),
                ),
              ),
            ],
          ),
          
          // Stops/Waypoints
          if (route.stops.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Waypoints',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF71717A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: route.stops
                  .map(
                    (stop) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 10, color: const Color(0xFF18181B)),
                          const SizedBox(width: 3),
                          Text(
                            stop,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF18181B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          
          // Bus Number
          if (route.assignedBuses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_bus, size: 16, color: const Color(0xFF18181B)),
                  const SizedBox(width: 8),
                  Text(
                    'Bus #${route.assignedBuses.join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF18181B), width: 2),
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
