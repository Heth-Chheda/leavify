import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

enum UserRole { employee, manager, hr }

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final String role;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.role,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final String role = widget.role.toLowerCase();
    final bool isManagerOrHR = role != 'employee';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Navigation items based on role (excluding the add button)
    final List<IconData> navIcons = [];
    int addButtonOriginalIndex;

    if (isManagerOrHR) {
      navIcons.addAll([
        Icons.home_rounded,
        Icons.pending_actions_rounded,
        Icons.bar_chart,
        Icons.person_rounded,
      ]);
      addButtonOriginalIndex = 2;
    } else {
      navIcons.addAll([Icons.home_rounded, Icons.person_rounded]);
      addButtonOriginalIndex = 1;
    }

    return AnimatedBottomNavigationBar(
      icons: navIcons,
      activeIndex: _getActiveIndex(
        widget.currentIndex,
        addButtonOriginalIndex,
        isManagerOrHR,
      ),
      onTap: (index) {
        int originalIndex = _convertToOriginalIndex(
          index,
          addButtonOriginalIndex,
          isManagerOrHR,
        );
        widget.onTabSelected(originalIndex);
      },
      // Styling
      activeColor: AppColors.highlightBlue,
      inactiveColor: Colors.grey.withOpacity(0.9),
      backgroundColor: Color(0xFF060838),
      splashColor: const Color(0xFF4735DD).withOpacity(0.9),
      splashSpeedInMilliseconds: 300,
      notchSmoothness: NotchSmoothness.smoothEdge,
      gapLocation: GapLocation.center,
      iconSize: 30,
      elevation: 8,
      shadow: BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(0, -2),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    );
  }

  // Convert current index to the package's expected index (excluding add button)
  int _getActiveIndex(
    int currentIndex,
    int addButtonIndex,
    bool isManagerOrHR,
  ) {
    if (currentIndex == addButtonIndex) {
      return -1; // Add button is floating, not in the regular nav
    } else if (currentIndex > addButtonIndex) {
      return currentIndex - 1; // Shift down by 1 since add button is removed
    } else {
      return currentIndex; // No change needed
    }
  }

  // Convert package index back to original indexing
  int _convertToOriginalIndex(
    int packageIndex,
    int addButtonIndex,
    bool isManagerOrHR,
  ) {
    if (packageIndex >= addButtonIndex) {
      return packageIndex + 1; // Shift up by 1 to account for add button
    } else {
      return packageIndex; // No change needed
    }
  }
}

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSelected;

  const FloatingAddButton({
    super.key,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.red,
      elevation: isSelected ? 8 : 6,
      shape: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF4735DD), const Color(0xFF1111E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
    );
  }
}
