package com.marcgelwertz.alphatrack

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.concurrent.atomic.AtomicInteger

/**
 * Posts one banner on [AlphaTrackApplication.CHANNEL_ID] while the app is
 * open. Background and killed messages are left to FCM. The tap opens
 * [MainActivity] with routing extras; it is not an FCM click.
 */
object ForegroundNotifications {
    const val EXTRA_TAP = "alphatrack_notification_tap"
    const val EXTRA_NOTIFICATION_ID = "notificationId"
    const val EXTRA_CATEGORY = "category"
    const val EXTRA_KIND = "kind"
    const val EXTRA_PROJECT_ID = "projectId"

    private val anonymousIds = AtomicInteger(0)

    fun show(
        context: Context,
        title: String,
        body: String,
        notificationId: String?,
        category: String?,
        kind: String?,
        projectId: String?,
    ) {
        val id = androidNotificationId(notificationId)
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_TAP, true)
            if (!notificationId.isNullOrEmpty()) putExtra(EXTRA_NOTIFICATION_ID, notificationId)
            if (!category.isNullOrEmpty()) putExtra(EXTRA_CATEGORY, category)
            if (!kind.isNullOrEmpty()) putExtra(EXTRA_KIND, kind)
            if (!projectId.isNullOrEmpty()) putExtra(EXTRA_PROJECT_ID, projectId)
        }
        val pending = PendingIntent.getActivity(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, AlphaTrackApplication.CHANNEL_ID)
        } else {
            preChannelBuilder(context)
        }
        val notification = builder
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .build()
        context.getSystemService(NotificationManager::class.java).notify(id, notification)
    }

    fun readTap(intent: Intent?): Map<String, String>? {
        if (intent == null || !intent.getBooleanExtra(EXTRA_TAP, false)) return null
        val tap = linkedMapOf<String, String>()
        intent.getStringExtra(EXTRA_NOTIFICATION_ID)?.let { tap[EXTRA_NOTIFICATION_ID] = it }
        intent.getStringExtra(EXTRA_CATEGORY)?.let { tap[EXTRA_CATEGORY] = it }
        intent.getStringExtra(EXTRA_KIND)?.let { tap[EXTRA_KIND] = it }
        intent.getStringExtra(EXTRA_PROJECT_ID)?.let { tap[EXTRA_PROJECT_ID] = it }
        return tap
    }

    fun clearTap(intent: Intent?) {
        if (intent == null) return
        intent.removeExtra(EXTRA_TAP)
        intent.removeExtra(EXTRA_NOTIFICATION_ID)
        intent.removeExtra(EXTRA_CATEGORY)
        intent.removeExtra(EXTRA_KIND)
        intent.removeExtra(EXTRA_PROJECT_ID)
    }

    /** Stable for a real id so a repeat replaces the same banner. Empty ids stay distinct. */
    fun androidNotificationId(notificationId: String?): Int {
        if (notificationId.isNullOrEmpty()) {
            return anonymousIds.incrementAndGet() and 0x7FFFFFFF
        }
        return notificationId.hashCode() and 0x7FFFFFFF
    }

    @Suppress("DEPRECATION")
    private fun preChannelBuilder(context: Context): Notification.Builder {
        return Notification.Builder(context)
            .setPriority(Notification.PRIORITY_HIGH)
            .setDefaults(Notification.DEFAULT_SOUND)
    }
}
