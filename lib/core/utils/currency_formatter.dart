import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility for formatting Ghana Cedi amounts
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _ghsFormat = NumberFormat.currency(
    locale: 'en_GH',
    symbol: AppConstants.defaultCurrencySymbol,
    decimalDigits: 2,
  );

  static final _plainFormat = NumberFormat('#,##0.00', 'en_GH');

  /// Format amount as GH₵ 1,234.56
  static String formatGhs(double amount) {
    return _ghsFormat.format(amount);
  }

  /// Format as plain number: 1,234.56
  static String formatPlain(double amount) {
    return _plainFormat.format(amount);
  }

  /// Format with custom currency symbol
  static String formatWithSymbol(double amount, String symbol) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Compact format: GH₵ 1.2K, GH₵ 3.4M
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${AppConstants.defaultCurrencySymbol} ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${AppConstants.defaultCurrencySymbol} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatGhs(amount);
  }

  /// Parse a GHS string back to double
  static double? parse(String text) {
    final cleaned = text
        .replaceAll(AppConstants.defaultCurrencySymbol, '')
        .replaceAll('GHS', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(cleaned);
  }
}
