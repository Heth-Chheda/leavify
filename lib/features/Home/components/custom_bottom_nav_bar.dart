import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final String role;
  final String? profileImageUrl;
  final int pendingRequestCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.role,
    this.profileImageUrl,
    this.pendingRequestCount = 0,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final String role = widget.role.toLowerCase();
    final bool isManagerOrHR = role != 'employee';

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

    return AnimatedBottomNavigationBar.builder(
      itemCount: navIcons.length,
      tabBuilder: (int index, bool isActive) {
        final color = isActive
            ? AppColors.highlightBlue
            : Colors.grey.withOpacity(0.9);
        final bool isProfileTab = index == navIcons.length - 1;

        // 1. Profile Tab Logic
        if (isProfileTab) {
          return _buildProfileTab(isActive, color);
        }

        // 2. Pending Requests Badge Logic (Manager only, Index 1)
        if (isManagerOrHR && index == 1) {
          return _buildBadgedIcon(
            icon: navIcons[index],
            color: color,
            count: widget.pendingRequestCount,
          );
        }

        // 3. Standard Icon
        return Icon(navIcons[index], size: 30, color: color);
      },
      activeIndex: _getActiveIndex(
        widget.currentIndex,
        addButtonOriginalIndex,
        isManagerOrHR,
      ),
      onTap: (index) {
        try {
          int originalIndex = _convertToOriginalIndex(
            index,
            addButtonOriginalIndex,
            isManagerOrHR,
          );
          widget.onTabSelected(originalIndex);
        } catch (e) {
          debugPrint('Navigation error: $e');
        }
      },
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

  // --- NEW HELPER: Builds the Icon with a Red Notification Badge ---
  Widget _buildBadgedIcon({
    required IconData icon,
    required Color color,
    required int count,
  }) {
    // If count is 0, just return the plain icon
    if (count <= 0) {
      return Icon(icon, size: 30, color: color);
    }

    return Stack(
      clipBehavior: Clip.none, // Allows the badge to hang slightly off the icon
      alignment: Alignment.center,
      children: [
        Icon(icon, size: 30, color: color),
        Positioned(
          top: 6,
          right: 23,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 18, // Ensures a perfect circle for single digits
              minHeight: 18,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : '$count', // Cap at 99+ for layout safety
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(bool isActive, Color defaultColor) {
    if (widget.profileImageUrl == null ||
        widget.profileImageUrl!.isEmpty ||
        widget.profileImageUrl == 'null') {
      return Icon(Icons.person_rounded, size: 30, color: defaultColor);
    }

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
              return Icon(Icons.person_rounded, size: 30, color: defaultColor);
            },
          ),
        ),
      ),
    );
  }

  int _getActiveIndex(
    int currentIndex,
    int addButtonIndex,
    bool isManagerOrHR,
  ) {
    if (currentIndex == addButtonIndex) {
      return -1;
    } else if (currentIndex > addButtonIndex) {
      return currentIndex - 1;
    } else {
      return currentIndex;
    }
  }

  int _convertToOriginalIndex(
    int packageIndex,
    int addButtonIndex,
    bool isManagerOrHR,
  ) {
    if (packageIndex >= addButtonIndex) {
      return packageIndex + 1;
    } else {
      return packageIndex;
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
