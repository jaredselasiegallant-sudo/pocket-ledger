package com.pocketledger.pocket_ledger

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * Receives incoming SMS messages in real-time and forwards them to Flutter
 * via the same MethodChannel used by the SMS Reader.
 *
 * Only processes messages from senders that look like financial institutions
 * (shortcodes, known bank/MoMo numbers).
 */
class SmsReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "PocketLedgerSMS"
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        // Group messages by sender (multi-part SMS)
        val grouped = mutableMapOf<String, StringBuilder>()
        for (msg in messages) {
            val sender = msg.displayOriginatingAddress ?: msg.originatingAddress ?: ""
            grouped.getOrPut(sender) { StringBuilder() }.append(msg.messageBody ?: "")
        }

        for ((sender, body) in grouped) {
            val text = body.toString()
            Log.d(TAG, "SMS received from: $sender (${text.length} chars)")

            val data = mapOf(
                "address" to sender,
                "body" to text,
                "date" to System.currentTimeMillis(),
            )

            sendToFlutter(data)
        }
    }

    private fun sendToFlutter(data: Map<String, Any?>) {
        val channel = methodChannel
        if (channel == null) {
            Log.w(TAG, "MethodChannel is null — Flutter engine not ready. SMS dropped.")
            return
        }
        try {
            Log.d(TAG, "Sending SMS to Flutter via MethodChannel")
            channel.invokeMethod("onSmsReceived", data)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send SMS to Flutter: ${e.message}")
        }
    }
}
