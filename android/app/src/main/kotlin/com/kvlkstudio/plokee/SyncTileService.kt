package com.kvlkstudio.plokee

import android.annotation.TargetApi
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick settings tile that pauses and resumes clipboard sync.
 *
 * Pausing sync is the one thing people reach for in a hurry — before pasting
 * something they do not want mirrored to a shared laptop — and it should not
 * require finding and opening the app. The tile owns no state of its own: it
 * reads and writes the same preference the app does (see [SyncPrefs]), so the
 * two can never disagree, whether the app is running or not.
 *
 * Requires API 24; on older devices the class is simply never loaded.
 */
@TargetApi(24)
class SyncTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        render(SyncPrefs.isEnabled(this))
    }

    override fun onClick() {
        super.onClick()
        val next = !SyncPrefs.isEnabled(this)
        SyncPrefs.setEnabled(this, next)
        render(next)
    }

    private fun render(enabled: Boolean) {
        val tile = qsTile ?: return
        tile.state = if (enabled) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = getString(R.string.tile_label)
        tile.contentDescription = getString(
            if (enabled) R.string.tile_state_on else R.string.tile_state_off
        )
        tile.updateTile()
    }
}
