// ignore_for_file: avoid_print, deprecated_member_use, unused_element
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/driver_sync_service.dart';
import '../services/location_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String userRole;
  final String? userName;
  final String? userEmail;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.userRole,
    this.userName,
    this.userEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userDataFuture;
  bool _isEditMode = false;
  late TextEditingController _academicYearController;
  late TextEditingController _departmentController;
  late TextEditingController _homeLocationController;

  @override
  void initState() {
    super.initState();
    print(
      'ProfilePage initiated with userId: ${widget.userId}, role: ${widget.userRole}',
    );
    if (widget.userId.isEmpty) {
      print('WARNING: userId is empty!');
    }
    _academicYearController = TextEditingController();
    _departmentController = TextEditingController();
    _homeLocationController = TextEditingController();
    _userDataFuture = _fetchUserData();
  }

  @override
  void dispose() {
    _academicYearController.dispose();
    _departmentController.dispose();
    _homeLocationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      // Check if userId is empty
      if (widget.userId.isEmpty) {
        throw Exception('User ID is empty. Please log in again.');
      }

      print('Fetching user data for userId: ${widget.userId}');

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        print('User data found: ${doc.data()}');
        final data = doc.data() as Map<String, dynamic>;
        // Initialize controllers with current data
        _academicYearController.text = data['year'] ?? '';
        _departmentController.text = data['department'] ?? '';
        _homeLocationController.text = data['homeLocation'] ?? '';
        return data;
      } else {
        throw Exception('User not found in database');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Error fetching user data: $e');
    }
  }

  // Check if profile is complete for the user's role
  Map<String, bool> _checkProfileCompletion(Map<String, dynamic> userData) {
    final role = widget.userRole.toLowerCase();
    final completion = {
      'personalInfo':
          userData['firstName']?.isNotEmpty == true &&
          userData['lastName']?.isNotEmpty == true &&
          userData['email']?.isNotEmpty == true,
      'contactInfo':
          userData['age'] != null && userData['dob']?.isNotEmpty == true,
      'address': userData['address']?.isNotEmpty == true,
      'gender': userData['gender']?.isNotEmpty == true,
      'studentDetails': true, // Default true for non-students
      'role': userData['role']?.isNotEmpty == true,
    };

    // Check student-specific details
    if (role == 'student') {
      completion['studentDetails'] =
          userData['year']?.isNotEmpty == true &&
          userData['department']?.isNotEmpty == true;
    }

    return completion;
  }

  double _getCompletionPercentage(Map<String, bool> completion) {
    int completed = completion.values.where((v) => v).length;
    return (completed / completion.length) * 100;
  }

  Future<void> _updateProfileFields() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch current user data to preserve other fields
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      final currentData = userDoc.data() ?? {};

      // Get current role for change detection
      final currentRole = (currentData['role'] ?? 'student')
          .toString()
          .toLowerCase();

      // Prepare additional data beyond what updateUserProfile handles
      final additionalData = {
        'year': _academicYearController.text.trim(),
        'department': _departmentController.text.trim(),
      };

      // Add home location if student and not empty
      if (widget.userRole.toLowerCase() == 'student' &&
          _homeLocationController.text.isNotEmpty) {
        additionalData['homeLocation'] = _homeLocationController.text.trim();
      }

      // Capture current location and store as lastKnownLocation
      try {
        final position = await LocationService().getCurrentLocation();
        if (position != null) {
          additionalData['lastKnownLatitude'] = position.latitude.toString();
          additionalData['lastKnownLongitude'] = position.longitude.toString();
          additionalData['lastLocationUpdate'] = DateTime.now()
              .toIso8601String();
        }
      } catch (e) {
        print('Could not capture location: $e');
        // Continue with profile update even if location capture fails
      }

      // Update profile using FirebaseService (triggers automatic driver sync)
      await FirebaseService().updateUserProfile(
        userId: widget.userId,
        firstName: currentData['firstName'] ?? '',
        lastName: currentData['lastName'] ?? '',
        phone: currentData['phone'] ?? '',
        address: currentData['address'] ?? '',
        role: currentRole,
      );

      // Update additional profile fields
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update(additionalData);

      // Also sync driver if role is driver (in addition to updateUserProfile)
      if (currentRole == 'driver') {
        await DriverSyncService().syncOnProfileUpdate(widget.userId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Profile updated successfully!')),
        );
        setState(() {
          _isEditMode = false;
          _userDataFuture = _fetchUserData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
      print('Profile update error: $e');
    }
  }

  String _getRoleEmoji() {
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

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(value.toDate());
    } else if (value is String) {
      try {
        DateTime dateTime = DateTime.parse(value);
        return DateFormat('dd/MM/yyyy').format(dateTime);
      } catch (e) {
        return value;
      }
    }
    return value.toString();
  }

  void _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                // Sign out from Firebase
                await FirebaseService().signOut();
                // Navigate back to login page and clear navigation stack
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              } catch (e) {
                print('Error during logout: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
        title: Text(
          'Profile',
          style: TextStyle(
            color: const Color(0xFF18181B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _userDataFuture = _fetchUserData();
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!;
          final completion = _checkProfileCompletion(userData);
          final percentage = _getCompletionPercentage(completion);
          final isComplete = percentage == 100;
          final displayName =
              widget.userName ??
              '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                  .trim();
          final displayEmail = widget.userEmail ?? userData['email'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName.isNotEmpty ? displayName : 'User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE4E4E7)),
                        ),
                        child: Text(
                          widget.userRole.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF71717A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Completion Status (Only for incomplete profiles)
                if (!isComplete)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFC107),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Completion',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFC107),
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFC107),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: const Color(
                              0xFFFFC107,
                            ).withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFC107),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!isComplete) const SizedBox(height: 20),

                // Account Section
                _buildSection(
                  title: 'Account',
                  items: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        setState(() {
                          _isEditMode = true;
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Student-specific section (if in edit mode)
                if (widget.userRole.toLowerCase() == 'student' &&
                    _isEditMode) ...[
                  _buildEditSection(userData),
                  const SizedBox(height: 20),
                ],

                // Support Section
                _buildSection(
                  title: 'Support',
                  items: [
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Logout Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _handleLogout(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.logout,
                                color: const Color(0xFFDC2626),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF71717A),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) => Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(color: const Color(0xFFE4E4E7), height: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF18181B), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF18181B),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: const Color(0xFF71717A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditSection(Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 16),

          // Academic Year
          Text(
            'Academic Year',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _academicYearController,
            decoration: InputDecoration(
              hintText: 'e.g., 2024',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Department
          Text(
            'Course / Department',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _departmentController,
            decoration: InputDecoration(
              hintText: 'Enter course/department',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Home Location
          Text(
            'Home Location (for Bus Notifications)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _homeLocationController,
            decoration: InputDecoration(
              hintText: 'e.g., Urapakkam, Chengalpattu',
              helperText: 'Where you board the bus',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save and Cancel Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _updateProfileFields,
                  icon: const Icon(Icons.check),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditMode = false),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4E4E7),
                    foregroundColor: const Color(0xFF18181B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
