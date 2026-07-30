import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PocketLedger Precision Utilitarian Design System - Typography
/// Inter for UI + JetBrains Mono for numeric data
abstract final class AppTypography {
  static final TextTheme _lightTextTheme = _buildTextTheme(
    ThemeData.light().textTheme,
    const Color(0xFF191C1E),
  );

  static final TextTheme _darkTextTheme = _buildTextTheme(
    ThemeData.dark().textTheme,
    const Color(0xFFE1E3E5),
  );

  static TextTheme get lightTextTheme => _lightTextTheme;
  static TextTheme get darkTextTheme => _darkTextTheme;

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return GoogleFonts.interTextTheme(base).apply(
      bodyColor: color,
      displayColor: color,
    );
  }

  // ─── Display (Precision Utilitarian) ───
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    height: 1.17,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    height: 1.1,
  );

  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.22,
  );

  // ─── Headline ───
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    height: 1.29,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ─── Title ───
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.43,
  );

  // ─── Label ───
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.43,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    height: 1.33,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    height: 1.33,
  );

  // ─── Body ───
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.43,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  // ─── Numeric (JetBrains Mono) ───
  static TextStyle labelNumeric = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.43,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle currencyDisplay = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    height: 1.1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle transactionAmount = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.43,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle balanceLarge = GoogleFonts.jetBrainsMono(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.25,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
