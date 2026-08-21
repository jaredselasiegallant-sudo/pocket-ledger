package com.pocketledger.pocket_ledger

import android.app.Notification
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel

/**
 * PocketLedger NotificationListenerService
 *
 * Intercepts system notifications from Ghanaian mobile money and bank apps:
 * - MTN Mobile Money / MoMo
 * - Telecel Cash
 * - AT Money
 * - GCB, Ecobank, Fidelity, Stanbic, etc.
 *
 * Passes raw notification text to Flutter via EventChannel for local RegEx parsing.
 * No data leaves the device — 100% offline processing.
 */
class PocketLedgerNotificationService : NotificationListenerService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null

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

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let { notification ->
            val packageName = notification.packageName

            // Filter: only process notifications from known financial apps
            if (packageName in KNOWN_PACKAGES) {
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
        val summaryText = extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT)?.toString() ?: ""

        return mapOf(
            "packageName" to sbn.packageName,
            "title" to title,
            "text" to text,
            "bigText" to bigText,
            "subText" to subText,
            "summaryText" to summaryText,
            "timestamp" to sbn.postTime,
            "category" to notification.category,
            "priority" to notification.priority,
        )
    }

    private fun sendToFlutter(data: Map<String, Any?>) {
        try {
            eventSink?.success(data)
        } catch (e: Exception) {
            // Flutter engine may not be ready yet
            e.printStackTrace()
        }
    }
}
