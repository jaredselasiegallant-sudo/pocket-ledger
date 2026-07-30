import 'package:flutter/material.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';

/// PocketLedger Precision Utilitarian Design System - Theme Configuration
/// Corporate Modernism + Systematic Minimalism
abstract final class AppTheme {
  static ThemeData lightTheme({ColorScheme? dynamicScheme}) {
    final colorScheme = dynamicScheme ??
        ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.lightPrimary,
          onPrimary: AppColors.lightOnPrimary,
          primaryContainer: AppColors.lightPrimaryContainer,
          onPrimaryContainer: AppColors.lightOnPrimaryContainer,
          secondary: AppColors.lightSecondary,
          onSecondary: AppColors.lightOnSecondary,
          secondaryContainer: AppColors.lightSecondaryContainer,
          onSecondaryContainer: AppColors.lightOnSecondaryContainer,
          tertiary: AppColors.lightTertiary,
          onTertiary: AppColors.lightOnTertiary,
          tertiaryContainer: AppColors.lightTertiaryContainer,
          onTertiaryContainer: AppColors.lightOnTertiaryContainer,
          error: AppColors.lightError,
          onError: AppColors.lightOnError,
          errorContainer: AppColors.lightErrorContainer,
          onErrorContainer: AppColors.lightOnErrorContainer,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOnSurface,
          onSurfaceVariant: AppColors.lightOnSurfaceVariant,
          outline: AppColors.lightOutline,
          outlineVariant: AppColors.lightOutlineVariant,
          inverseSurface: AppColors.lightInverseSurface,
          onInverseSurface: AppColors.lightInverseOnSurface,
          inversePrimary: AppColors.lightInversePrimary,
          surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
          surfaceContainerLow: AppColors.lightSurfaceContainerLow,
          surfaceContainer: AppColors.lightSurfaceContainer,
          surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
          surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
          surfaceDim: AppColors.lightSurfaceDim,
          surfaceBright: AppColors.lightSurfaceBright,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.lightTextTheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // ─── Card Theme (Level 1 Tonal Layer) ───
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ─── App Bar ───
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // ─── Bottom Navigation ───
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: colorScheme.onSurface,
            );
          }
          return AppTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // ─── Floating Action Button ───
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ─── Input Decoration (40px height, system-fixed) ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        labelStyle: AppTypography.labelMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ─── Primary Button (Deep Navy) ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      // ─── Filled Button ───
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.onTertiaryContainer,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      // ─── Outlined Button ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),

      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),

      // ─── Chip Theme ───
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedColor: colorScheme.secondaryContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ─── Dialog Theme ───
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme({ColorScheme? dynamicScheme}) {
    final colorScheme = dynamicScheme ??
        ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkOnPrimary,
          primaryContainer: AppColors.darkPrimaryContainer,
          onPrimaryContainer: AppColors.darkOnPrimaryContainer,
          secondary: AppColors.darkSecondary,
          onSecondary: AppColors.darkOnSecondary,
          secondaryContainer: AppColors.darkSecondaryContainer,
          onSecondaryContainer: AppColors.darkOnSecondaryContainer,
          tertiary: AppColors.darkTertiary,
          onTertiary: AppColors.darkOnTertiary,
          tertiaryContainer: AppColors.darkTertiaryContainer,
          onTertiaryContainer: AppColors.darkOnTertiaryContainer,
          error: AppColors.darkError,
          onError: AppColors.darkOnError,
          errorContainer: AppColors.darkErrorContainer,
          onErrorContainer: AppColors.darkOnErrorContainer,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          onSurfaceVariant: AppColors.darkOnSurfaceVariant,
          outline: AppColors.darkOutline,
          outlineVariant: AppColors.darkOutlineVariant,
          inverseSurface: AppColors.darkInverseSurface,
          onInverseSurface: AppColors.darkInverseOnSurface,
          inversePrimary: AppColors.darkInversePrimary,
          surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
          surfaceContainerLow: AppColors.darkSurfaceContainerLow,
          surfaceContainer: AppColors.darkSurfaceContainer,
          surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
          surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
          surfaceDim: AppColors.darkSurfaceDim,
          surfaceBright: AppColors.darkSurfaceBright,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.darkTextTheme,
      scaffoldBackgroundColor: colorScheme.surface,

      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: colorScheme.onSurface,
            );
          }
          return AppTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        labelStyle: AppTypography.labelMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.onTertiaryContainer,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedColor: colorScheme.secondaryContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
