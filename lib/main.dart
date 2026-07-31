import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_ledger/core/theme/app_theme.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/providers.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/data/repositories/transaction_repository.dart';
import 'package:pocket_ledger/features/auto_capture/data/auto_capture_service.dart';
import 'package:pocket_ledger/features/auto_capture/data/ghana_transaction_parser.dart';
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

  // Record install date on first launch
  String? installDateStr = prefs.getString(AppConstants.keyInstallDate);
  if (installDateStr == null) {
    installDateStr = DateTime.now().toIso8601String();
    await prefs.setString(AppConstants.keyInstallDate, installDateStr);
    developer.log('First launch — install date recorded: $installDateStr', name: 'PocketLedger');
  }
  final installDate = DateTime.parse(installDateStr);

  // Initialize notification listener & auto-capture
  final autoCaptureService = AutoCaptureService();
  await autoCaptureService.initialize();
  developer.log('Auto-capture service initialized', name: 'PocketLedger');

  // Subscribe to real-time transaction stream — auto-import to DB
  final txRepo = TransactionRepository(db);
  autoCaptureService.onTransactionCaptured.listen((parsed) async {
    // Only import transactions from install date onwards
    if (parsed.timestamp.isBefore(installDate)) {
      developer.log('Skipping pre-install transaction: ${parsed.formattedAmount}', name: 'PocketLedger');
      return;
    }
    developer.log('Auto-importing: ${parsed.formattedAmount} ${parsed.type.name} via ${parsed.provider}',
        name: 'PocketLedger');
    final id = await txRepo.addAutoCapturedTransaction(parsed);
    if (id != null) {
      developer.log('Saved transaction #$id', name: 'PocketLedger');
    } else {
      developer.log('Duplicate skipped', name: 'PocketLedger');
    }
  });

  // Scan SMS inbox on startup to catch transactions missed while app was closed
  _scanMissedSms(autoCaptureService, txRepo, installDate);

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

/// Scan recent SMS on startup to capture any transactions missed while app was closed.
/// Only imports messages from install date onwards. Runs in background.
void _scanMissedSms(AutoCaptureService service, TransactionRepository txRepo, DateTime installDate) async {
  try {
    final hasPermission = await service.isSmsPermissionGranted();
    if (!hasPermission) return;

    developer.log('Scanning SMS inbox for missed transactions (from $installDate)...', name: 'PocketLedger');
    final messages = await service.readRawSms(limit: 100);

    var imported = 0;
    var skipped = 0;
    for (final msg in messages) {
      // Filter by install date
      final msgDate = DateTime.fromMillisecondsSinceEpoch(msg['date'] as int? ?? 0);
      if (msgDate.isBefore(installDate)) {
        skipped++;
        continue;
      }

      final body = msg['body'] as String? ?? '';
      final parsed = GhanaTransactionParser.parse(body);
      if (parsed != null) {
        final id = await txRepo.addAutoCapturedTransaction(parsed);
        if (id != null) imported++;
      }
    }
    developer.log('Startup SMS scan: ${messages.length} read, $skipped pre-install skipped, $imported imported', name: 'PocketLedger');
  } catch (e) {
    developer.log('Startup SMS scan failed: $e', name: 'PocketLedger');
  }
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
