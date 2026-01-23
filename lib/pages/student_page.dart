import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/location_service.dart';
import '../services/firebase_service.dart';
import '../pages/profile_page.dart';
import '../pages/bus_seat_selection_page.dart';

// Route 68 CHENGALPET - Actual stops data with realistic road coordinates
final List<Map<String, dynamic>> morningStops = [
  {
    'name': 'Government Hospital',
    'latitude': 12.6069,
    'longitude': 80.0588,
    'time': '05:55',
    'distance': 0,
  },
  {
    'name': 'Rattina Kinaru',
    'latitude': 12.6100,
    'longitude': 80.0610,
    'time': '06:00',
    'distance': 1,
  },
  {
    'name': 'Bus Stand',
    'latitude': 12.6872,
    'longitude': 79.9810,
    'time': '06:05',
    'distance': 2,
  },
  {
    'name': 'Iyyappan Kovil',
    'latitude': 12.6950,
    'longitude': 79.9750,
    'time': '06:10',
    'distance': 3,
  },
  {
    'name': 'Mahendra City',
    'latitude': 12.7425,
    'longitude': 79.9960,
    'time': '06:15',
    'distance': 5,
  },
  {
    'name': 'Singaperumal Koil',
    'latitude': 12.7813,
    'longitude': 80.0404,
    'time': '06:20',
    'distance': 7,
  },
  {
    'name': 'Maraimalai Nagar',
    'latitude': 12.7710,
    'longitude': 80.0400,
    'time': '06:25',
    'distance': 10,
  },
  {
    'name': 'Kattankulathur',
    'latitude': 12.7860,
    'longitude': 80.0446,
    'time': '06:25',
    'distance': 12,
  },
  {
    'name': 'SRM',
    'latitude': 12.8200,
    'longitude': 80.0450,
    'time': '06:30',
    'distance': 15,
  },
  {
    'name': 'Guduvanchery',
    'latitude': 12.7886,
    'longitude': 80.0340,
    'time': '06:35',
    'distance': 18,
  },
  {
    'name': 'Urapakkam',
    'latitude': 12.8700,
    'longitude': 80.0600,
    'time': '06:40',
    'distance': 22,
  },
  {
    'name': 'Vandalur',
    'latitude': 12.9424,
    'longitude': 80.1306,
    'time': '06:45',
    'distance': 25,
  },
  {
    'name': 'Mannivakkam',
    'latitude': 12.9300,
    'longitude': 80.1200,
    'time': '06:50',
    'distance': 27,
  },
  {
    'name': 'Panimalar Engineering College',
    'latitude': 13.050333,
    'longitude': 80.072333,
    'time': '07:15',
    'distance': 30,
  },
];

