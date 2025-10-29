import 'package:flutter/material.dart';

class MyAppContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool useShadow;
  final VoidCallback? onTap;

  const MyAppContainer({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.useShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.white;

    final boxDecoration = BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: useShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : [],
    );

    final content = Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: boxDecoration,
      child: child,
    );

    // Allow gesture handling if provided
    return onTap != null
        ? GestureDetector(onTap: onTap, child: content)
        : content;
  }
}
