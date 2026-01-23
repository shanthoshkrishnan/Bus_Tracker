// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/driver_sync_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedRole = 'student';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // If new user is a driver, trigger driver sync
      if (_selectedRole.toLowerCase() == 'driver') {
        try {
          await DriverSyncService().syncCurrentUserDriver();
          print('✓ Driver record created on registration');
        } catch (e) {
          print('Note: Driver sync after registration: $e');
          // Don't block registration if sync fails
        }
      }

      if (!mounted) return;
      
      _showSnackBar('Account created successfully!', isError: false);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
      
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Registration failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF18181B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF18181B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF71717A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                // First Name
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'John',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Last Name
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Doe',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Role Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF71717A)),
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color(0xFF18181B),
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedRole = newValue);
                            }
                          },
                          items: <String>['student', 'driver', 'admin']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(
                                    value == 'student'
                                        ? Icons.school_outlined
                                        : value == 'driver'
                                            ? Icons.drive_eta_outlined
                                            : Icons.admin_panel_settings_outlined,
                                    color: const Color(0xFF71717A),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(value[0].toUpperCase() + value.substring(1)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF71717A),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF71717A),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18181B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFFE4E4E7),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: const Color(0xFF71717A),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: const Color(0xFF18181B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF18181B),
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
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF18181B),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFFA1A1AA),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF71717A), size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
