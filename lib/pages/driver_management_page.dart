import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/driver_sync_service.dart';
import '../services/firebase_service.dart';

class DriverManagementPage extends StatefulWidget {
  const DriverManagementPage({super.key});

  @override
  State<DriverManagementPage> createState() => _DriverManagementPageState();
}

class _DriverManagementPageState extends State<DriverManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _availableBuses = [];
  List<String> _availableRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableBuses();
    _loadAvailableRoutes();
  }

  Future<void> _loadAvailableBuses() async {
    try {
      final snapshot = await _firestore.collection('buses').get();
      final buses = snapshot.docs.map((doc) => doc['busNumber'].toString()).toList();
      setState(() => _availableBuses = buses);
      print('✓ Loaded ${buses.length} buses');
    } catch (e) {
      print('Error loading buses: $e');
    }
  }

  Future<void> _loadAvailableRoutes() async {
    try {
      final snapshot = await _firestore.collection('routes').get();
      final routes = snapshot.docs.map((doc) => doc['routeName'].toString()).toList();
      setState(() => _availableRoutes = routes);
      print('✓ Loaded ${routes.length} routes');
    } catch (e) {
      print('Error loading routes: $e');
    }
  }

  // Create new driver with registration form
  void _showCreateDriverDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final ageController = TextEditingController();
    final dobController = TextEditingController();
    String selectedGender = 'Male';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Driver'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => selectedGender = value ?? 'Male',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Create user account
                  final tempPassword = 'Driver@123456';
                  await FirebaseService().registerUser(
                    email: emailController.text.trim(),
                    password: tempPassword,
                    firstName: firstNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    age: int.parse(ageController.text),
                    dob: dobController.text.trim(),
                    address: addressController.text.trim(),
                    role: 'driver',
                    gender: selectedGender.toLowerCase(),
                    year: '',
                    department: '',
                  );

                  // Sync driver after registration
                  await DriverSyncService().syncCurrentUserDriver();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ Driver created! Password: $tempPassword'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18181B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Manage driver details
  void _showEditDriverDialog(String userId, Map<String, dynamic> driverData) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(
      text: driverData['firstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: driverData['lastName'] ?? '',
    );
    final phoneController = TextEditingController(
      text: driverData['phone'] ?? '',
    );
    final addressController = TextEditingController(
      text: driverData['address'] ?? '',
    );
    final ageController = TextEditingController(
      text: driverData['age']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Driver Details'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Update users collection
                  await _firestore.collection('users').doc(userId).update({
                    'firstName': firstNameController.text.trim(),
                    'lastName': lastNameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'age': int.tryParse(ageController.text) ?? 0,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  // Update driver collection
                  await DriverSyncService().updateDriverAssignment(
                    driverId: userId,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Driver details updated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18181B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Add dummy data
  Future<void> _addDummyData() async {
    try {
      const dummyDrivers = [
        {
          'name': 'John Driver',
          'phone': '+91-9876543210',
          'email': 'john.driver@college.com',
          'age': 35,
          'dob': '1988-05-15',
          'address': 'Chennai, Tamil Nadu',
        },
        {
          'name': 'Raj Kumar',
          'phone': '+91-9876543211',
          'email': 'raj.kumar@college.com',
          'age': 32,
          'dob': '1991-07-20',
          'address': 'Bangalore, Karnataka',
        },
        {
          'name': 'Priya Singh',
          'phone': '+91-9876543212',
          'email': 'priya.singh@college.com',
          'age': 28,
          'dob': '1995-03-10',
          'address': 'Hyderabad, Telangana',
        },
      ];

      for (var dummy in dummyDrivers) {
        final parts = (dummy['name'] as String).split(' ');
        final firstName = parts[0];
        final lastName = parts.skip(1).join(' ');

        await FirebaseService().registerUser(
          email: dummy['email'] as String,
          password: 'DummyDriver@123',
          firstName: firstName,
          lastName: lastName,
          age: dummy['age'] as int,
          dob: dummy['dob'] as String,
          address: dummy['address'] as String,
          role: 'driver',
          gender: 'Male',
          year: '',
          department: '',
        );
      }

      await DriverSyncService().syncCurrentUserDriver();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Dummy drivers added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding dummy data: $e');
    }
  }

  // Update driver bus
  Future<void> _updateDriverBus(String userId, String newBusNumber) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      await _firestore.collection('users').doc(userId).update({
        'assignedBusNumber': newBusNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final busSnapshot = await _firestore
          .collection('buses')
          .where('busNumber', isEqualTo: newBusNumber)
          .get();

      if (busSnapshot.docs.isNotEmpty) {
        await busSnapshot.docs.first.reference.update({
          'assignedDriverId': userId,
          'driverName': '${userData['firstName']} ${userData['lastName']}',
          'driverPhone': userData['phone'] ?? '',
        });
      }

      await DriverSyncService().updateDriverAssignment(
        driverId: userId,
        assignedBusNumber: newBusNumber,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Bus assigned!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Update driver route
  Future<void> _updateDriverRoute(String userId, String newRoute) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'assignedRoute': newRoute,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await DriverSyncService().updateDriverAssignment(
        driverId: userId,
        assignedRoute: newRoute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Route assigned!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildAssignmentCard({
    required IconData icon,
    required String label,
    required String value,
    required List<String> dropdownItems,
    required String Function(String) dropdownLabel,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF18181B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18181B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: null,
            hint: const Text(
              'Change',
              style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
            ),
            items: dropdownItems.map((item) {
              return DropdownMenuItem(
                value: item,
                child: SizedBox(
                  width: 140,
                  child: Text(
                    dropdownLabel(item),
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.unfold_more, size: 16),
            isDense: true,
            menuMaxHeight: 200,
          ),
        ],
      ),
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
              'Driver Management',
              style: TextStyle(
                color: const Color(0xFF18181B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Manage assignments & details',
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _addDummyData,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Dummy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18181B),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDriverDialog,
        backgroundColor: const Color(0xFF18181B),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Stream builder for drivers
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'driver')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                              Icons.person_off,
                              size: 40,
                              color: const Color(0xFF71717A),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Drivers Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to create a new driver',
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

                final drivers = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    final userId = driver.id;
                    final data = driver.data() as Map<String, dynamic>;

                    final driverName =
                        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                            .trim();
                    final phone = data['phone'] ?? 'N/A';
                    final email = data['email'] ?? 'N/A';
                    final assignedBus =
                        data['assignedBusNumber'] ?? 'Not assigned';
                    final assignedRoute =
                        data['assignedRoute'] ?? 'Not assigned';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with name and action buttons
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFF18181B),
                                  child: Text(
                                    driverName.isNotEmpty
                                        ? driverName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driverName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF18181B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        phone,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFF71717A),
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF71717A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                IconButton(
                                  onPressed: () =>
                                      _showEditDriverDialog(userId, data),
                                  icon: const Icon(Icons.edit,
                                      size: 20, color: Color(0xFF18181B)),
                                  tooltip: 'Edit Details',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE4E4E7), height: 1),
                            const SizedBox(height: 16),

                            // Bus Assignment
                            _buildAssignmentCard(
                              icon: Icons.directions_bus,
                              label: 'Bus Assignment',
                              value: 'Bus #$assignedBus',
                              dropdownItems: _availableBuses,
                              dropdownLabel: (bus) => 'Bus #$bus',
                              onChanged: (value) {
                                if (value != null) {
                                  _updateDriverBus(userId, value);
                                }
                              },
                            ),
                            const SizedBox(height: 12),

                            // Route Assignment
                            _buildAssignmentCard(
                              icon: Icons.map,
                              label: 'Route Assignment',
                              value: assignedRoute,
                              dropdownItems: _availableRoutes,
                              dropdownLabel: (route) => route,
                              onChanged: (value) {
                                if (value != null) {
                                  _updateDriverRoute(userId, value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
