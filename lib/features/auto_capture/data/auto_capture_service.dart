import 'dart:async';
import 'package:pocket_ledger/features/auto_capture/data/ghana_transaction_parser.dart';
import 'package:pocket_ledger/platform/platform_channel_service.dart';

/// Service that connects the native Android NotificationListenerService
/// and SMS Reader to the Dart-based Ghana Transaction Parser
class AutoCaptureService {
  final PlatformChannelService _platformChannel = PlatformChannelService();

  static final AutoCaptureService _instance = AutoCaptureService._internal();
  factory AutoCaptureService() => _instance;
  AutoCaptureService._internal();

  final _transactionController =
      StreamController<ParsedTransaction>.broadcast();

  /// Stream of automatically captured transactions
  Stream<ParsedTransaction> get onTransactionCaptured =>
      _transactionController.stream;

  bool _isInitialized = false;

  /// Initialize the auto-capture system
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen for incoming notifications from native
    _platformChannel.onNotificationReceived((data) {
      _processNotificationData(data);
    });

    // Listen for incoming SMS from native
    _platformChannel.onSmsReceived((data) {
      _processSmsData(data);
    });
  }

  /// Check if notification listener is enabled
  Future<bool> isNotificationListenerEnabled() async {
    return await _platformChannel.isNotificationListenerEnabled();
  }

  /// Open notification listener settings
  Future<void> openNotificationSettings() async {
    await _platformChannel.openNotificationListenerSettings();
  }

  /// Check SMS permission
  Future<bool> isSmsPermissionGranted() async {
    return await _platformChannel.isSmsPermissionGranted();
  }

  /// Request SMS permission
  Future<void> requestSmsPermission() async {
    await _platformChannel.requestSmsPermission();
  }

  /// Scan SMS inbox for historical transactions
  Future<List<ParsedTransaction>> scanSmsInbox({int limit = 100}) async {
    final messages = await _platformChannel.readSmsInbox(limit: limit);

    final transactions = <ParsedTransaction>[];
    for (final msg in messages) {
      final body = msg['body'] as String? ?? '';
      final parsed = GhanaTransactionParser.parse(body);
      if (parsed != null) {
        transactions.add(parsed);
      }
    }

    return transactions;
  }

  void _processNotificationData(Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final text = data['text'] as String? ?? '';
    final bigText = data['bigText'] as String? ?? '';
    final subText = data['subText'] as String? ?? '';

    // Combine all notification text fields for parsing
    final combinedText = ['$title $text $bigText $subText'].join(' ').trim();

    if (combinedText.isNotEmpty) {
      final parsed = GhanaTransactionParser.parse(combinedText);
      if (parsed != null) {
        _transactionController.add(parsed);
      }
    }
  }

  void _processSmsData(Map<String, dynamic> data) {
    final body = data['body'] as String? ?? '';
    if (body.isNotEmpty) {
      final parsed = GhanaTransactionParser.parse(body);
      if (parsed != null) {
        _transactionController.add(parsed);
      }
    }
  }

  void dispose() {
    _transactionController.close();
    _isInitialized = false;
  }
}
