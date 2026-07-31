import 'dart:async';
import 'dart:developer' as developer;
import 'package:pocket_ledger/features/auto_capture/data/ghana_transaction_parser.dart';
import 'package:pocket_ledger/platform/platform_channel_service.dart';

/// Service that connects the native Android NotificationListenerService
/// and SMS Reader to the Dart-based Ghana Transaction Parser
class AutoCaptureService {
  final PlatformChannelService _platformChannel;

  static final AutoCaptureService _instance = AutoCaptureService._internal();
  factory AutoCaptureService() => _instance;
  AutoCaptureService._internal({PlatformChannelService? platformChannel})
      : _platformChannel = platformChannel ?? PlatformChannelService();

  StreamController<ParsedTransaction>? _transactionController;

  /// Stream of automatically captured transactions
  Stream<ParsedTransaction> get onTransactionCaptured {
    _transactionController ??= StreamController<ParsedTransaction>.broadcast();
    return _transactionController!.stream;
  }

  bool _isInitialized = false;

  /// Initialize the auto-capture system
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    developer.log('Initializing AutoCaptureService...', name: 'AutoCapture');

    // Ensure controller exists
    _transactionController ??= StreamController<ParsedTransaction>.broadcast();

    // Listen for incoming notifications from native
    _platformChannel.onNotificationReceived((data) {
      developer.log('Notification data received in AutoCaptureService', name: 'AutoCapture');
      _processNotificationData(data);
    });

    // Listen for incoming SMS from native
    _platformChannel.onSmsReceived((data) {
      developer.log('SMS data received in AutoCaptureService', name: 'AutoCapture');
      _processSmsData(data);
    });
    developer.log('AutoCaptureService initialized successfully', name: 'AutoCapture');
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
    try {
      final title = data['title'] as String? ?? '';
      final text = data['text'] as String? ?? '';
      final bigText = data['bigText'] as String? ?? '';
      final subText = data['subText'] as String? ?? '';
      final packageName = data['packageName'] as String? ?? '';

      developer.log('Processing notification from: $packageName', name: 'AutoCapture');
      developer.log('  title=$title, text=$text', name: 'AutoCapture');

      final combinedText = ['$title $text $bigText $subText'].join(' ').trim();

      if (combinedText.isNotEmpty) {
        final parsed = GhanaTransactionParser.parse(combinedText);
        if (parsed != null) {
          developer.log('Parsed transaction: ${parsed.formattedAmount} ${parsed.type.name}', name: 'AutoCapture');
          if (_transactionController != null && !_transactionController!.isClosed) {
            _transactionController!.add(parsed);
          }
        } else {
          developer.log('Could not parse transaction from notification text', name: 'AutoCapture');
        }
      } else {
        developer.log('Notification text was empty, skipping', name: 'AutoCapture');
      }
    } catch (e) {
      developer.log('Error processing notification: $e', name: 'AutoCapture');
    }
  }

  void _processSmsData(Map<String, dynamic> data) {
    try {
      final body = data['body'] as String? ?? '';
      final address = data['address'] as String? ?? '';
      developer.log('Processing SMS from: $address', name: 'AutoCapture');
      if (body.isNotEmpty) {
        final parsed = GhanaTransactionParser.parse(body);
        if (parsed != null) {
          developer.log('Parsed SMS transaction: ${parsed.formattedAmount} ${parsed.type.name}', name: 'AutoCapture');
          if (_transactionController != null && !_transactionController!.isClosed) {
            _transactionController!.add(parsed);
          }
        } else {
          developer.log('Could not parse transaction from SMS text', name: 'AutoCapture');
        }
      }
    } catch (e) {
      developer.log('Error processing SMS: $e', name: 'AutoCapture');
    }
  }

  void dispose() {
    _transactionController?.close();
    _transactionController = null;
    _isInitialized = false;
  }
}
