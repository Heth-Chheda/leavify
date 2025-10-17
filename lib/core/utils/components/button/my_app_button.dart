import 'package:flutter/material.dart';

enum MyButtonType { elevated, outlined, text }

class MyAppButton extends StatelessWidget {
  final String label;
  final dynamic onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final MyButtonType type;
  final MainAxisAlignment mainAxisAlignment;

  const MyAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.padding,
    this.borderRadius = 10,
    this.type = MyButtonType.elevated,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (onPressed == null || isLoading)
        ? null
        : () async {
            final result = onPressed();
            if (result is Future) await result;
          };

    final child = Row(
      mainAxisAlignment: mainAxisAlignment,
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

    Widget buttonContent;

    switch (type) {
      case MyButtonType.outlined:
        buttonContent = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? Colors.blueAccent,
            backgroundColor: Colors.transparent,
            padding:
                padding ??
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide(
              color: backgroundColor ?? Colors.blueAccent,
              width: 2,
            ),
          ),
          child: child,
        );
        break;
      case MyButtonType.text:
        buttonContent = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? Colors.blueAccent,
            padding:
                padding ??
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        );
        break;
      default:
        // Elevated / gradient button
        if (gradient != null) {
          // Use Container with gradient
          buttonContent = Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ElevatedButton(
              onPressed: effectiveOnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    padding ??
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: child,
            ),
          );
        } else {
          // Normal elevated button
          buttonContent = ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? Colors.blueAccent,
              foregroundColor: foregroundColor ?? Colors.white,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: child,
          );
        }
    }

    return buttonContent;
  }
}
