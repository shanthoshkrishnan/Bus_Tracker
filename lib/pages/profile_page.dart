import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String userRole;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.userRole,
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
    print('ProfilePage initiated with userId: ${widget.userId}, role: ${widget.userRole}');
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
      'personalInfo': userData['firstName']?.isNotEmpty == true &&
          userData['lastName']?.isNotEmpty == true &&
          userData['email']?.isNotEmpty == true,
      'contactInfo': userData['age'] != null && userData['dob']?.isNotEmpty == true,
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
      final updateData = {
        'year': _academicYearController.text.trim(),
        'department': _departmentController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Add home location if student and not empty
      if (widget.userRole.toLowerCase() == 'student' && _homeLocationController.text.isNotEmpty) {
        updateData['homeLocation'] = _homeLocationController.text.trim();
      }
      
      // Capture current location and store as lastKnownLocation
      try {
        final position = await LocationService().getCurrentLocation();
        if (position != null) {
          updateData['lastKnownLatitude'] = position.latitude;
          updateData['lastKnownLongitude'] = position.longitude;
          updateData['lastLocationUpdate'] = FieldValue.serverTimestamp();
        }
      } catch (e) {
        print('Could not capture location: $e');
        // Continue with profile update even if location capture fails
      }
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() {
          _isEditMode = false;
          _userDataFuture = _fetchUserData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
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

  Color _getRoleColor() {
    switch (widget.userRole.toLowerCase()) {
      case 'student':
        return const Color(0xFF4CAF50);
      case 'driver':
        return const Color(0xFF2196F3);
      case 'staff':
        return const Color(0xFF9C27B0);
      case 'worker':
        return const Color(0xFFFF9800);
      case 'people':
        return const Color(0xFF00BCD4);
      case 'admin':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF8B6F47);
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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                }
              } catch (e) {
                print('Error during logout: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout error: $e')),
                  );
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
      appBar: AppBar(
        title: Text('${_getRoleEmoji()} ${widget.userRole} Profile'),
        backgroundColor: _getRoleColor(),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _getRoleColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No user data found'),
            );
          }

          final userData = snapshot.data!;
          final completion = _checkProfileCompletion(userData);
          final percentage = _getCompletionPercentage(completion);
          final isComplete = percentage == 100;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Completion Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isComplete
                        ? [const Color(0xFF4CAF50).withOpacity(0.1), const Color(0xFF4CAF50).withOpacity(0.05)]
                        : [const Color(0xFFFFC107).withOpacity(0.1), const Color(0xFFFFC107).withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFFC107),
                    width: 2,
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
                            fontWeight: FontWeight.bold,
                            color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFFC107),
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFFC107),
                        ),
                      ),
                    ),
                    if (!isComplete) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: const Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Complete your profile to get full access',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Complete Profile Button (if not complete)
              if (!isComplete)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditMode = true;
                    });
                    // Scroll to incomplete section
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('👇 Scroll down to complete your profile fields'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Complete Profile to Unlock',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Profile Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getRoleColor(),
                        _getRoleColor().withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getRoleEmoji(),
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.userRole,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              _buildProfileField('Email', userData['email'] ?? 'N/A'),
              _buildProfileField('First Name', userData['firstName'] ?? 'N/A'),
              _buildProfileField(
                'Last Name',
                userData['lastName'] ?? 'N/A',
              ),
              _buildProfileField('Age', userData['age']?.toString() ?? 'N/A'),
              _buildProfileField(
                'Date of Birth',
                _formatDate(userData['dob']),
              ),
              const SizedBox(height: 16),

              // Academic Information (Only for Students)
              if (widget.userRole.toLowerCase() == 'student') ...[
                _buildSectionTitle('Academic Information'),
                if (!_isEditMode) ...[
                  if ((userData['year'] ?? '').isNotEmpty)
                    _buildProfileField('Academic Year', userData['year']),
                  if ((userData['department'] ?? '').isNotEmpty)
                    _buildProfileField('Course / Department', userData['department']),
                  if ((userData['year'] ?? '').isEmpty || (userData['department'] ?? '').isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFC107),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: const Color(0xFFFFC107),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please update your academic details',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => setState(() => _isEditMode = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ] else ...[
                  // Edit Mode - Academic Year
                  Text(
                    'Academic Year',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getRoleColor(),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _academicYearController,
                    decoration: InputDecoration(
                      hintText: 'Enter academic year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Edit Mode - Department
                  Text(
                    'Course / Department',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getRoleColor(),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _departmentController,
                    decoration: InputDecoration(
                      hintText: 'Enter course/department',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Home Location (for notification purposes)
                  Text(
                    'Home Location (for Bus Notifications)',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getRoleColor(),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _homeLocationController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Urapakkam, Chengalpattu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      helperText: 'Where you board the bus',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Save and Cancel Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _updateProfileFields,
                          icon: const Icon(Icons.check),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
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
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Address Information
              _buildSectionTitle('Address Information'),
              _buildProfileField('Address', userData['address'] ?? 'N/A'),
              const SizedBox(height: 16),

              // Account Information
              _buildSectionTitle('Account Information'),
              _buildProfileField(
                'Created On',
                _formatDate(userData['createdAt']),
              ),
              _buildProfileField(
                'Last Updated',
                _formatDate(userData['updatedAt']),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getRoleColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getRoleColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _getRoleColor(),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: _getRoleColor(),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
