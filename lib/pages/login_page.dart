import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        String firstName = userDoc['firstName'] ?? 'User';
        String lastName = userDoc['lastName'] ?? '';
        String role = userDoc['role'] ?? 'user';
        String email = userDoc['email'] ?? _emailController.text;

        // Navigate to home page with user data
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(
              userRole: role.toUpperCase(),
              userName: '$firstName $lastName'.trim(),
              userEmail: email,
              userId: userCredential.user!.uid,
            ),
          ),
          (route) => false,
        );
      } else {
        // User document not found
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF5C4A3D),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF7A6B60),
                    ),
              ),
              const SizedBox(height: 40),

              // Email Field
              Text(
                'Email Address',
                style: TextStyle(
                  color: const Color(0xFF5C4A3D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
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
                    Icons.email_outlined,
                    color: Color(0xFF8B6F47),
                  ),
                ),
                style: const TextStyle(color: Color(0xFF5C4A3D)),
              ),
              const SizedBox(height: 24),

              // Password Field
              Text(
                'Password',
                style: TextStyle(
                  color: const Color(0xFF5C4A3D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
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
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF8B6F47),
                    ),
                  ),
                ),
                style: const TextStyle(color: Color(0xFF5C4A3D)),
              ),
              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFF8B6F47),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                          'Sign In',
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
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFD4C4B0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: const Color(0xFF7A6B60),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFD4C4B0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Social Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialButton(
                    icon: '🔵',
                    label: 'Facebook',
                    onTap: () {},
                  ),
                  _socialButton(
                    icon: '🔴',
                    label: 'Google',
                    onTap: () {},
                  ),
                  _socialButton(
                    icon: '🍎',
                    label: 'Apple',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: const Color(0xFF7A6B60),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text(
                      'Sign Up',
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

  Widget _socialButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFD4C4B0),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5C4A3D),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