final List<Map<String, dynamic>> eveningStops = [
  {
    'name': 'Panimalar Engineering College',
    'latitude': 13.050333,
    'longitude': 80.072333,
    'time': '15:07',
    'distance': 0,
  },
  {
    'name': 'Mannivakkam',
    'latitude': 12.9300,
    'longitude': 80.1200,
    'time': '15:25',
    'distance': 3,
  },
  {
    'name': 'Vandalur',
    'latitude': 12.9424,
    'longitude': 80.1306,
    'time': '15:35',
    'distance': 5,
  },
  {
    'name': 'Urapakkam',
    'latitude': 12.8700,
    'longitude': 80.0600,
    'time': '15:40',
    'distance': 8,
  },
  {
    'name': 'Guduvanchery',
    'latitude': 12.7886,
    'longitude': 80.0340,
    'time': '15:45',
    'distance': 12,
  },
  {
    'name': 'SRM',
    'latitude': 12.8200,
    'longitude': 80.0450,
    'time': '15:50',
    'distance': 15,
  },
  {
    'name': 'Kattankulathur',
    'latitude': 12.7860,
    'longitude': 80.0446,
    'time': '15:55',
    'distance': 17,
  },
  {
    'name': 'Maraimalai Nagar',
    'latitude': 12.7710,
    'longitude': 80.0400,
    'time': '16:00',
    'distance': 20,
  },
  {
    'name': 'Singaperumal Koil',
    'latitude': 12.7813,
    'longitude': 80.0404,
    'time': '16:05',
    'distance': 23,
  },
  {
    'name': 'Mahendra City',
    'latitude': 12.7425,
    'longitude': 79.9960,
    'time': '16:10',
    'distance': 25,
  },
  {
    'name': 'Iyyappan Kovil',
    'latitude': 12.6950,
    'longitude': 79.9750,
    'time': '16:15',
    'distance': 27,
  },
  {
    'name': 'Bus Stand',
    'latitude': 12.6872,
    'longitude': 79.9810,
    'time': '16:20',
    'distance': 28,
  },
  {
    'name': 'Rattina Kinaru',
    'latitude': 12.6100,
    'longitude': 80.0610,
    'time': '16:25',
    'distance': 29,
  },
  {
    'name': 'Government Hospital',
    'latitude': 12.6069,
    'longitude': 80.0588,
    'time': '16:30',
    'distance': 30,
  },
];

class StudentPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? userId;

  const StudentPage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userId,
  });

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final FirebaseService _firebaseService = FirebaseService();
  
  late Future<List<dynamic>> _busesFuture;
  String _userId = '';
  late String _userName;
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _busesFuture = _firebaseService.getAllBuses();
  }

  void _showBusDetailsModal(BuildContext context, dynamic bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BusDetailsModal(bus: bus),
    );
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
              'Hello, ${_userName.split(' ').first}',
              style: TextStyle(
                color: const Color(0xFF18181B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Find your bus',
              style: TextStyle(
                color: const Color(0xFF71717A),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: const Color(0xFF18181B)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: _userId,
                    userRole: 'student',
                    userName: _userName,
                    userEmail: _userEmail,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: const Color(0xFF18181B)),
            onPressed: () {
              setState(() {
                _busesFuture = _firebaseService.getAllBuses();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _busesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF18181B)),
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: const Color(0xFFEF4444)),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: const Color(0xFF71717A), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _busesFuture = _firebaseService.getAllBuses();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18181B),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final buses = snapshot.data ?? [];

          if (buses.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.directions_bus_outlined,
                        size: 40,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Buses Available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for bus updates',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _busesFuture = _firebaseService.getAllBuses();
              });
            },
            color: const Color(0xFF18181B),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: buses.length,
              itemBuilder: (context, index) {
                final bus = buses[index];
                return _buildSimpleBusCard(context, bus);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleBusCard(BuildContext context, dynamic bus) {
    String busNumber = bus.busNumber ?? 'N/A';
    String busRoute = bus.busRoute ?? 'Route 68 Chengalpet';
    String driverName = bus.driverName ?? 'Driver';
    String status = bus.status ?? 'inactive';
    
    return GestureDetector(
      onTap: () => _showBusDetailsModal(context, bus),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
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
            // Header with bus number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus $busNumber',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        busRoute,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF71717A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'active' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'active' ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: status == 'active' ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Driver info
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: const Color(0xFF71717A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    driverName,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF18181B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tap for details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.my_location, size: 16, color: const Color(0xFF18181B)),
                  const SizedBox(width: 8),
                  Text(
                    'View Live Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusDetailsModal extends StatefulWidget {
  final dynamic bus;

  const _BusDetailsModal({required this.bus});

  @override
  State<_BusDetailsModal> createState() => _BusDetailsModalState();
}

class _BusDetailsModalState extends State<_BusDetailsModal> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _showFullMap = false;
  List<Map<String, dynamic>> _currentStops = morningStops;
  late AnimationController _animationController;
  late LatLng _currentBusLocation;
  late LatLng _userLocation; // User's actual GPS location
  int _nextStopIndex = 0;
  late Timer _locationUpdateTimer;
  bool _hasShownUrapakkamNotification = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentStops = now.hour < 12 ? morningStops : eveningStops;
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Initialize with first stop as default
    _currentBusLocation = LatLng(
      _currentStops[0]['latitude'] as double,
      _currentStops[0]['longitude'] as double,
    );
    
    // Fetch user's actual GPS location
    _fetchUserLocation();
    _startLiveLocationUpdate();
    _checkForNotifications();
  }

  Future<void> _fetchUserLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          
          // Animate camera to user's location
          if (_mapController != null) {
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _userLocation,
                  zoom: 15,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Error fetching user location: $e');
      // Fall back to first stop if location fetch fails
      _userLocation = LatLng(
        _currentStops[0]['latitude'] as double,
        _currentStops[0]['longitude'] as double,
      );
    }
  }

  void _startLiveLocationUpdate() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _updateBusLocation();
          _checkForNotifications();
        });
      }
    });
  }

  void _updateBusLocation() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    final firstStopTime = _timeStringToMinutes(_currentStops[0]['time']);
    final lastStopTime = _timeStringToMinutes(_currentStops[_currentStops.length - 1]['time']);
    
    // If before first stop, show at first stop
    if (currentMinutes < firstStopTime) {
      _nextStopIndex = 0;
      _currentBusLocation = LatLng(
        _currentStops[0]['latitude'] as double,
        _currentStops[0]['longitude'] as double,
      );
    }
    // If after last stop, show at last stop
    else if (currentMinutes >= lastStopTime) {
      _nextStopIndex = _currentStops.length - 1;
      _currentBusLocation = LatLng(
        _currentStops[_currentStops.length - 1]['latitude'],
        _currentStops[_currentStops.length - 1]['longitude'],
      );
    }
    // Find which segment the bus is on
    else {
      for (int i = 0; i < _currentStops.length - 1; i++) {
        final stop1 = _currentStops[i];
        final stop2 = _currentStops[i + 1];
        
        final time1 = _timeStringToMinutes(stop1['time']);
        final time2 = _timeStringToMinutes(stop2['time']);
        
        if (currentMinutes >= time1 && currentMinutes < time2) {
          _nextStopIndex = i + 1;
          
          // Interpolate location between two stops
          final progress = (currentMinutes - time1) / (time2 - time1);
          final lat1Double = stop1['latitude'] as double;
          final lat2Double = stop2['latitude'] as double;
          final lng1Double = stop1['longitude'] as double;
          final lng2Double = stop2['longitude'] as double;
          final lat = lat1Double + (lat2Double - lat1Double) * progress;
          final lng = lng1Double + (lng2Double - lng1Double) * progress;
          
          _currentBusLocation = LatLng(lat, lng);
          break;
        }
      }
    }
    
    // Always animate camera to follow current bus location
    if (_mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentBusLocation,
            zoom: 14,
          ),
        ),
      );
    }
  }

  int _timeStringToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _checkForNotifications() {
    // Show notification when bus reaches Urapakkam
    if (_nextStopIndex >= 10 && !_hasShownUrapakkamNotification) {
      _hasShownUrapakkamNotification = true;
      _showBusNotification(
        'Bus Arrived at Urapakkam',
        'Your bus (Bus ${widget.bus.busNumber}) has reached Urapakkam. Next stop: Vandalur',
      );
    }
  }

  void _showBusNotification(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bus_alert, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFE4E4E7),
                          fontSize: 12,
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
  }

  @override
  Widget build(BuildContext context) {
    if (_showFullMap) {
      return _buildFullMapView();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              // Map view at bottom (half view)
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _buildMapMarkers(),
                  polylines: _buildPolylines(),
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              // Content overlay
              SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E4E7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bus ${widget.bus.busNumber}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF18181B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.bus.busRoute ?? 'Route',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _showFullMap = true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF18181B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              icon: Icon(Icons.map, size: 16),
                              label: const Text('Map'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Driver info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE4E4E7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, size: 20, color: const Color(0xFF18181B)),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Driver: ${widget.bus.driverName ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF18181B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 20, color: const Color(0xFF18181B)),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Phone: ${widget.bus.driverPhone ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF18181B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.directions_car, size: 20, color: const Color(0xFF18181B)),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Vehicle: ${widget.bus.vehicleNumber ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF18181B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Stops header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Stops',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Stops list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _currentStops.map((stop) {
                            int index = _currentStops.indexOf(stop);
                            return _buildStopItem(stop, index);
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Seat Selection Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF18181B),
                                const Color(0xFF18181B).withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BusSeatSelectionPage(
                                      busNumber: widget.bus.busNumber ?? 'N/A',
                                      busRoute: widget.bus.busRoute ?? 'Route',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_seat,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Select Seats',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStopItem(Map<String, dynamic> stop, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (index < _currentStops.length - 1)
                Container(
                  width: 2,
                  height: 50,
                  color: const Color(0xFFE4E4E7),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Stop details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop['name'] ?? 'Stop',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: const Color(0xFF71717A)),
                    const SizedBox(width: 6),
                    Text(
                      stop['time'] ?? '00:00',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 16, color: const Color(0xFF71717A)),
                    const SizedBox(width: 6),
                    Text(
                      '${stop['distance']}km',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMapView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Bus ${widget.bus.busNumber} Route'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showFullMap = false),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _userLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _buildMapMarkers(),
        polylines: _buildPolylines(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};
    
    // User's actual location - LIVE LOCATION with "You are here" tag
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation,
        infoWindow: const InfoWindow(
          title: 'You are here',
          snippet: 'Your current location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add stop markers
    for (var stop in _currentStops) {
      markers.add(
        Marker(
          markerId: MarkerId(stop['name']),
          position: LatLng(stop['latitude'] as double, stop['longitude'] as double),
          infoWindow: InfoWindow(
            title: stop['name'],
            snippet: 'Time: ${stop['time']} | Distance: ${stop['distance']}km',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    // Create realistic route polyline with enhanced intermediate waypoints
    final List<LatLng> routePoints = [];
    
    // Add all stop locations
    for (var stop in _currentStops) {
      routePoints.add(LatLng(stop['latitude'] as double, stop['longitude'] as double));
    }
    
    // Add more intermediate waypoints for smoother, more accurate road-like curves
    final List<LatLng> detailedRoute = [];
    
    for (int i = 0; i < routePoints.length - 1; i++) {
      detailedRoute.add(routePoints[i]);
      
      // Add intermediate waypoints between stops for smooth curved roads
      final lat1 = routePoints[i].latitude;
      final lng1 = routePoints[i].longitude;
      final lat2 = routePoints[i + 1].latitude;
      final lng2 = routePoints[i + 1].longitude;
      
      // Create 4-5 intermediate points for much smoother curves
      // This makes the polyline follow more naturally
      for (double t = 0.2; t < 1.0; t += 0.2) {
        // Linear interpolation between two stops
        final midLat = lat1 + (lat2 - lat1) * t;
        final midLng = lng1 + (lng2 - lng1) * t;
        
        // Add curve variations to simulate realistic road bends
        // Using Bezier-like curve function for smoother paths
        final curveVariation = 0.0008 * (t - 0.5) * (t - 0.5) * (1 - t);
        detailedRoute.add(LatLng(
          midLat + curveVariation,
          midLng - curveVariation, // Alternate direction for natural curves
        ));
      }
    }
    
    // Add the final point
    detailedRoute.add(routePoints.last);
    
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: detailedRoute,
        color: const Color(0xFF18181B),
        width: 5,
        geodesic: false,
      ),
    };
  }

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
