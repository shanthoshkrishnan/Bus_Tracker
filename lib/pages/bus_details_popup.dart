import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';

class BusDetailsPopup extends StatefulWidget {
  final BusModel bus;

  const BusDetailsPopup({
    super.key,
    required this.bus,
  });

  @override
  State<BusDetailsPopup> createState() => _BusDetailsPopupState();
}

class _BusDetailsPopupState extends State<BusDetailsPopup> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final departureLocation = LatLng(
      widget.bus.departureLatitude,
      widget.bus.departureLongitude,
    );
    final arrivalLocation = LatLng(
      widget.bus.arrivalLatitude,
      widget.bus.arrivalLongitude,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚌 Bus Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bus #${widget.bus.busNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Map Section
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: departureLocation,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.bus_tracker',
                  ),
                  MarkerLayer(
                    markers: [
                      // Departure marker
                      Marker(
                        point: departureLocation,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Arrival marker
                      Marker(
                        point: arrivalLocation,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Bus Information
                  _buildDetailCard(
                    icon: Icons.directions_bus,
                    label: 'Bus Number',
                    value: widget.bus.busNumber,
                    color: const Color(0xFF2196F3),
                  ),
                  _buildDetailCard(
                    icon: Icons.route,
                    label: 'Route',
                    value:
                        '${widget.bus.departureLocation} → ${widget.bus.arrivalLocation}',
                    color: const Color(0xFF2196F3),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Location Information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📍 Departure',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.bus.departureLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.bus.departureLatitude.toStringAsFixed(4)}, ${widget.bus.departureLongitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎯 Arrival',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.bus.arrivalLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.bus.arrivalLatitude.toStringAsFixed(4)}, ${widget.bus.arrivalLongitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Driver Information
                  _buildDetailCard(
                    icon: Icons.person,
                    label: 'Driver Name',
                    value: widget.bus.driverName,
                    color: const Color(0xFF9C27B0),
                  ),
                  _buildDetailCard(
                    icon: Icons.phone,
                    label: 'Driver Phone',
                    value: widget.bus.driverPhone,
                    color: const Color(0xFF9C27B0),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Vehicle Information
                  _buildDetailCard(
                    icon: Icons.confirmation_number,
                    label: 'Vehicle Number (Plate)',
                    value: widget.bus.vehicleNumber,
                    color: const Color(0xFFFF9800),
                  ),
                  _buildDetailCard(
                    icon: Icons.info,
                    label: 'Status',
                    value: widget.bus.status.toUpperCase(),
                    color: widget.bus.status == 'active'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                ],
              ),
            ),

            // Close Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B6F47),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
