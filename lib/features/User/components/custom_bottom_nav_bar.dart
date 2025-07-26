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
  late Animation<double> _slideAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _positionAnimation;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ), // Reduced duration for smoother feel
      vsync: this,
    );

    // Changed to smooth easeInOutCubic curve instead of elasticOut
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _elevationAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animationController.forward();

    _previousIndex = widget.currentIndex;

    _positionAnimation =
        Tween<double>(
          begin: _previousIndex.toDouble(),
          end: widget.currentIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;

      _positionAnimation =
          Tween<double>(
            begin: _previousIndex.toDouble(),
            end: widget.currentIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutCubic,
            ),
          );

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main navigation bar with depression
          CustomPaint(
            painter: _NavBarPainter(
              currentIndex: widget.currentIndex,
              itemCount: navItems.length,
              animationValue: _slideAnimation,
              positionAnimation: _positionAnimation,
            ),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: navItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  _NavItemData item = entry.value;
                  return _buildNavItem(item, navItems.length);
                }).toList(),
              ),
            ),
          ),
          // Elevated selected icon
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return _buildElevatedIcon(navItems);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItemData item, int totalItems) {
    final bool isSelected = widget.currentIndex == item.index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTabSelected(item.index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 80,
          child: Center(
            child: Opacity(
              opacity: isSelected ? 0.0 : 1.0,
              child: Icon(
                item.icon,
                size: 32,
                color: const Color(0xFFD6E8EE), // Light blue-gray for unselected icons
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedIcon(List<_NavItemData> navItems) {
    final double itemWidth = MediaQuery.of(context).size.width / navItems.length;
    final double iconPosition = (_positionAnimation.value * itemWidth) + (itemWidth / 2);

    // Determine which icon to show based on animation progress
    final double animationProgress = _positionAnimation.value;
    final int fromIndex = _previousIndex;
    final int toIndex = widget.currentIndex;

    // Show the previous icon during the first half of animation, then switch to new icon
    final bool showPreviousIcon = (animationProgress - fromIndex).abs() < 0.5;
    final IconData iconToShow = showPreviousIcon
        ? navItems[fromIndex].icon
        : navItems[toIndex].icon;

    return Positioned(
      left: iconPosition - 25,
      top: -25 * _elevationAnimation.value,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001B48), // Light blue
              Color(0xFF001B48), // Light blue
              // Color(0xFF97CADB), // Medium blue
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02457A).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF001B48).withOpacity(0.9),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          iconToShow,
          size: 28,
          color: const Color(0xFFFFFFFF), // Dark navy for icon
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final int currentIndex;
  final int itemCount;
  final Animation<double> animationValue;
  final Animation<double> positionAnimation;

  _NavBarPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.animationValue,
    required this.positionAnimation,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF02457A), // Deep navy
          Color(0xFF018ABE), // Dark blue
          Color(0xFF97CADB), // Medium blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final borderPaint = Paint()
      ..color = const Color(0xFF97CADB).withOpacity(0.3) // Light blue border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final shadowPaint = Paint()
      ..color = const Color(0xFF001B48).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path();
    final itemWidth = size.width / itemCount;
    final depressionRadius = 60.0; // Bigger depression to fit the 50px circle
    final depressionDepth = 35.0; // Depth of the notch cut into the nav bar

    // Calculate the center position of the selected item
    final animatedIndex = positionAnimation.value;
    final selectedCenter = (animatedIndex * itemWidth) + (itemWidth / 2);
    final animatedDepth = depressionDepth * animationValue.value;

    // Start from top-left
    path.moveTo(0, 0);

    // Draw the top edge with depression cut INTO the nav bar
    final depressionStart = selectedCenter - depressionRadius;
    final depressionEnd = selectedCenter + depressionRadius;

    // Left part of top edge
    path.lineTo(depressionStart, 0);

    // Create depression that cuts INTO the nav bar (downward curve)
    if (animationValue.value > 0) {
      // Create a smooth downward arc that cuts into the nav bar

      final double controlPointOffset = depressionRadius * 0.6;

      final bottomPoint = Offset(selectedCenter, animatedDepth);

      path.cubicTo(
        depressionStart + (controlPointOffset * 0.5),
        0,
        selectedCenter - (controlPointOffset * 0.8),
        animatedDepth,
        bottomPoint.dx,
        bottomPoint.dy,
      );

      path.cubicTo(
        selectedCenter + (controlPointOffset * 0.8),
        animatedDepth,
        depressionEnd - (controlPointOffset * 0.5),
        0,
        depressionEnd,
        0,
      );
    }

    // Right part of top edge
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);

    // Draw main shape
    canvas.drawPath(path, paint);

    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_NavBarPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.animationValue != animationValue;
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final int index;

  _NavItemData({required this.icon, required this.label, required this.index});
}