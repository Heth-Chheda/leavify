import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/custom_app_bar.dart';
import 'package:leavify/features/User/components/custom_bottom_nav_bar.dart';
import 'package:leavify/features/User/view/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/User/view/home_screen.dart';
import 'package:leavify/features/User/view/leave_history.dart';

import '../../../core/storage/app_storage.dart';
import '../../Authentication/domain/response/login_response.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  int _currentIndex = 0;
  UserRole _userRole = UserRole.employee; // Default role
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
            _userRole = UserRole.employee;
            break;
        }
      }
    } catch (e) {
      // Handle error - default to employee role
      _userRole = UserRole.employee;
      debugPrint('Error loading user role: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getScreenForIndex(int index) {
    final bool isManagerOrHR =
        _userRole == UserRole.manager || _userRole == UserRole.hr;

    if (isManagerOrHR) {
      // Manager/HR navigation: Home, Analytics, Add, History, Pending
      switch (index) {
        case 0:
          return const HomeScreen();
        case 1:
          return const Placeholder(); // Analytics
        case 2:
          return const ApplyLeaveScreen(); // Add
        case 3:
          return const HistoryScreen(); // History
        case 4:
          return const Placeholder(); // Pending
        default:
          return const HomeScreen();
      }
    } else {
      // Employee navigation: Home, Add, History
      switch (index) {
        case 0:
          return const HomeScreen();
        case 1:
          return const ApplyLeaveScreen(); // Add
        case 2:
          return const HistoryScreen(); // History
        default:
          return const HomeScreen();
      }
    }
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
        body: SafeArea(bottom: true, child: _getScreenForIndex(_currentIndex)),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          role: _userRole, // Use the loaded role
        ),
      ),
    );
  }
}
