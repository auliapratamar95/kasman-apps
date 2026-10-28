import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'id_ID');

  /// Formats value as Indonesian Rupiah: "Rp 18.000"
  static String format(num amount) {
    return _idrFormat.format(amount);
  }

  /// Formats value without prefix: "18.000"
  static String formatNumber(num amount) {
    return _numberFormat.format(amount);
  }

  /// Compact format for dashboard badges: "Rp 26,5 Jt" or "Rp 850 Rb"
  static String formatCompact(num amount) {
    if (amount >= 1000000000) {
      double val = amount / 1000000000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} M';
    } else if (amount >= 1000000) {
      double val = amount / 1000000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} Jt';
    } else if (amount >= 1000) {
      double val = amount / 1000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} Rb';
    }
    return format(amount);
  }

  /// Formats percentage: "58.3%"
  static String formatPercent(num percent) {
    return '${percent.toStringAsFixed(1)}%';
  }
}
