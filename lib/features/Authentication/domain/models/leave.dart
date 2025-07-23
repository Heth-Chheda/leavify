import 'package:intl/intl.dart';

class Leave {
  final String userId;
  final String employeeName;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;

  Leave({
    required this.userId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  factory Leave.fromJson(Map<String, dynamic> json) => Leave(
    userId: json['userId'] ?? '',
    employeeName: json['employeeName'] ?? '',
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'] ?? '',
    reason: json['reason'] ?? '',
    status: json['status'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'employeeName': employeeName,
    'startDate': startDate,
    'endDate': endDate,
    'reason': reason,
    'status': status,
  };

  /// 📅 Returns formatted date range like "12 Jul – 14 Jul"
  String get formattedDateRange {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      final sameMonth = start.month == end.month && start.year == end.year;

      final format = DateFormat('d MMM');
      final formatWithYear = DateFormat('d MMM yyyy');

      if (sameMonth) {
        return '${format.format(start)} – ${DateFormat('d').format(end)} ${DateFormat('MMM').format(end)}';
      } else if (start.year == end.year) {
        return '${format.format(start)} – ${format.format(end)}';
      } else {
        return '${formatWithYear.format(start)} – ${formatWithYear.format(end)}';
      }
    } catch (e) {
      return '$startDate – $endDate';
    }
  }

  /// 🧮 Returns number of leave days inclusive (e.g. 3 days for 12–14 Jul)
  int get leaveDuration {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays + 1;
    } catch (e) {
      return 1;
    }
  }
}
