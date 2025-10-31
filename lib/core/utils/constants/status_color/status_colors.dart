import 'package:flutter/material.dart';

class StatusColors {
  static Color fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'escalated':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
