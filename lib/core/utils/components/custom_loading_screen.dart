import 'package:flutter/material.dart';

class CustomLoadingScreen extends StatefulWidget {
  final String? message;

  const CustomLoadingScreen({super.key, this.message});

  @override
  State<CustomLoadingScreen> createState() => _CustomLoadingScreenState();
}

class _CustomLoadingScreenState extends State<CustomLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for the outer ring
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Pulse animation for the center dot
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark
        ? const Color(0xFF4735DD)
        : const Color(0xFF4735DD);
    final secondaryColor = isDark
        ? const Color(0xFF61BFC2)
        : const Color(0xFFFF3E6C);
    final textColor = isDark ? Colors.white : Colors.black;
    final accentColor = isDark
        ? const Color(0xFFFF3E6C)
        : const Color(0xFF61BFC2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Subtle gradient overlay for depth
          gradient: isDark
              ? RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.black,
                    const Color(0xFF0A0A1F).withOpacity(0.3),
                    Colors.black,
                  ],
                )
              : RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white,
                    const Color(0xFFF5F5F5).withOpacity(0.5),
                    Colors.white,
                  ],
                ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern animated loading indicator
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 3,
                                color: Colors.transparent,
                              ),
                              gradient: SweepGradient(
                                colors: [
                                  primaryColor.withOpacity(0.1),
                                  primaryColor,
                                  secondaryColor,
                                  accentColor,
                                  primaryColor.withOpacity(0.1),
                                ],
                                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Middle ring with different speed
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_rotationAnimation.value * 1.5 * 2 * 3.14159,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: Colors.transparent,
                              ),
                              gradient: SweepGradient(
                                colors: [
                                  secondaryColor.withOpacity(0.1),
                                  secondaryColor,
                                  accentColor.withOpacity(0.7),
                                  secondaryColor.withOpacity(0.1),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Center pulsing dot
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [primaryColor, secondaryColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Floating particles effect
                    ...List.generate(6, (index) {
                      return AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          final angle =
                              (index * 60) + (_rotationAnimation.value * 180);
                          final radians = angle * 3.14159 / 180;
                          final radius = 45.0;

                          return Positioned(
                            left: 60 + radius * (1.2 * cos(radians)) - 3,
                            top: 60 + radius * (1.2 * sin(radians)) - 3,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: [
                                  primaryColor,
                                  secondaryColor,
                                  accentColor,
                                ][index % 3].withOpacity(0.6),
                                boxShadow: [
                                  BoxShadow(
                                    color: [
                                      primaryColor,
                                      secondaryColor,
                                      accentColor,
                                    ][index % 3].withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Animated loading text
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          widget.message ?? 'Loading',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Animated dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final delay = index * 0.3;
                                final animationValue =
                                    (_pulseController.value + delay) % 1.0;
                                final opacity = animationValue < 0.5
                                    ? animationValue * 2
                                    : 2.0 - (animationValue * 2);

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor.withOpacity(opacity),
                                  ),
                                );
                              },
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        // Subtle progress indicator
                        Container(
                          width: 200,
                          height: 2,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    0.3 +
                                    (0.4 *
                                        sin(
                                          _rotationAnimation.value *
                                              2 *
                                              3.14159,
                                        )),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, secondaryColor],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double cos(double radians) =>
      Curves.easeInOut.transform((radians % (2 * 3.14159)) / (2 * 3.14159)) *
          2 -
      1;
  double sin(double radians) =>
      Curves.easeInOut.transform(
            ((radians + 3.14159 / 2) % (2 * 3.14159)) / (2 * 3.14159),
          ) *
          2 -
      1;
}
