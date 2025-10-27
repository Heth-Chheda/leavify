import 'package:intl/intl.dart';
import 'base_formatter.dart';

class DateFormatter extends BaseFormatter {
  DateFormatter({super.locale});

  /// Formats date as 'dd/MM/yyyy'
  /// e.g. '2025-10-16' -> '16/10/2025'
  static String formatShort(String? dateStr, {String? locale}) {
    final date = BaseFormatter.parseDate(dateStr);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy', locale ?? 'en_US').format(date);
  }

  /// Formats date as 'EEEE, MMM d, yyyy'
  /// e.g. '2025-10-16' -> 'Thursday, Oct 16, 2025'
  static String formatLong(String? dateStr, {String? locale}) {
    final date = BaseFormatter.parseDate(dateStr);
    if (date == null) return '';
    return DateFormat('EEEE, MMM d, yyyy', locale ?? 'en_US').format(date);
  }

  /// Formats time as 'hh:mm a'
  /// e.g. '2025-10-16T14:30:00' -> '02:30 PM'
  static String formatTime(String? dateStr, {String? locale}) {
    final date = BaseFormatter.parseDate(dateStr);
    if (date == null) return '';
    return DateFormat('hh:mm a', locale ?? 'en_US').format(date);
  }

  /// Formats date as 'MMM d, yyyy'
  /// e.g. '2026-06-16' -> 'Jun 16, 2026'
  static String formatMonthDayYear(String? dateStr, {String? locale}) {
    final date = BaseFormatter.parseDate(dateStr);
    if (date == null) return '';
    return DateFormat('MMM d, yyyy', locale ?? 'en_US').format(date);
  }

  /// Calculates the duration between two dates.
  /// e.g. '2026-06-16' -> '2026-06-20' -> '4 days'
  static String durationBetween(String? startStr, String? endStr) {
    final start = BaseFormatter.parseDate(startStr);
    final end = BaseFormatter.parseDate(endStr);
    if (start == null || end == null) return '';

    final duration = end.difference(start);
    return '${duration.inDays} days';
  }

  /// Formats a date range as 'MMM d, yyyy -> MMM d, yyyy'
  /// e.g. '2020-06-16', '2020-06-18' -> 'Jun 16, 2020 -> Jun 18, 2020'
  static String formatDateRange(
    String? startStr,
    String? endStr, {
    String? locale,
  }) {
    final start = BaseFormatter.parseDate(startStr);
    final end = BaseFormatter.parseDate(endStr);
    if (start == null || end == null) return '';

    final startFormatted = DateFormat(
      'MMM d, yyyy',
      locale ?? 'en_US',
    ).format(start);
    final endFormatted = DateFormat(
      'MMM d, yyyy',
      locale ?? 'en_US',
    ).format(end);

    if (startFormatted == endFormatted) {
      return startFormatted;
    }

    return '$startFormatted -- $endFormatted';
  }
}
