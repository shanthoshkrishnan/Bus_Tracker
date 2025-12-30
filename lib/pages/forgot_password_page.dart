import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    });
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              if (!_emailSent) ...[
                // Header
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: const Color(0xFF5C4A3D),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password',
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
                const SizedBox(height: 40),

                // Send Reset Link Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
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
                            'Send Reset Link',
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
              ] else ...[
                // Success Message
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6F47).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Check Your Email',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF5C4A3D),
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We\'ve sent a password reset link to:',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF7A6B60),
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _emailController.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF8B6F47),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Follow the link in the email to reset your password. If you don\'t see the email, please check your spam folder.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF7A6B60),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Back to Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6F47),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Back to Login',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend Email Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    child: Text(
                      'Didn\'t receive the email? Resend',
                      style: TextStyle(
                        color: const Color(0xFF8B6F47),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
