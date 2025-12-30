import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class BusManagementPage extends StatefulWidget {
  final String? busId;

  const BusManagementPage({
    super.key,
    this.busId,
  });

  @override
  State<BusManagementPage> createState() => _BusManagementPageState();
}

class _BusManagementPageState extends State<BusManagementPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> _driversFuture;

  // Form controllers
  final _busNumberController = TextEditingController();
  final _busRouteController = TextEditingController();
  final _departureLocationController = TextEditingController();
  final _arrivalLocationController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _departureLatController = TextEditingController();
  final _departureLonController = TextEditingController();
  final _arrivalLatController = TextEditingController();
  final _arrivalLonController = TextEditingController();

  String _selectedDriverEmail = '';
  Map<String, dynamic>? _selectedDriverObject;
  String _selectedStatus = 'active';
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _driversFuture = _firebaseService.getAllDrivers();
    _loadBusData();
  }

  Future<void> _loadBusData() async {
    if (widget.busId != null && widget.busId!.isNotEmpty) {
      setState(() {
        _isEditMode = true;
      });
      try {
        final bus = await _firebaseService.getBusById(widget.busId!);
        if (bus != null && mounted) {
          setState(() {
            _busNumberController.text = bus.busNumber;
            _busRouteController.text = bus.busRoute;
            _departureLocationController.text = bus.departureLocation;
            _arrivalLocationController.text = bus.arrivalLocation;
            _driverNameController.text = bus.driverName;
            _driverPhoneController.text = bus.driverPhone;
            _vehicleNumberController.text = bus.vehicleNumber;
            _departureLatController.text = bus.departureLatitude.toString();
            _departureLonController.text = bus.departureLongitude.toString();
            _arrivalLatController.text = bus.arrivalLatitude.toString();
            _arrivalLonController.text = bus.arrivalLongitude.toString();
            _selectedStatus = bus.status;
          });
        }
      } catch (e) {
        print('Error loading bus data: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading bus: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _busRouteController.dispose();
    _departureLocationController.dispose();
    _arrivalLocationController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _vehicleNumberController.dispose();
    _departureLatController.dispose();
    _departureLonController.dispose();
    _arrivalLatController.dispose();
    _arrivalLonController.dispose();
    super.dispose();
  }

  void _selectDriverFromDropdown(Map<String, dynamic> driver) {
    setState(() {
      final driverName = '${driver['firstName']} ${driver['lastName']}';
      _driverNameController.text = driverName;
      _selectedDriverEmail = driver['email'] ?? '';
      _selectedDriverObject = driver;
    });
  }

  Future<bool> _isBusNumberExists(String busNumber) async {
    try {
      final buses = await _firebaseService.getAllBuses();
      for (var bus in buses) {
        // If editing, skip the current bus
        if (_isEditMode && widget.busId == bus.id) {
          continue;
        }
        if (bus.busNumber.toLowerCase() == busNumber.toLowerCase()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking bus number: $e');
      return false;
    }
  }

  void _handleSaveBus() async {
    // Validation
    if (_busNumberController.text.isEmpty ||
        _busRouteController.text.isEmpty ||
        _departureLocationController.text.isEmpty ||
        _arrivalLocationController.text.isEmpty ||
        _driverNameController.text.isEmpty ||
        _driverPhoneController.text.isEmpty ||
        _vehicleNumberController.text.isEmpty) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    // Check for duplicate bus number
    final busNumberExists = await _isBusNumberExists(_busNumberController.text.trim());
    if (busNumberExists) {
      _showErrorDialog('Bus number ${_busNumberController.text.trim()} already exists. Please use a different number.');
      return;
    }

    // Validate coordinates
    double? depLat, depLon, arrLat, arrLon;
    try {
      depLat = double.parse(_departureLatController.text);
      depLon = double.parse(_departureLonController.text);
      arrLat = double.parse(_arrivalLatController.text);
      arrLon = double.parse(_arrivalLonController.text);

      if (depLat < -90 || depLat > 90 || arrLat < -90 || arrLat > 90) {
        throw Exception('Latitude must be between -90 and 90');
      }
      if (depLon < -180 || depLon > 180 || arrLon < -180 || arrLon > 180) {
        throw Exception('Longitude must be between -180 and 180');
      }
    } catch (e) {
      _showErrorDialog('Invalid coordinates: $e');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save bus
      await _firebaseService.addOrUpdateBus(
        busId: _isEditMode ? widget.busId : null,
        busNumber: _busNumberController.text.trim(),
        busRoute: _busRouteController.text.trim(),
        departureLocation: _departureLocationController.text.trim(),
        arrivalLocation: _arrivalLocationController.text.trim(),
        departureLatitude: depLat,
        departureLongitude: depLon,
        arrivalLatitude: arrLat,
        arrivalLongitude: arrLon,
        driverName: _driverNameController.text.trim(),
        driverPhone: _driverPhoneController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        status: _selectedStatus,
      );

      // Update driver with assigned bus information
      if (_selectedDriverEmail.isNotEmpty) {
        await _firebaseService.updateDriverWithBusAssignment(
          driverEmail: _selectedDriverEmail,
          busNumber: _busNumberController.text.trim(),
          busRoute: _busRouteController.text.trim(),
          vehicleNumber: _vehicleNumberController.text.trim(),
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Bus updated successfully!' : 'Bus created successfully!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorDialog('Error saving bus: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B6F47),
        elevation: 0,
        title: Text(
          _isEditMode ? 'Edit Bus' : 'Create New Bus',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bus Information Section
            _buildSectionTitle('Bus Information'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Bus Number',
              controller: _busNumberController,
              hintText: 'e.g., BUS-A-001',
              icon: Icons.directions_bus_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Bus Route',
              controller: _busRouteController,
              hintText: 'e.g., Route A - Main Campus to City Center',
              icon: Icons.route_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Location Information Section
            _buildSectionTitle('Location Information'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Departure Location',
              controller: _departureLocationController,
              hintText: 'e.g., Main Campus Gate',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Departure Latitude',
                    controller: _departureLatController,
                    hintText: '40.7128',
                    icon: Icons.public_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Longitude',
                    controller: _departureLonController,
                    hintText: '-74.0060',
                    icon: Icons.public_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Arrival Location',
              controller: _arrivalLocationController,
              hintText: 'e.g., City Center Bus Station',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Arrival Latitude',
                    controller: _arrivalLatController,
                    hintText: '40.7489',
                    icon: Icons.public_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Longitude',
                    controller: _arrivalLonController,
                    hintText: '-73.9680',
                    icon: Icons.public_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Driver Information Section
            _buildSectionTitle('Driver Information'),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _driversFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }

                final drivers = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign Driver',
                      style: TextStyle(
                        color: const Color(0xFF5C4A3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (drivers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No drivers available. Please register a driver account first.',
                                style: TextStyle(color: Colors.orange[700]),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFD4C4B0),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButton<Map<String, dynamic>>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('Select a driver'),
                          value: _selectedDriverObject,
                          items: drivers.map((driver) {
                            final driverName =
                                '${driver['firstName']} ${driver['lastName']}';
                            return DropdownMenuItem(
                              value: driver,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(driverName),
                                  Text(
                                    driver['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (driver) {
                            if (driver != null) {
                              _selectDriverFromDropdown(driver);
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            _buildTextField(
              label: 'Driver Phone',
              controller: _driverPhoneController,
              hintText: 'e.g., +1-800-123-4567',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Vehicle Information Section
            _buildSectionTitle('Vehicle Information'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Vehicle Number (License Plate)',
              controller: _vehicleNumberController,
              hintText: 'e.g., DL01AB1234',
              icon: Icons.directions_car_outlined,
            ),
            const SizedBox(height: 16),

            // Status Section
            Text(
              'Bus Status',
              style: TextStyle(
                color: const Color(0xFF5C4A3D),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD4C4B0),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                value: _selectedStatus,
                items: ['active', 'inactive', 'maintenance'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: status == 'active'
                            ? Colors.green
                            : status == 'inactive'
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? 'active';
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveBus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B6F47),
                  disabledBackgroundColor: const Color(0xFFB8A895),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Bus' : 'Create Bus',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B6F47),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5C4A3D),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFB8A895)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD4C4B0),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD4C4B0),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF8B6F47),
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF8B6F47),
            ),
          ),
          style: const TextStyle(color: Color(0xFF5C4A3D)),
        ),
      ],
    );
  }
}
