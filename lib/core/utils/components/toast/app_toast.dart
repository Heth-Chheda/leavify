import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';

enum ToastType { success, error, info }

class AppToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Determine colors / icon based on type
    Color backgroundColor;
    Icon? leadingIcon;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        leadingIcon = const Icon(Icons.check_circle, color: Colors.white);
        break;
      case ToastType.error:
        backgroundColor = Colors.red;
        leadingIcon = const Icon(Icons.error, color: Colors.white);
        break;
      case ToastType.info:
        backgroundColor = Colors.blue;
        leadingIcon = const Icon(Icons.info, color: Colors.white);
        break;
    }

    InteractiveToast.slide(
      context: context,
      title: Text(message, style: const TextStyle(color: Colors.white)),
      leading: leadingIcon,
      toastStyle: ToastStyle(
        backgroundColor: backgroundColor,
        // you can customize other style properties, like gradient, border radius etc.
        expandedTitle: false,
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
  }) => show(
    context: context,
    message: message,
    type: ToastType.success,
    duration: duration ?? const Duration(seconds: 1),
  );

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
  }) => show(
    context: context,
    message: message,
    type: ToastType.error,
    duration: duration ?? const Duration(seconds: 1),
  );

  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
  }) => show(
    context: context,
    message: message,
    type: ToastType.info,
    duration: duration ?? const Duration(seconds: 1),
  );

  /// optional: to close all toasts
  static void closeAll() {
    InteractiveToast.closeAllToast();
  }
}
