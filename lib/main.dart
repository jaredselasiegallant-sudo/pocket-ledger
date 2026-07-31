import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_ledger/core/theme/app_theme.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/providers.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/features/auto_capture/data/auto_capture_service.dart';
import 'package:pocket_ledger/features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString(AppConstants.keyThemeMode);
  final savedCurrency = prefs.getString(AppConstants.keyCurrencyCode);

  ThemeMode initialTheme = ThemeMode.system;
  if (savedTheme == 'light') initialTheme = ThemeMode.light;
  if (savedTheme == 'dark') initialTheme = ThemeMode.dark;

  final initialCurrency = savedCurrency ?? AppConstants.defaultCurrencyCode;
  CurrencyFormatter.setActiveCurrency(initialCurrency);

  // Initialize database eagerly
  final db = AppDatabase();
  await db.customSelect('SELECT 1').get();

  // Initialize notification listener & auto-capture
  final autoCaptureService = AutoCaptureService();
  await autoCaptureService.initialize();
  developer.log('Auto-capture service initialized', name: 'PocketLedger');

  final themeModeNotifier = ThemeModeNotifier()..init(initialTheme);
  final currencyNotifier = CurrencyNotifier()..init(initialCurrency);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themeModeProvider.overrideWith((ref) => themeModeNotifier),
        currencyProvider.overrideWith((ref) => currencyNotifier),
      ],
      child: const PocketLedgerApp(),
    ),
  );
}

class PocketLedgerApp extends ConsumerWidget {
  const PocketLedgerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

/// Theme mode provider — persisted via SharedPreferences
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void init(ThemeMode saved) {
    state = saved;
  }

  void setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(AppConstants.keyThemeMode, value);
  }
}
