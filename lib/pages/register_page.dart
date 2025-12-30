import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedRole;
  String? _selectedGender;
  String? _selectedAcademicYear;
  String? _selectedDepartment;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final List<String> _roles = ['Student', 'Driver', 'Staff', 'Worker', 'People', 'Admin'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _academicYears = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];
  final List<String> _engineeringCourses = [
    'Computer Science',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Electronics Engineering',
    'Software Engineering',
    'Aerospace Engineering',
  ];
  final FirebaseService _firebaseService = FirebaseService();


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B6F47),
              onPrimary: Colors.white,
              surface: Color(0xFFF5F0E8),
              onSurface: Color(0xFF5C4A3D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleRegister() async {
    // Validation - check common fields
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (_selectedRole == null) {
      _showErrorDialog('Please select a role');
      return;
    }

    if (_selectedGender == null) {
      _showErrorDialog('Please select your gender');
      return;
    }

    // If student role, validate student-specific fields
    if (_selectedRole == 'Student') {
      if (_selectedAcademicYear == null) {
        _showErrorDialog('Please select academic year');
        return;
      }
      if (_selectedDepartment == null) {
        _showErrorDialog('Please select a course/department');
        return;
      }
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    if (!_agreeToTerms) {
      _showErrorDialog('Please agree to terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user already exists
      bool userExists = await _firebaseService.userExists(_emailController.text);
      if (userExists) {
        _showErrorDialog('User with this email already exists');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Register user
      await _firebaseService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        year: _selectedRole == 'Student' ? _selectedAcademicYear! : '',
        department: _selectedRole == 'Student' ? _selectedDepartment! : '',
        age: int.parse(_ageController.text),
        dob: _dobController.text,
        address: _addressController.text.trim(),
        role: _selectedRole!.toLowerCase(),
        gender: _selectedGender!.toLowerCase(),
      );

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog('Account created successfully!');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop();
            },
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
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C4A3D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
          style: TextStyle(
            color: const Color(0xFF5C4A3D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Us Today',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF5C4A3D),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7A6B60),
                    ),
              ),
              const SizedBox(height: 32),

              // First Name Field
              _buildTextField(
                label: 'First Name',
                controller: _firstNameController,
                hintText: 'Enter your first name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Last Name Field
              _buildTextField(
                label: 'Last Name',
                controller: _lastNameController,
                hintText: 'Enter your last name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildTextField(
                label: 'Email Address',
                controller: _emailController,
                hintText: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Gender Dropdown (for all roles)
              Text(
                'Gender',
                style: TextStyle(
                  color: const Color(0xFF5C4A3D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text('Select your gender'),
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(
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
                  prefixIcon: const Icon(
                    Icons.wc_outlined,
                    color: Color(0xFF8B6F47),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Role Dropdown (placed here before conditional fields)
              Text(
                'Role',
                style: TextStyle(
                  color: const Color(0xFF5C4A3D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text('Select your role'),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                    // Reset student-specific fields when role changes
                    if (value != 'Student') {
                      _selectedAcademicYear = null;
                      _selectedDepartment = null;
                    }
                  });
                },
                decoration: InputDecoration(
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
                  prefixIcon: const Icon(
                    Icons.security_outlined,
                    color: Color(0xFF8B6F47),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Academic Year Dropdown (only for students)
              if (_selectedRole == 'Student')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic Year',
                      style: TextStyle(
                        color: const Color(0xFF5C4A3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedAcademicYear,
                      hint: const Text('Select academic year'),
                      items: _academicYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAcademicYear = value;
                        });
                      },
                      decoration: InputDecoration(
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
                        prefixIcon: const Icon(
                          Icons.school_outlined,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Course/Department Dropdown (only for students)
              if (_selectedRole == 'Student')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course / Department',
                      style: TextStyle(
                        color: const Color(0xFF5C4A3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: const Text('Select engineering course'),
                      items: _engineeringCourses.map((course) {
                        return DropdownMenuItem(
                          value: course,
                          child: Text(course),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      },
                      decoration: InputDecoration(
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
                        prefixIcon: const Icon(
                          Icons.business_outlined,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Age Field
              _buildTextField(
                label: 'Age',
                controller: _ageController,
                hintText: 'Enter your age',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Date of Birth Field
              Text(
                'Date of Birth',
                style: TextStyle(
                  color: const Color(0xFF5C4A3D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: 'Select your date of birth',
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
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF8B6F47),
                  ),
                ),
                style: const TextStyle(color: Color(0xFF5C4A3D)),
              ),
              const SizedBox(height: 20),

              // Address Field
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                hintText: 'Enter your address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Password Field
              _buildPasswordField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Enter your password',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              _buildPasswordField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                hintText: 'Confirm your password',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Terms and Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF8B6F47),
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'I agree to the ',
                        style: const TextStyle(
                          color: Color(0xFF7A6B60),
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(
                              color: Color(0xFF8B6F47),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          'Create Account',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: const Color(0xFF7A6B60),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: const Color(0xFF8B6F47),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
          obscureText: obscureText,
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
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF8B6F47),
            ),
            suffixIcon: GestureDetector(
              onTap: onToggleVisibility,
              child: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF8B6F47),
              ),
            ),
          ),
          style: const TextStyle(color: Color(0xFF5C4A3D)),
        ),
      ],
    );
  }
}
