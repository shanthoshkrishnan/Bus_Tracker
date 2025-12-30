import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../pages/bus_details_popup.dart';

class BusCard extends StatelessWidget {
  final BusModel bus;

  const BusCard({
    super.key,
    required this.bus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => BusDetailsPopup(bus: bus),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[400]!,
              Colors.blue[600]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚌 Bus Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bus #${bus.busNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[200],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bus.status == 'active'
                          ? Colors.green
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bus.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route
                  _buildInfoRow(
                    icon: Icons.route,
                    label: 'Route',
                    value:
                        '${bus.departureLocation} → ${bus.arrivalLocation}',
                  ),
                  const SizedBox(height: 8),

                  // Driver
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Driver',
                    value: bus.driverName,
                  ),
                  const SizedBox(height: 8),

                  // Phone
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: bus.driverPhone,
                  ),
                  const SizedBox(height: 8),

                  // Vehicle Number
                  _buildInfoRow(
                    icon: Icons.confirmation_number,
                    label: 'Vehicle #',
                    value: bus.vehicleNumber,
                  ),

                  const SizedBox(height: 12),

                  // Tap for details button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap for full details & map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[100],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
