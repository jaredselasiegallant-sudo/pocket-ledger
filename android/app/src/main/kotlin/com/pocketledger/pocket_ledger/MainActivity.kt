package com.pocketledger.pocket_ledger

import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val NOTIFICATION_CHANNEL = "com.pocketledger/notification_listener"
    private val SMS_CHANNEL = "com.pocketledger/sms_reader"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ─── Notification Listener Method Channel ───
        val notificationMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATION_CHANNEL
        )
        // Give the service a reference so it can push notifications to Dart
        PocketLedgerNotificationService.methodChannel = notificationMethodChannel

        notificationMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isEnabled" -> {
                    result.success(isNotificationListenerEnabled())
                }
                "openSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ─── SMS Reader Method Channel ───
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> {
                        result.success(hasSmsPermission())
                    }
                    "requestPermission" -> {
                        requestSmsPermission()
                        result.success(null)
                    }
                    "readInbox" -> {
                        val limit = call.argument<Int>("limit") ?: 100
                        val messages = readSmsInbox(limit)
                        result.success(messages)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val pkgName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":")
            for (name in names) {
                val cn = android.content.ComponentName.unflattenFromString(name)
                if (cn != null && TextUtils.equals(pkgName, cn.packageName)) {
                    return true
                }
            }
        }
        return false
    }

    private fun hasSmsPermission(): Boolean {
        return checkSelfPermission(android.Manifest.permission.READ_SMS) ==
                android.content.pm.PackageManager.PERMISSION_GRANTED
    }

    private fun requestSmsPermission() {
        requestPermissions(arrayOf(android.Manifest.permission.READ_SMS), 1001)
    }

    private fun readSmsInbox(limit: Int): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        val uri = android.net.Uri.parse("content://sms/inbox")
        val cursor = contentResolver.query(
            uri,
            arrayOf("_id", "address", "body", "date", "read"),
            null,
            null,
            "date DESC"
        )

        cursor?.use {
            var count = 0
            val idIndex = it.getColumnIndex("_id")
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")
            val readIndex = it.getColumnIndex("read")

            while (it.moveToNext() && count < limit) {
                messages.add(
                    mapOf(
                        "id" to it.getLong(idIndex),
                        "address" to it.getString(addressIndex),
                        "body" to it.getString(bodyIndex),
                        "date" to it.getLong(dateIndex),
                        "read" to it.getInt(readIndex),
                    )
                )
                count++
            }
        }

        return messages
    }
}
