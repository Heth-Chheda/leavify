import 'package:intl/intl.dart';

class Formatters {
  /// Formats ISO date string to 'dd/MM/yyyy'
  static String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }
}
