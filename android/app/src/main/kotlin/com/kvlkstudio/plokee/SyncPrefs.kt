package com.kvlkstudio.plokee

import android.content.Context
import android.content.Intent

/**
 * The one setting that native code shares with Dart: whether sync is on.
 *
 * It lives in the file shared_preferences writes for the Flutter side
 * ("FlutterSharedPreferences", keys prefixed with "flutter."), so the quick
 * settings tile can flip it whether or not the app is running, and the app
 * picks the new value up on its next read. When the process *is* alive a
 * broadcast tells it right away, because a tile that only takes effect at the
 * next launch is not a control.
 */
object SyncPrefs {
    private const val FILE = "FlutterSharedPreferences"
    private const val KEY = "flutter.sync_enabled"

    const val ACTION_SYNC_CHANGED = "com.kvlkstudio.plokee.SYNC_CHANGED"
    const val EXTRA_ENABLED = "enabled"

    fun isEnabled(context: Context): Boolean =
        context.applicationContext
            .getSharedPreferences(FILE, Context.MODE_PRIVATE)
            // Dart defaults this to on when the key is absent; match it, or the
            // tile would show "off" on a fresh install that is in fact syncing.
            .getBoolean(KEY, true)

    /** Writes the new value and tells a running app about it. */
    fun setEnabled(context: Context, enabled: Boolean) {
        val app = context.applicationContext
        app.getSharedPreferences(FILE, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY, enabled)
            .apply()
        app.sendBroadcast(
            Intent(ACTION_SYNC_CHANGED)
                // Keep it inside the app: this is an internal signal, not an
                // invitation for anything else on the device to listen in.
                .setPackage(app.packageName)
                .putExtra(EXTRA_ENABLED, enabled)
        )
    }
}
