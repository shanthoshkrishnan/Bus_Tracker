import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/location_service.dart';
import '../services/firebase_service.dart';
import '../models/bus_model.dart';
import '../pages/profile_page.dart';
import '../pages/admin_page.dart';
import '../widgets/bus_card.dart';

class HomePage extends StatefulWidget {
  final String userRole;
  final String userName;
  final String userEmail;
  final String? userId;

  const HomePage({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
    this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();
  final MapController _mapController = MapController();
  
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _locationError = false;
  List<BusModel> _studentBuses = [];
  bool _isLoadingBuses = false;
  List<Map<String, dynamic>> _nearbyBuses = [];
  bool _isLoadingNearbyBuses = false;
  String _userId = '';
  late DateTime _currentDateTime;
  late Timer _timer;
  bool _profileIncomplete = false;
  Map<String, dynamic> _userData = {};
  List<Map<String, dynamic>> _pendingNotifications = [];
  bool _isLoadingNotifications = false;

  @override
  void initState() {
    super.initState();
    // Initialize userId from widget or Firebase Auth
    _userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Initialize date and time
    _currentDateTime = DateTime.now();
    _startTimer();
    
    // Debug logging
    print('=== HomePage Initialize ===');
    print('Widget userId: ${widget.userId}');
    print('Firebase Auth uid: ${FirebaseAuth.instance.currentUser?.uid}');
    print('Final _userId: $_userId');
    print('User Role: ${widget.userRole}');
    print('===========================');
    
    _getCurrentLocation();
    _checkProfileCompletion();
    if (widget.userRole.toLowerCase() == 'student' && _userId.isNotEmpty) {
      _loadStudentBuses();
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    if (_userId.isEmpty) return;
    
    setState(() => _isLoadingNotifications = true);
    try {
      final notifications = await _firebaseService.getPendingNotifications(_userId);
      if (mounted) {
        setState(() {
          _pendingNotifications = notifications;
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() => _isLoadingNotifications = false);
      }
    }
  }

  Future<void> _checkProfileCompletion() async {
    if (_userId.isEmpty) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userData = data;
        
        // Check role-specific required fields
        final role = widget.userRole.toLowerCase();
        bool isIncomplete = false;
        
        // Common required fields
        if ((data['firstName'] ?? '').isEmpty ||
            (data['lastName'] ?? '').isEmpty ||
            (data['email'] ?? '').isEmpty) {
          isIncomplete = true;
        }
        
        // Student-specific required fields
        if (role == 'student') {
          if ((data['year'] ?? '').isEmpty ||
              (data['department'] ?? '').isEmpty ||
              (data['homeLocation'] ?? '').isEmpty) {
            isIncomplete = true;
          }
        }
        
        if (mounted) {
          setState(() {
            _profileIncomplete = isIncomplete;
          });
        }
      }
    } catch (e) {
      print('Error checking profile: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      }
    });
  }

  String _getFormattedDateTime() {
    final now = _currentDateTime;
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return '$dateStr | $timeStr';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadStudentBuses() async {
    if (_userId.isEmpty) return;
    
    setState(() => _isLoadingBuses = true);
    try {
      final buses = await _firebaseService.getBusesForStudent(_userId);
      if (mounted) {
        setState(() {
          _studentBuses = buses;
          _isLoadingBuses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBuses = false);
      }
      print('Error loading buses: $e');
    }
  }

  Future<void> _loadNearbyBuses() async {
    if (_currentLocation == null) {
      print('Current location not available');
      return;
    }

    setState(() => _isLoadingNearbyBuses = true);
    try {
      final nearbyBuses = await _firebaseService.getNearbyBuses(
        studentLat: _currentLocation!.latitude,
        studentLng: _currentLocation!.longitude,
        radiusKm: 5.0,
      );
      if (mounted) {
        setState(() {
          _nearbyBuses = nearbyBuses;
          _isLoadingNearbyBuses = false;
        });
      }
    } catch (e) {
      print('Error loading nearby buses: $e');
      if (mounted) {
        setState(() => _isLoadingNearbyBuses = false);
      }
    }
  }

  void _getCurrentLocation() async {
    try {
      LatLng? location = await _locationService.getCurrentLocation();
      
      if (mounted) {
        setState(() {
          if (location != null) {
            _currentLocation = location;
            _isLoadingLocation = false;
            // Animate map to current location
            _mapController.move(location, 16.0);
            
            // Load nearby buses for students
            if (widget.userRole.toLowerCase() == 'student') {
              _loadNearbyBuses();
            }
          } else {
            _locationError = true;
            _isLoadingLocation = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = true;
          _isLoadingLocation = false;
        });
      }
    }
  }

  String _getRoleColor() {
    switch (widget.userRole.toLowerCase()) {
      case 'student':
        return '🎓';
      case 'driver':
        return '🚌';
      case 'staff':
        return '👔';
      case 'worker':
        return '👷';
      case 'people':
        return '👥';
      case 'admin':
        return '👨‍💼';
      default:
        return '👤';
    }
  }

  Color _getRoleColorCode() {
    switch (widget.userRole.toLowerCase()) {
      case 'student':
        return const Color(0xFF4CAF50);
      case 'driver':
        return const Color(0xFF2196F3);
      case 'staff':
        return const Color(0xFF9C27B0);
      case 'worker':
        return const Color(0xFFFF9800);
      case 'people':
        return const Color(0xFF00BCD4);
      case 'admin':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF8B6F47);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B6F47),
        elevation: 0,
        title: const Text(
          'Bus Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Admin Button (visible only for admins)
          if (widget.userRole.toLowerCase() == 'admin')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings, size: 20),
                label: const Text('Assign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF44336),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          // Round Profile Button (Top Right)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                if (_userId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in first')),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userId: _userId,
                      userRole: widget.userRole,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: _getRoleColorCode(),
                  radius: 24,
                  child: Text(
                    _getRoleColor(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Real-time Date and Time Widget
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getRoleColorCode().withOpacity(0.9),
                    _getRoleColorCode().withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Bus Tracker System',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDateTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // User Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getRoleColorCode(),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          _getRoleColor(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C4A3D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.userEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7A6B60),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColorCode().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Role: ${widget.userRole}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColorCode(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userId: _userId,
                            userRole: widget.userRole,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _getRoleColorCode().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getRoleColorCode().withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'View Full Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColorCode(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Incomplete Warning Banner
            if (_profileIncomplete)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () {
                    if (_userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in first')),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userId: _userId,
                          userRole: widget.userRole,
                        ),
                      ),
                    ).then((_) {
                      _checkProfileCompletion();
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ Update Your Profile',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete your profile to unlock all features',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

            // Location Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _locationError
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _locationError
                        ? Colors.red.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _locationError
                          ? Icons.location_off
                          : Icons.location_on,
                      color:
                          _locationError ? Colors.red : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isLoadingLocation
                            ? 'Getting your location...'
                            : _locationError
                                ? 'Location access denied or error occurred'
                                : 'Location: ${_currentLocation?.latitude.toStringAsFixed(4)}, ${_currentLocation?.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: _locationError
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_isLoadingLocation)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF8B6F47)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Map Container
            Container(
              margin: const EdgeInsets.all(16),
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoadingLocation || _currentLocation == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_locationError)
                              Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Unable to Get Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please enable location services\nand grant permission',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _getCurrentLocation,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF8B6F47),
                                    ),
                                    child: const Text(
                                      'Try Again',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            else
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B6F47),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLocation!,
                          initialZoom: 16.0,
                          minZoom: 5,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.bus_tracker',
                            tileProvider: NetworkTileProvider(),
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLocation!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getRoleColorCode(),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B6F47),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_currentLocation != null) {
                          _mapController.move(_currentLocation!, 16.0);
                        }
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('Center Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Student Bus Section
            if (widget.userRole.toLowerCase() == 'student')
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.directions_bus,
                          color: Color(0xFF2196F3),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'My Buses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C4A3D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingBuses)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B6F47),
                          ),
                        ),
                      )
                    else if (_studentBuses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue[200]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_bus_filled,
                              size: 48,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Buses Assigned Yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Contact your administrator to assign a bus',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _studentBuses
                            .map((bus) => BusCard(bus: bus))
                            .toList(),
                      ),
                  ],
                ),
              ),

            // Nearby Buses Section
            if (widget.userRole.toLowerCase() == 'student' && _currentLocation != null)
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF4CAF50),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Buses Near You (5 km radius)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5C4A3D),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _loadNearbyBuses,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingNearbyBuses)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B6F47),
                            ),
                          ),
                        ),
                      )
                    else if (_nearbyBuses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange[200]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: Colors.orange[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Buses Nearby',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No buses are within 5 km radius of your location',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _nearbyBuses.asMap().entries.map((entry) {
                          final bus = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Bus #${bus['busNumber']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2196F3).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF2196F3),
                                          ),
                                        ),
                                        child: Text(
                                          '${bus['distance']} km away',
                                          style: const TextStyle(
                                            color: Color(0xFF2196F3),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.route,
                                        color: Color(0xFF5C4A3D),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          bus['busRoute'] ?? 'Unknown Route',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF5C4A3D),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Color(0xFF5C4A3D),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Driver: ${bus['driverName'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF5C4A3D),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: bus['status'] == 'active'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          bus['status'] == 'active' ? '● Active' : '● Inactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: bus['status'] == 'active'
                                                ? Colors.green[700]
                                                : Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (double.tryParse(bus['distance'] ?? '0') != null &&
                                          double.parse(bus['distance']) <= 2)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF9800).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.notifications_active,
                                                size: 12,
                                                color: Color(0xFFFF9800),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Approaching',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFFF9800),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
