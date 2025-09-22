import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class WorkInProgressScreen extends StatefulWidget {
  final String message;

  const WorkInProgressScreen({super.key, this.message = 'Under Maintenance'});

  @override
  State<WorkInProgressScreen> createState() => _WorkInProgressScreenState();
}

class _WorkInProgressScreenState extends State<WorkInProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _orbitController;
  late AnimationController _pulseController;

  late Animation<double> _mainRotation;
  late Animation<double> _orbitRotation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main central gear rotation
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _mainRotation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.linear));

    // Orbit animation for surrounding gears
    _orbitController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _orbitRotation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(parent: _orbitController, curve: Curves.linear));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _mainController.repeat();
    _orbitController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkText : AppColors.lightText;
    final accentColor = isDark ? Colors.amber.shade300 : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main animated gears section
            SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer orbiting gears
                  AnimatedBuilder(
                    animation: _orbitRotation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Gear 1 - Top Right
                          Transform.translate(
                            offset: Offset(
                              120 * math.cos(_orbitRotation.value),
                              120 * math.sin(_orbitRotation.value),
                            ),
                            child: Transform.rotate(
                              angle: -_orbitRotation.value * 2,
                              child: Icon(
                                Icons.settings,
                                size: 80,
                                color: primaryColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                          // Gear 2 - Top Left
                          Transform.translate(
                            offset: Offset(
                              120 * math.cos(_orbitRotation.value + 2.09),
                              120 * math.sin(_orbitRotation.value + 2.09),
                            ),
                            child: Transform.rotate(
                              angle: -_orbitRotation.value * 1.5,
                              child: Icon(
                                Icons.settings,
                                size: 75,
                                color: primaryColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                          // Gear 3 - Bottom Left
                          Transform.translate(
                            offset: Offset(
                              120 * math.cos(_orbitRotation.value + 4.18),
                              120 * math.sin(_orbitRotation.value + 4.18),
                            ),
                            child: Transform.rotate(
                              angle: -_orbitRotation.value * 1.8,
                              child: Icon(
                                Icons.settings,
                                size: 70,
                                color: primaryColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Central main gear with pulse
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _mainRotation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Transform.rotate(
                          angle: _mainRotation.value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withOpacity(0.1),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.settings,
                              size: 200,
                              color: accentColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Animated text
            Column(
              children: [
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Good things take time',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
