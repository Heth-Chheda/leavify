import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/custom_app_bar.dart';
import 'package:leavify/features/User/components/custom_bottom_nav_bar.dart';
import 'package:leavify/features/User/view/home_screen.dart';

import '../../../core/storage/app_storage.dart';
import '../../Authentication/domain/response/login_response.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  int _currentIndex = 0;
  UserRole _userRole = UserRole.manager; // Default role
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final loginResponse = await AppStorage.getObject<LoginResponseModel>(
        "user_details",
        (json) => LoginResponseModel.fromJson(json),
      );

      if (loginResponse != null) {
        final userRoleString =
            loginResponse.currentUser?.role.toLowerCase() ?? 'employee';

        // Map string role to UserRole enum
        switch (userRoleString) {
          case 'manager':
            _userRole = UserRole.manager;
            break;
          case 'hr':
            _userRole = UserRole.hr;
            break;
          case 'employee':
          default:
            _userRole = UserRole.manager;
            break;
        }
      }
    } catch (e) {
      // Handle error - default to employee role
      _userRole = UserRole.manager;
      debugPrint('Error loading user role: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabSelected(int index) {
    final bool isManagerOrHR =
        _userRole == UserRole.manager || _userRole == UserRole.hr;

    if (isManagerOrHR) {
      // Manager/HR navigation: Home, Analytics, Add, History, Pending
      switch (index) {
        case 0:
          // Home - stay on current screen
          setState(() {
            _currentIndex = index;
          });
          break;
        case 1:
          // Analytics - navigate to new screen

          Navigator.pushNamed(context, '/pending');
          break;
        case 2:
          // Add Leave - navigate to new screen
          Navigator.pushNamed(context, '/apply-leave');
          break;
        case 3:
          Navigator.pushNamed(context, '/analytics');
          break;
        case 4:
          // Pending - navigate to new screen
          Navigator.pushNamed(context, '/profile');
          break;
      }
    } else {
      // Employee navigation: Home, Add, History
      switch (index) {
        case 0:
          // Home - stay on current screen
          setState(() {
            _currentIndex = index;
          });
          break;
        case 1:
          // Add Leave - navigate to new screen
          Navigator.pushNamed(context, '/apply-leave');
          break;
        case 2:
          // History - navigate to new screen
          Navigator.pushNamed(context, '/profile');
          break;
      }
    }
  }

  Widget _getCurrentScreen() {
    // Only show HomeScreen in the landing view
    // All other screens will be navigated to as separate pages
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: CustomAppBar(),
        body: SafeArea(bottom: true, child: _getCurrentScreen()),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          role: _userRole, // Use the loaded role
        ),
      ),
    );
  }
}
