import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';

enum UserRole { employee, manager, hr }

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final UserRole role;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.role,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _underlineAnimation;
  double _underlinePosition = 0.0;
  double _itemWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _underlineAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateUnderlinePosition(int index, double itemWidth) {
    final newPosition = index * itemWidth + (itemWidth / 2) - 20;

    setState(() {
      _itemWidth = itemWidth;
    });

    final tween = Tween<double>(begin: _underlinePosition, end: newPosition);

    _underlineAnimation = tween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animationController.forward(from: 0.0).then((_) {
      _underlinePosition = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isManagerOrHR =
        widget.role == UserRole.manager || widget.role == UserRole.hr;

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
        _NavItemData(icon: Icons.add_rounded, label: 'Add', index: 2),
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
        _NavItemData(icon: Icons.add_rounded, label: 'Add', index: 1),
        _NavItemData(icon: Icons.history_rounded, label: 'History', index: 2),
      ]);
    }

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
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
                  isSelected: widget.currentIndex == item.index,
                  onTap: () {
                    widget.onTabSelected(item.index);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final itemWidth = screenWidth / navItems.length;
                      _updateUnderlinePosition(item.index, itemWidth);
                    });
                  },
                ),
              );
            }).toList(),
          ),
          // Animated Underline
          Positioned(
            bottom: 27,
            child: AnimatedBuilder(
              animation: _underlineAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_underlineAnimation.value, 0),
                  child: Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.infoBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
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
      end: 10.0,
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
        padding: EdgeInsets.only(bottom: 25),
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
