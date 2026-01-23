// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';

class BusSeatSelectionPage extends StatefulWidget {
  final String busNumber;
  final String busRoute;
  final VoidCallback? onSeatsSelected;

  const BusSeatSelectionPage({
    super.key,
    required this.busNumber,
    required this.busRoute,
    this.onSeatsSelected,
  });

  @override
  State<BusSeatSelectionPage> createState() => _BusSeatSelectionPageState();
}

class _BusSeatSelectionPageState extends State<BusSeatSelectionPage> {
  late List<SeatStatus> seats;
  List<int> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    // 22 seats total (2 columns x 11 rows)
    seats = List.generate(22, (index) {
      // Mark some seats as occupied for demo
      if ([2, 5, 8, 10, 15, 19].contains(index)) {
        return SeatStatus.occupied;
      }
      return SeatStatus.available;
    });
  }

  void _toggleSeat(int index) {
    if (seats[index] == SeatStatus.occupied) return;

    setState(() {
      if (seats[index] == SeatStatus.selected) {
        seats[index] = SeatStatus.available;
        selectedSeats.remove(index);
      } else {
        seats[index] = SeatStatus.selected;
        selectedSeats.add(index);
      }
    });
  }

  String _getSeatNumber(int index) {
    int row = (index ~/ 2) + 1;
    int col = (index % 2) + 1;
    return '$row${col == 1 ? 'A' : 'B'}';
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
              'Select Seats',
              style: TextStyle(
                color: const Color(0xFF18181B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Bus #${widget.busNumber} - ${widget.busRoute}',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seat Legend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seat Legend',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(
                        icon: Icons.event_seat,
                        color: Colors.black,
                        label: 'Available',
                      ),
                      _buildLegendItem(
                        icon: Icons.event_seat,
                        color: Colors.green,
                        label: 'Selected',
                      ),
                      _buildLegendItem(
                        icon: Icons.event_seat,
                        color: Colors.red,
                        label: 'Occupied',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bus Layout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Column(
                children: [
                  // Driver Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.drive_eta,
                          color: const Color(0xFF18181B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Driver',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seats Grid
                  Column(
                    children: List.generate(11, (rowIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left seat
                            _buildSeat(rowIndex * 2),
                            const SizedBox(width: 12),
                            // Aisle
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Text(
                                  '${rowIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: const Color(0xFF71717A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Right seat
                            _buildSeat(rowIndex * 2 + 1),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Selected Seats Summary
            if (selectedSeats.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Seats',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedSeats.map((index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Text(
                            _getSeatNumber(index),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF18181B),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedSeats.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ ${selectedSeats.length} seat(s) selected: ${selectedSeats.map((i) => _getSeatNumber(i)).join(', ')}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        widget.onSeatsSelected?.call();
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pop(context);
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: const Color(
                    0xFF71717A,
                  ).withOpacity(0.5),
                ),
                child: const Text(
                  'Book Selected Seats',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSeat(int index) {
    final status = seats[index];
    final isSelected = status == SeatStatus.selected;
    final isOccupied = status == SeatStatus.occupied;

    Color seatColor;
    if (isOccupied) {
      seatColor = const Color(0xFFEF4444);
    } else if (isSelected) {
      seatColor = Colors.green;
    } else {
      seatColor = const Color(0xFF18181B);
    }

    return GestureDetector(
      onTap: isOccupied ? null : () => _toggleSeat(index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isOccupied ? seatColor : Colors.white,
          border: Border.all(
            color: isOccupied ? seatColor : seatColor,
            width: isOccupied ? 2 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.event_seat, color: seatColor, size: 20),
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF71717A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

enum SeatStatus { available, selected, occupied }
