import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Bus #${widget.bus.busNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Map Section
            Container(
              height: 260,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: departureLocation,
                    zoom: 13.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    setState(() => _mapController = controller);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('departure'),
                      position: departureLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: const InfoWindow(title: 'Departure'),
                    ),
                    Marker(
                      markerId: const MarkerId('arrival'),
                      position: arrivalLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: const InfoWindow(title: 'Arrival'),
                    ),
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Bus Info
                  _buildDetailCard(
                    icon: Icons.directions_bus_outlined,
                    label: 'Bus Number',
                    value: widget.bus.busNumber,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    icon: Icons.route_outlined,
                    label: 'Route',
                    value: '${widget.bus.departureLocation} → ${widget.bus.arrivalLocation}',
                  ),

                  const SizedBox(height: 16),
                  Divider(color: const Color(0xFFE4E4E7), height: 1),
                  const SizedBox(height: 16),

                  // Location Info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: const Color(0xFF16A34A),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Departure',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.bus.departureLocation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.bus.departureLatitude.toStringAsFixed(4)}, ${widget.bus.departureLongitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: const Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Arrival',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.bus.arrivalLocation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.bus.arrivalLatitude.toStringAsFixed(4)}, ${widget.bus.arrivalLongitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: const Color(0xFFE4E4E7), height: 1),
                  const SizedBox(height: 16),

                  // Driver Info
                  _buildDetailCard(
                    icon: Icons.person_outline,
                    label: 'Driver Name',
                    value: widget.bus.driverName,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    icon: Icons.phone_outlined,
                    label: 'Driver Phone',
                    value: widget.bus.driverPhone,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: const Color(0xFFE4E4E7), height: 1),
                  const SizedBox(height: 16),

                  // Vehicle Info
                  _buildDetailCard(
                    icon: Icons.local_shipping_outlined,
                    label: 'Vehicle Number',
                    value: widget.bus.vehicleNumber,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: widget.bus.status.toUpperCase(),
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
                    backgroundColor: const Color(0xFF18181B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF71717A), size: 18),
          const SizedBox(width: 12),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF18181B),
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
