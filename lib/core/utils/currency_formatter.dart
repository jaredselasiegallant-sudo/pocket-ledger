import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility for formatting currency amounts dynamically
class CurrencyFormatter {
  CurrencyFormatter._();

  static String _currentCode = AppConstants.defaultCurrencyCode;

  /// Update the active currency code (called when user changes currency)
  static void setActiveCurrency(String code) {
    _currentCode = code;
  }

  /// Get the current currency code
  static String get activeCode => _currentCode;

  /// Get symbol for a currency code
  static String symbolFor(String code) {
    return AppConstants.supportedCurrencies[code]?['symbol'] ?? code;
  }

  /// Get name for a currency code
  static String nameFor(String code) {
    return AppConstants.supportedCurrencies[code]?['name'] ?? code;
  }

  /// Get locale for a currency code
  static String localeFor(String code) {
    return AppConstants.supportedCurrencies[code]?['locale'] ?? 'en_US';
  }

  /// Format amount with the current or specified currency
  static String format(double amount, {String? code}) {
    final c = code ?? _currentCode;
    final sym = symbolFor(c);
    final loc = localeFor(c);
    final formatter = NumberFormat.currency(
      locale: loc,
      symbol: sym,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format as plain number: 1,234.56
  static String formatPlain(double amount) {
    return NumberFormat('#,##0.00', 'en_GH').format(amount);
  }

  /// Compact format: GH₵ 1.2K, GH₵ 3.4M
  static String formatCompact(double amount, {String? code}) {
    final c = code ?? _currentCode;
    final sym = symbolFor(c);
    if (amount >= 1000000) {
      return '$sym ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$sym ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, code: c);
  }

  /// Backward-compatible alias
  static String formatGhs(double amount, {String? code}) {
    return format(amount, code: code);
  }

  /// Parse a currency string back to double
  static double? parse(String text, {String? code}) {
    final c = code ?? _currentCode;
    final sym = symbolFor(c);
    final cleaned = text
        .replaceAll(sym, '')
        .replaceAll(c, '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(cleaned);
  }
}
