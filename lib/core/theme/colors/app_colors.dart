import 'package:flutter/material.dart';

/// PocketLedger Stitch Design System - Color Tokens
/// Based on Material 3 Expressive with Ghana-inspired palette
abstract final class AppColors {
  // ─── Seed Colors ───
  static const Color primarySeed = Color(0xFF006B3F); // Ghana Green
  static const Color secondarySeed = Color(0xFFCE1126); // Ghana Red
  static const Color tertiarySeed = Color(0xFFFCD116); // Ghana Gold

  // ─── Light Theme ───
  static const Color lightPrimary = Color(0xFF006B3F);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFA4F5BA);
  static const Color lightOnPrimaryContainer = Color(0xFF002110);

  static const Color lightSecondary = Color(0xFFCE1126);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFFDAD8);
  static const Color lightOnSecondaryContainer = Color(0xFF410005);

  static const Color lightTertiary = Color(0xFFC99E00);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFDEA6);
  static const Color lightOnTertiaryContainer = Color(0xFF3F2E00);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);

  static const Color lightSurface = Color(0xFFF8FAF5);
  static const Color lightOnSurface = Color(0xFF1A1C19);
  static const Color lightSurfaceVariant = Color(0xFFDCE5DB);
  static const Color lightOnSurfaceVariant = Color(0xFF414941);
  static const Color lightSurfaceContainer = Color(0xFFECF0E8);
  static const Color lightSurfaceContainerLow = Color(0xFFF2F5EE);
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E6DE);
  static const Color lightSurfaceBright = Color(0xFFF8FAF5);
  static const Color lightSurfaceDim = Color(0xFFD9DBD4);

  static const Color lightOutline = Color(0xFF717971);
  static const Color lightOutlineVariant = Color(0xFFC1C9BF);

  static const Color lightInverseSurface = Color(0xFF2F312D);
  static const Color lightInverseOnSurface = Color(0xFFF0F2EB);
  static const Color lightInversePrimary = Color(0xFF89D89F);

  // ─── Dark Theme ───
  static const Color darkPrimary = Color(0xFF89D89F);
  static const Color darkOnPrimary = Color(0xFF00391E);
  static const Color darkPrimaryContainer = Color(0xFF00522E);
  static const Color darkOnPrimaryContainer = Color(0xFFA4F5BA);

  static const Color darkSecondary = Color(0xFFFFB3B0);
  static const Color darkOnSecondary = Color(0xFF69000A);
  static const Color darkSecondaryContainer = Color(0xFF920013);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDAD8);

  static const Color darkTertiary = Color(0xFFE7C018);
  static const Color darkOnTertiary = Color(0xFF423100);
  static const Color darkTertiaryContainer = Color(0xFF614700);
  static const Color darkOnTertiaryContainer = Color(0xFFFFDEA6);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkSurface = Color(0xFF121410);
  static const Color darkOnSurface = Color(0xFFE1E3DC);
  static const Color darkSurfaceVariant = Color(0xFF414941);
  static const Color darkOnSurfaceVariant = Color(0xFFC1C9BF);
  static const Color darkSurfaceContainer = Color(0xFF1E201C);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1C19);
  static const Color darkSurfaceContainerHigh = Color(0xFF292B27);
  static const Color darkSurfaceBright = Color(0xFF373934);
  static const Color darkSurfaceDim = Color(0xFF121410);

  static const Color darkOutline = Color(0xFF8B938A);
  static const Color darkOutlineVariant = Color(0xFF414941);

  static const Color darkInverseSurface = Color(0xFFE1E3DC);
  static const Color darkInverseOnSurface = Color(0xFF2F312D);
  static const Color darkInversePrimary = Color(0xFF006B3F);

  // ─── Semantic Transaction Colors ───
  static const Color income = Color(0xFF00875A);
  static const Color expense = Color(0xFFDE350B);
  static const Color transfer = Color(0xFF0065FF);
  static const Color pending = Color(0xFFFF991F);
  static const Color credit = Color(0xFF36B37E);
  static const Color debit = Color(0xFFFF5630);

  // ─── Category Colors ───
  static const Color food = Color(0xFFFF6D00);
  static const Color transport = Color(0xFF2962FF);
  static const Color utilities = Color(0xFF00BFA5);
  static const Color health = Color(0xFFD50000);
  static const Color education = Color(0xFFAA00FF);
  static const Color entertainment = Color(0xFFFF1744);
  static const Color savings = Color(0xFF00C853);
  static const Color investment = Color(0xFF6200EA);
  static const Color salary = Color(0xFF00B0FF);
  static const Color business = Color(0xFFFFD600);
}
