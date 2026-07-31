package com.pocketledger.pocket_ledger

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * PocketLedger NotificationListenerService
 *
 * Intercepts system notifications from Ghanaian mobile money and bank apps
 * and forwards them to Flutter via MethodChannel for local RegEx parsing.
 * 100% offline — no data leaves the device.
 */
class PocketLedgerNotificationService : NotificationListenerService() {

    companion object {
        private const val TAG = "PocketLedgerNL"
        var methodChannel: MethodChannel? = null

        // Known package names for Ghana MoMo and bank apps
        private val KNOWN_PACKAGES = setOf(
            // MTN MoMo
            "com.mtn.momo",
            "com.mtn.mobilemoney",
            "com.mtn.momoagent",
            // Telecel (formerly Vodafone)
            "com.vodafone.cash",
            "com.telecel.cash",
            // AT Money (AirtelTigo)
            "com.airteltigo.money",
            "com.atmoney",
            // GCB Bank
            "com.gcb.gcbmobile",
            "com.ghanapostbank",
            // Ecobank
            "com.ecobank.transflex",
            "com.ecobank.mobile",
            // Fidelity Bank
            "com.fidelity.fidelitybank",
            // Stanbic Bank
            "com.stanbic.ibtc",
            // Absa Bank
            "com.absa.absamobile",
            // CalBank
            "com.calbank.calbank",
            // Republic Bank
            "republicbank.mobile",
            // Standard Chartered
            "com.sc.android.scbmobile",
            // UBA
            "com.uba.group.ubamobile",
            // Zenith Bank
            "com.zenithbank.mobile",
            // Consolidated Bank Ghana
            "com.cbg.mobile",
            // Prudential Bank
            "com.prudentialbank.mobile",
            // First Atlantic Bank
            "com.firstatlantic.mobile",
        )
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.i(TAG, "NotificationListenerService connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.w(TAG, "NotificationListenerService disconnected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let { notification ->
            val packageName = notification.packageName
            Log.d(TAG, "Notification posted from: $packageName")

            // Filter: only process notifications from known financial apps
            if (packageName in KNOWN_PACKAGES) {
                Log.i(TAG, "Matched known financial app: $packageName")
                val notificationData = extractNotificationData(notification)
                sendToFlutter(notificationData)
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // No-op: we only care about incoming notifications
    }

    private fun extractNotificationData(sbn: StatusBarNotification): Map<String, Any?> {
        val notification = sbn.notification
        val extras = notification.extras

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() ?: ""

        Log.d(TAG, "Extracted data: title=$title, text=$text, bigText=$bigText")

        return mapOf(
            "packageName" to sbn.packageName,
            "title" to title,
            "text" to text,
            "bigText" to bigText,
            "subText" to subText,
            "timestamp" to sbn.postTime,
        )
    }

    private fun sendToFlutter(data: Map<String, Any?>) {
        val channel = methodChannel
        if (channel == null) {
            Log.w(TAG, "MethodChannel is null — Flutter engine not ready yet. Notification dropped.")
            return
        }
        try {
            Log.d(TAG, "Sending notification to Flutter via MethodChannel")
            channel.invokeMethod("onNotificationPosted", data)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send notification to Flutter: ${e.message}")
        }
    }
}
