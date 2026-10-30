package com.marcgelwertz.alphatrack

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

/**
 * Creates [CHANNEL_ID] on every process start, including a start caused by
 * an incoming push while no activity is running. Calling
 * [NotificationManager.createNotificationChannel] again updates the name and
 * description only; Android keeps the user's importance and sound.
 *
 * The id matches the manifest default and the backend payload
 * (`ANDROID_NOTIFICATION_CHANNEL_ID` in time-tracker).
 */
class AlphaTrackApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        )
        channel.description = getString(R.string.notification_channel_description)
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        const val CHANNEL_ID = "alpha_track_default_channel"
    }
}
