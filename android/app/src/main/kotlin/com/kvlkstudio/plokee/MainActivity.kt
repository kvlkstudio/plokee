package com.kvlkstudio.plokee

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var multicastLock: WifiManager.MulticastLock? = null
    private var tileChannel: MethodChannel? = null
    private var syncReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // The quick settings tile writes the shared preference and broadcasts.
        // Dart is told immediately so a running app reacts to the tile in the
        // same moment it is tapped; if the process is gone, the preference it
        // wrote is read at the next launch instead.
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.kvlkstudio.plokee/tile"
        )
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isSyncEnabled" -> result.success(SyncPrefs.isEnabled(this))
                "setSyncEnabled" -> {
                    SyncPrefs.setEnabled(this, call.arguments as? Boolean ?: true)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        tileChannel = channel
        registerSyncReceiver()

        // Android drops multicast packets on a dozing Wi-Fi interface unless a
        // MulticastLock is held, which made UDP discovery unreliable even with
        // CHANGE_WIFI_MULTICAST_STATE declared. Dart takes the lock while
        // discovery runs and releases it on stop, so it costs battery only
        // while syncing.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.kvlkstudio.plokee/multicast"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquire" -> result.success(acquireLock())
                "release" -> {
                    releaseLock()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun registerSyncReceiver() {
        if (syncReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val enabled = intent?.getBooleanExtra(SyncPrefs.EXTRA_ENABLED, true) ?: return
                tileChannel?.invokeMethod("syncChanged", enabled)
            }
        }
        val filter = IntentFilter(SyncPrefs.ACTION_SYNC_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(receiver, filter)
        }
        syncReceiver = receiver
    }

    private fun acquireLock(): Boolean {
        if (multicastLock?.isHeld == true) return true
        return try {
            val wifi =
                applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val lock = wifi.createMulticastLock("plokee-discovery").apply {
                setReferenceCounted(false)
                acquire()
            }
            multicastLock = lock
            lock.isHeld
        } catch (_: Exception) {
            false
        }
    }

    private fun releaseLock() {
        try {
            multicastLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {
            // Already released, or Wi-Fi went away.
        }
        multicastLock = null
    }

    override fun onDestroy() {
        releaseLock()
        syncReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: IllegalArgumentException) {
                // Already gone with the context.
            }
        }
        syncReceiver = null
        tileChannel = null
        super.onDestroy()
    }
}
