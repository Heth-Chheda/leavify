import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';

enum UserRole { employee, manager, hr }

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final UserRole role;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.role = UserRole.manager,
  });

  @override
  Widget build(BuildContext context) {
    final bool isManagerOrHR = role == UserRole.manager || role == UserRole.hr;

    // Navigation items based on role
    final List<_NavItemData> navItems = [];

    if (isManagerOrHR) {
      navItems.addAll([
        _NavItemData(icon: Icons.home_rounded, label: 'Home', index: 0),
        _NavItemData(
          icon: Icons.analytics_rounded,
          label: 'Analytics',
          index: 1,
        ),
        _NavItemData(
          icon: Icons.add_rounded,
          label: 'Add',
          index: 2,
          isFloating: true,
        ),
        _NavItemData(icon: Icons.history_rounded, label: 'History', index: 3),
        _NavItemData(
          icon: Icons.pending_actions_rounded,
          label: 'Pending',
          index: 4,
        ),
      ]);
    } else {
      navItems.addAll([
        _NavItemData(icon: Icons.home_rounded, label: 'Home', index: 0),
        _NavItemData(
          icon: Icons.add_rounded,
          label: 'Add',
          index: 1,
          isFloating: true,
        ),
        _NavItemData(icon: Icons.history_rounded, label: 'History', index: 2),
      ]);
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlueDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlueDark.withOpacity(0.9),
                AppTheme.primaryBlueDark.withOpacity(0.8),
              ],
            ),
            // Glassmorphism effect
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.map((item) {
              return _buildNavItem(item);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItemData item) {
    final bool isSelected = currentIndex == item.index;

    if (item.isFloating) {
      return _buildFloatingActionButton(item);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(item.index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with modern selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              // Label with fade animation
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.7,
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              // Selection indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: isSelected ? 16 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(_NavItemData item) {
    final bool isSelected = currentIndex == item.index;

    return GestureDetector(
      onTap: () => onTabSelected(item.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        transform: Matrix4.translationValues(0, isSelected ? -4 : 0, 0),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [Colors.white, Colors.white.withOpacity(0.9)]
                  : [
                      AppTheme.primaryBlueLighter,
                      AppTheme.primaryBlueLighter.withOpacity(0.8),
                    ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.white.withOpacity(0.4)
                    : AppTheme.primaryBlueLighter.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            item.icon,
            size: 28,
            color: isSelected ? AppTheme.primaryBlueDark : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final int index;
  final bool isFloating;

  _NavItemData({
    required this.icon,
    required this.label,
    required this.index,
    this.isFloating = false,
  });
}
