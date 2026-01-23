import 'package:flutter/material.dart';
import 'student_page.dart';
import 'driver_page.dart';
import 'admin_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String userRole;
  final String userName;
  final String userEmail;
  final String userId;

  const HomePage({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _getRolePage(),
      ProfilePage(
        userId: widget.userId,
        userRole: widget.userRole,
      ),
    ];
  }

  Widget _getRolePage() {
    switch (widget.userRole.toLowerCase()) {
      case 'student':
        return StudentPage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userId: widget.userId,
        );
      case 'driver':
        return DriverPage(
          driverEmail: widget.userEmail,
          driverName: widget.userName,
        );
      case 'admin':
        return AdminPage();
      default:
        return StudentPage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userId: widget.userId,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFE4E4E7), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : const Color(0xFF71717A),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
