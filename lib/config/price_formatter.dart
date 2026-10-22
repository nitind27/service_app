import 'package:intl/intl.dart';

class PriceFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format as whole Indian Rupee (e.g. ₹6,999)
  static String format(num amount) {
    try {
      return _inrFormat.format(amount);
    } catch (_) {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  /// Format with decimals (e.g. ₹6,999.50)
  static String formatWithDecimals(num amount) {
    try {
      return _inrWithDecimals.format(amount);
    } catch (_) {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }
}
