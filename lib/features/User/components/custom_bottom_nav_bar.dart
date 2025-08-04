import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isManagerOrHR = widget.role != 'employee';

    // Navigation items based on role
    final List<_NavItemData> navItems = [];

    if (isManagerOrHR) {
      navItems.addAll([
        _NavItemData(icon: Icons.home_rounded, label: 'Home', index: 0),
        _NavItemData(
          icon: Icons.pending_actions_rounded,
          label: 'Analytics',
          index: 1,
        ),
        _NavItemData(icon: Icons.add_rounded, label: 'Add', index: 2),
        _NavItemData(icon: Icons.bar_chart, label: 'Statistics', index: 3),
        _NavItemData(icon: Icons.person_rounded, label: 'Profile', index: 4),
      ]);
    } else {
      navItems.addAll([
        _NavItemData(icon: Icons.home_rounded, label: 'Home', index: 0),
        _NavItemData(icon: Icons.add_rounded, label: 'Add', index: 1),
        _NavItemData(icon: Icons.person_rounded, label: 'History', index: 2),
      ]);
    }

    return Container(
      margin: EdgeInsets.all(16),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // Navigation Items
          Row(
            children: navItems.map((item) {
              return Expanded(
                child: _NavItem(
                  icon: item.icon,
                  // Only home tab (index 0) should be selected since others navigate away
                  isSelected: item.index == 0,
                  onTap: () {
                    widget.onTabSelected(item.index);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: widget.isSelected
                          ? AppTheme.infoBlue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final int index;

  _NavItemData({required this.icon, required this.label, required this.index});
}
