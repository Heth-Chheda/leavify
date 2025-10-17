import 'package:flutter/material.dart';

enum MyButtonType { elevated, outlined, text }

class MyAppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final BoxDecoration? decoration;
  final MyButtonType type;

  const MyAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius = 10,
    this.decoration,
    this.type = MyButtonType.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        else if (icon != null)
          icon!,
        if (icon != null || isLoading) const SizedBox(width: 8),
        Text(
          isLoading ? 'Processing...' : label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: foregroundColor ?? Colors.white,
          ),
        ),
      ],
    );

    final buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        backgroundColor ?? Colors.blueAccent,
      ),
      foregroundColor: MaterialStateProperty.all(
        foregroundColor ?? Colors.white,
      ),
      padding: MaterialStateProperty.all(
        padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    Widget button;
    switch (type) {
      case MyButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            side: MaterialStateProperty.all(
              BorderSide(color: backgroundColor ?? Colors.blueAccent, width: 2),
            ),
          ),
          child: child,
        );
        break;
      case MyButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      default:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
    }

    // Allow wrapping with custom decoration (like gradient backgrounds)
    if (decoration != null) {
      return Container(decoration: decoration, child: button);
    }

    return button;
  }
}
