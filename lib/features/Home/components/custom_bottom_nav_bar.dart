import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final String role;
  final String? profileImageUrl; // Added parameter for profile image

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.role,
    this.profileImageUrl,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final String role = widget.role.toLowerCase();
    final bool isManagerOrHR = role != 'employee';

    // Navigation items based on role (excluding the add button)
    // We keep the IconData list to determine length and default icons
    final List<IconData> navIcons = [];
    int addButtonOriginalIndex;

    if (isManagerOrHR) {
      navIcons.addAll([
        Icons.home_rounded,
        Icons.pending_actions_rounded,
        Icons.bar_chart,
        Icons.person_rounded, // Placeholder for profile image
      ]);
      addButtonOriginalIndex = 2;
    } else {
      navIcons.addAll([
        Icons.home_rounded,
        Icons.person_rounded // Placeholder for profile image
      ]);
      addButtonOriginalIndex = 1;
    }

    return AnimatedBottomNavigationBar.builder(
      itemCount: navIcons.length,
      tabBuilder: (int index, bool isActive) {
        final color = isActive ? AppColors.highlightBlue : Colors.grey.withOpacity(0.9);

        // Logic to determine if this is the profile tab (always the last one)
        final bool isProfileTab = index == navIcons.length - 1;

        if (isProfileTab) {
          return _buildProfileTab(isActive, color);
        }

        // Render standard icon for all other tabs
        return Icon(
          navIcons[index],
          size: 30,
          color: color,
        );
      },
      activeIndex: _getActiveIndex(
        widget.currentIndex,
        addButtonOriginalIndex,
        isManagerOrHR,
      ),
      onTap: (index) {
        try {
          // Check if the HomeScreen is still mounted and provider is available
          int originalIndex = _convertToOriginalIndex(
            index,
            addButtonOriginalIndex,
            isManagerOrHR,
          );
          widget.onTabSelected(originalIndex);
        } catch (e) {
          // Provider might be unavailable (e.g., during/after logout)
          debugPrint('Navigation error: $e');
        }
      },
      // Styling
      backgroundColor: const Color(0xFF060838),
      splashColor: const Color(0xFF4735DD).withOpacity(0.9),
      splashSpeedInMilliseconds: 300,
      notchSmoothness: NotchSmoothness.smoothEdge,
      gapLocation: GapLocation.center,
      elevation: 8,
      shadow: BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(0, -2),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    );
  }

  /// Helper to build the profile image with fallback
  Widget _buildProfileTab(bool isActive, Color defaultColor) {
    // 1. Check if the URL is valid.
    // We check for null, empty string, or the string "null" (just in case)
    if (widget.profileImageUrl == null ||
        widget.profileImageUrl!.isEmpty ||
        widget.profileImageUrl == 'null') {

      // Data hasn't arrived yet, show default Icon
      return Icon(Icons.person_rounded, size: 30, color: defaultColor);
    }

    // 2. Construct the full URL only when we have valid data
    // Ensure we handle slashes correctly to avoid double slashes //
    final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;

    final imagePath = widget.profileImageUrl!.startsWith('/')
        ? widget.profileImageUrl!
        : '/${widget.profileImageUrl!}';

    final fullUrl = '$baseUrl$imagePath';

    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: AppColors.highlightBlue, width: 2)
              : null,
        ),
        child: ClipOval(
          child: Image.network(
            fullUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(defaultColor),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading profile image: $error');
              return Icon(Icons.person_rounded, size: 30, color: defaultColor);
            },
          ),
        ),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4735DD), Color(0xFF1111E1)],
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