package com.kvlkstudio.plokee

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var multicastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
        super.onDestroy()
    }
}
