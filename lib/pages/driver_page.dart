import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../services/firebase_service.dart';

// Route 68 CHENGALPET - Stops data
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

class _DriverPageState extends State<DriverPage>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Map<String, dynamic>?> _assignedBusFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _assignedBusFuture = _firebaseService.getDriverAssignedBus(
      widget.driverEmail,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF18181B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Assignment',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _assignedBusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF18181B),
                ),
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
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: const Color(0xFFEF4444),
                    ),
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
                      style: TextStyle(
                        color: const Color(0xFF71717A),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _assignedBusFuture = _firebaseService
                              .getDriverAssignedBus(widget.driverEmail);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18181B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final busData = snapshot.data;
          final isAssigned =
              busData != null &&
              (busData['busNumber'] != null &&
                  busData['busNumber'] != 'Not Assigned');

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_outline,
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
                                widget.driverName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Driver',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF71717A),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.driverEmail,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF71717A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Badge
                  if (isAssigned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: const Color(0xFF16A34A),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Assignment',
                                  style: TextStyle(
                                    color: const Color(0xFF16A34A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'You have a bus assigned',
                                  style: TextStyle(
                                    color: const Color(0xFF16A34A),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFFCA8A04),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No Assignment',
                                  style: TextStyle(
                                    color: const Color(0xFFCA8A04),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Waiting for admin to assign a bus',
                                  style: TextStyle(
                                    color: const Color(0xFFCA8A04),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Section Title
                  Text(
                    'Bus Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bus Details or Empty State
                  if (isAssigned)
                    Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.directions_bus_outlined,
                          label: 'Bus Number',
                          value: busData['busNumber'] ?? 'N/A',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.route_outlined,
                          label: 'Route',
                          value: busData['busRoute'] ?? 'N/A',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Vehicle Number',
                          value: busData['vehicleNumber'] ?? 'N/A',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _RouteDetailsModal(
                                busNumber: busData['busNumber'] ?? 'N/A',
                                busRoute: busData['busRoute'] ?? 'Route 68',
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF18181B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text(
                            'View Full Route',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.directions_bus_outlined,
                              size: 32,
                              color: const Color(0xFFA1A1AA),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Vehicle Assigned',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF18181B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please wait for the admin to assign you a bus',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF71717A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF18181B)),
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
                    color: const Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF18181B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteDetailsModal extends StatefulWidget {
  final String busNumber;
  final String busRoute;

  const _RouteDetailsModal({required this.busNumber, required this.busRoute});

  @override
  State<_RouteDetailsModal> createState() => _RouteDetailsModalState();
}

class _RouteDetailsModalState extends State<_RouteDetailsModal>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _showFullMap = false;
  late List<Map<String, dynamic>> _currentStops;
  late AnimationController _animationController;
  late LatLng _firstStopLocation;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentStops = now.hour < 12 ? morningStops : eveningStops;

    // Initialize first stop position
    try {
      final firstStop = _currentStops[0];
      _firstStopLocation = LatLng(
        double.parse(firstStop['latitude'].toString()),
        double.parse(firstStop['longitude'].toString()),
      );
    } catch (e) {
      _firstStopLocation = const LatLng(12.6069, 80.0588);
    }

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMapMarkers() {
    Set<Marker> markers = {};

    // Add markers for all stops (red for others, green for first)
    for (int i = 0; i < _currentStops.length; i++) {
      final stop = _currentStops[i];
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(
            double.parse(stop['latitude'].toString()),
            double.parse(stop['longitude'].toString()),
          ),
          infoWindow: InfoWindow(
            title: stop['name'],
            snippet: '${stop['time']} - ${stop['distance']} km',
          ),
          icon: i == 0
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    Set<Polyline> polylines = {};

    List<LatLng> polylinePoints = [];
    for (var stop in _currentStops) {
      polylinePoints.add(
        LatLng(
          double.parse(stop['latitude'].toString()),
          double.parse(stop['longitude'].toString()),
        ),
      );
    }

    // Add intermediate waypoints for realistic curves
    List<LatLng> smoothedPoints = [];
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      smoothedPoints.add(polylinePoints[i]);

      final current = polylinePoints[i];
      final next = polylinePoints[i + 1];

      // Add 4 intermediate points between each stop for smooth curves
      for (int j = 1; j <= 4; j++) {
        final latDiff = next.latitude - current.latitude;
        final lonDiff = next.longitude - current.longitude;
        final curveOffset = 0.0008 * (2 - (j / 4).abs() * 2);

        smoothedPoints.add(
          LatLng(
            current.latitude + latDiff * (j / 5) + curveOffset,
            current.longitude + lonDiff * (j / 5) + curveOffset,
          ),
        );
      }
    }
    smoothedPoints.add(polylinePoints.last);

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: smoothedPoints,
        color: const Color(0xFF18181B),
        width: 5,
      ),
    );

    return polylines;
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _firstStopLocation,
                    zoom: 13,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _buildMapMarkers(),
                  polylines: _buildPolylines(),
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                ),
              ),
              SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    'Bus ${widget.busNumber}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF18181B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.busRoute,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(Icons.map, size: 16),
                              label: const Text('Expand'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Route Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _currentStops.length,
                          itemBuilder: (context, index) {
                            final stop = _currentStops[index];
                            final isFirst = index == 0;
                            final isLast = index == _currentStops.length - 1;

                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isFirst
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF18181B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE4E4E7),
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 60,
                                            color: const Color(0xFFE4E4E7),
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 4,
                                          bottom: isLast ? 0 : 60,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              stop['name'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF18181B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  size: 14,
                                                  color: const Color(
                                                    0xFF71717A,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  stop['time'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: const Color(
                                                      0xFF71717A,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: const Color(
                                                    0xFF71717A,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${stop['distance']} km',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: const Color(
                                                      0xFF71717A,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildFullMapView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF18181B)),
          onPressed: () {
            setState(() => _showFullMap = false);
          },
        ),
        title: Text(
          'Route Map - Bus ${widget.busNumber}',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _firstStopLocation,
          zoom: 13,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _buildMapMarkers(),
        polylines: _buildPolylines(),
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }
}
