package com.marcgelwertz.alphatrack

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingTap: Map<String, String>? = null
    private var dartReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        dartReady = false
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "show" -> {
                        val args = call.arguments as? Map<*, *>
                        ForegroundNotifications.show(
                            this,
                            args.string("title") ?: "",
                            args.string("body") ?: "",
                            args.string("notificationId"),
                            args.string("category"),
                            args.string("kind"),
                            args.string("projectId"),
                        )
                        result.success(null)
                    }
                    "consumePendingTap" -> {
                        dartReady = true
                        val tap = pendingTap
                        pendingTap = null
                        result.success(tap)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        deliverTap(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        deliverTap(intent)
    }

    private fun deliverTap(intent: Intent?) {
        val tap = ForegroundNotifications.readTap(intent) ?: return
        ForegroundNotifications.clearTap(intent)
        pendingTap = tap
        dispatchPending()
    }

    private fun dispatchPending() {
        val tap = pendingTap ?: return
        val methodChannel = channel ?: return
        if (!dartReady) return
        methodChannel.invokeMethod("onTap", tap, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (pendingTap === tap) pendingTap = null
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}

            override fun notImplemented() {}
        })
    }

    private fun Map<*, *>?.string(key: String): String? {
        val value = this?.get(key) as? String
        return value?.takeIf { it.isNotEmpty() }
    }

    companion object {
        const val CHANNEL = "com.marcgelwertz.alphatrack/foreground_notification"
    }
}
