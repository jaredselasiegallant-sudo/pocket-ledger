/// PocketLedger Application Constants
abstract final class AppConstants {
  // ─── App Info ───
  static const String appName = 'PocketLedger';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ─── Default Currency ───
  static const String defaultCurrencyCode = 'GHS';
  static const String defaultCurrencySymbol = 'GH₵';
  static const String defaultCurrencyName = 'Ghana Cedi';

  // ─── Database ───
  static const String dbName = 'pocket_ledger.db';
  static const int dbVersion = 1;

  // ─── SharedPreferences Keys ───
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrencyCode = 'currency_code';
  static const String keyUserId = 'user_id';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keySmsReaderEnabled = 'sms_reader_enabled';

  // ─── Platform Channel Names ───
  static const String notificationListenerChannel =
      'com.pocketledger/notification_listener';
  static const String smsReaderChannel = 'com.pocketledger/sms_reader';
  static const String hotkeyChannel = 'com.pocketledger/hotkey';

  // ─── Transaction Categories ───
  static const List<String> defaultCategories = [
    'Food & Dining',
    'Transport',
    'Utilities',
    'Health',
    'Education',
    'Entertainment',
    'Shopping',
    'Savings',
    'Investment',
    'Salary',
    'Business',
    'Gifts',
    'Rent',
    'Communication',
    'Other',
  ];

  // ─── MoMo / Bank Keywords ───
  static const List<String> mobileMoneyProviders = [
    'MTN MoMo',
    'MTN Mobile Money',
    'Telecel Cash',
    'AT Money',
    'Vodafone Cash',
  ];

  static const List<String> bankProviders = [
    'GCB',
    'Ecobank',
    'Fidelity',
    'Stanbic',
    'Absa',
    'CalBank',
    'Republic Bank',
    'SCB',
    'UBA',
    'Zenith',
    'Consolidated Bank',
    'Prudential Bank',
    'First Atlantic',
  ];

  // ─── Exchange Rates (Offline Matrix) ───
  static const Map<String, double> offlineExchangeRates = {
    'USD': 15.20,
    'EUR': 16.50,
    'GBP': 19.30,
    'NGN': 0.098,
    'KES': 0.117,
    'ZAR': 0.83,
    'GHS': 1.0,
  };
}
