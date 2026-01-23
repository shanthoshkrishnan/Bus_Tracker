// ignore_for_file: avoid_print, unused_element
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
            backgroundColor: const Color(0xFF10B981),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Error',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: const Color(0xFF71717A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF18181B),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If busId is provided, show edit form. Otherwise show list
    if (_isEditMode) {
      return _buildEditForm();
    } else {
      return _buildBusesList();
    }
  }

  Widget _buildBusesList() {
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
          'Bus Management',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF18181B)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusManagementPage(busId: ''),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _firebaseService.getAllBuses(),
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
                      'Error loading buses',
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
                      'No Buses Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a bus',
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusManagementPage(busId: bus.id),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_bus,
                              color: const Color(0xFF18181B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bus ${bus.busNumber}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF18181B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bus.busRoute,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF71717A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: bus.status == 'active'
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: bus.status == 'active'
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Text(
                              bus.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: bus.status == 'active'
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFCA8A04),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: const Color(0xFF71717A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToCreateBus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BusManagementPage(),
      ),
    ).then((_) => setState(() {}));
  }

  void _navigateToEditBus(String busId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusManagementPage(busId: busId),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _deleteBus(String busId) async {
    try {
      await _firebaseService.deleteBus(busId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus deleted successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildEditForm() {
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
          _isEditMode ? 'Edit Bus' : 'Add New Bus',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Bus Information'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Bus Number',
              controller: _busNumberController,
              hintText: 'e.g., 154',
              icon: Icons.numbers,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Bus Route',
              controller: _busRouteController,
              hintText: 'e.g., Route 12 - City Center',
              icon: Icons.route,
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Locations'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Departure Location',
              controller: _departureLocationController,
              hintText: 'e.g., Main Terminal',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Departure Latitude',
                    controller: _departureLatController,
                    hintText: '13.0827',
                    icon: Icons.my_location,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Departure Longitude',
                    controller: _departureLonController,
                    hintText: '80.2707',
                    icon: Icons.my_location,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Arrival Location',
              controller: _arrivalLocationController,
              hintText: 'e.g., Downtown Station',
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Arrival Latitude',
                    controller: _arrivalLatController,
                    hintText: '13.0827',
                    icon: Icons.flag,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Arrival Longitude',
                    controller: _arrivalLonController,
                    hintText: '80.2707',
                    icon: Icons.flag,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Driver Information'),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _driversFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final drivers = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Driver',
                      style: TextStyle(
                        color: const Color(0xFF18181B),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE4E4E7),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: Text(
                          'Select a driver',
                          style: TextStyle(color: const Color(0xFFA1A1AA)),
                        ),
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
                                Text(
                                  driverName,
                                  style: TextStyle(
                                    color: const Color(0xFF18181B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  driver['email'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF71717A),
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

            _buildSectionTitle('Vehicle Information'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Vehicle Number (License Plate)',
              controller: _vehicleNumberController,
              hintText: 'e.g., DL01AB1234',
              icon: Icons.directions_car_outlined,
            ),
            const SizedBox(height: 16),

            Text(
              'Bus Status',
              style: TextStyle(
                color: const Color(0xFF18181B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE4E4E7),
                  width: 1.5,
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
                            ? const Color(0xFF16A34A)
                            : status == 'inactive'
                                ? const Color(0xFFCA8A04)
                                : const Color(0xFFEF4444),
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

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveBus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
                  disabledBackgroundColor: const Color(0xFFE4E4E7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
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
                          fontWeight: FontWeight.w600,
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
          fontWeight: FontWeight.w700,
          color: Color(0xFF18181B),
          letterSpacing: 0.3,
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
            color: const Color(0xFF18181B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF18181B),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: const Color(0xFFA1A1AA),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF71717A),
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
