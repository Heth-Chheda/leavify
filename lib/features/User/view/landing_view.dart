import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/custom_app_bar.dart';
import 'package:leavify/features/User/components/custom_bottom_nav_bar.dart';
import 'package:leavify/features/User/view/home_screen.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Placeholder(), // Apply Leave screen
    const Placeholder(), // History
    const Placeholder(), // Statistics (for manager/HR only)
    const Placeholder(), // Pending Requests
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: CustomAppBar(),
        body: SafeArea(
          bottom: true, // This adds padding for the bottom bar
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
