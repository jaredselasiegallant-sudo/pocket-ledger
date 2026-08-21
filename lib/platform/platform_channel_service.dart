import 'package:flutter/services.dart';

/// Platform Channel service for native Android communication
/// Handles NotificationListenerService and SMS Reader bridges
class PlatformChannelService {
  static const _notificationChannel = MethodChannel(
    'com.pocketledger/notification_listener',
  );

  static const _smsChannel = MethodChannel(
    'com.pocketledger/sms_reader',
  );

  static const _hotkeyChannel = MethodChannel(
    'com.pocketledger/hotkey',
  );

  static final PlatformChannelService _instance =
      PlatformChannelService._internal();
  factory PlatformChannelService() => _instance;
  PlatformChannelService._internal();

  // ─── Notification Listener ───
  Future<bool> isNotificationListenerEnabled() async {
    try {
      final result = await _notificationChannel.invokeMethod<bool>(
        'isEnabled',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openNotificationListenerSettings() async {
    try {
      await _notificationChannel.invokeMethod('openSettings');
    } on PlatformException {
      // Handle error
    }
  }

  /// Set up callback for incoming notifications
  void onNotificationReceived(void Function(Map<String, dynamic> data) callback) {
    _notificationChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationPosted') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        callback(data);
      }
      return null;
    });
  }

  // ─── SMS Reader ───
  Future<bool> isSmsPermissionGranted() async {
    try {
      final result = await _smsChannel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> requestSmsPermission() async {
    try {
      await _smsChannel.invokeMethod('requestPermission');
    } on PlatformException {
      // Handle error
    }
  }

  Future<List<Map<String, dynamic>>> readSmsInbox({int limit = 100}) async {
    try {
      final result = await _smsChannel.invokeMethod<List>(
        'readInbox',
        {'limit': limit},
      );
      return result?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    } on PlatformException {
      return [];
    }
  }

  void onSmsReceived(void Function(Map<String, dynamic> data) callback) {
    _smsChannel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        callback(data);
      }
      return null;
    });
  }

  // ─── Desktop Hotkey (Windows) ───
  Future<void> registerGlobalHotkey({String hotkey = 'alt+space'}) async {
    try {
      await _hotkeyChannel.invokeMethod('register', {'hotkey': hotkey});
    } on PlatformException {
      // Handle error
    }
  }

  void onHotkeyPressed(void Function() callback) {
    _hotkeyChannel.setMethodCallHandler((call) async {
      if (call.method == 'onHotkeyPressed') {
        callback();
      }
      return null;
    });
  }
}
