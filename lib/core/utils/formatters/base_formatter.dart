import 'package:intl/intl.dart';

abstract class BaseFormatter {
  final String? locale;

  BaseFormatter({this.locale});

  /// Parses ISO date string to [DateTime] in UTC by default
  /// e.g. '2025-10-14T23:59:59Z' -> DateTime(2025, 10, 14, 23, 59, 59, isUtc: true)
  static DateTime? parseDate(String? dateStr, {bool toUtc = true}) {
    if (dateStr == null) return null;
    try {
      final dt = DateTime.parse(dateStr);
      return toUtc ? dt.toUtc() : dt.toLocal();
    } catch (_) {
      return null;
    }
  }

  static NumberFormat numberFormat({
    String pattern = '#,##0.##',
    String? locale,
  }) {
    return NumberFormat(pattern, locale);
  }

  static NumberFormat currencyFormat({String symbol = '\$', String? locale}) {
    return NumberFormat.currency(locale: locale, symbol: symbol);
  }

  NumberFormat get defaultNumberFormat => numberFormat(locale: locale);
}
