// ShortcutSetup.kt
package com.mehauk.nutritionist

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon

object ShortcutSetup {
    fun createOverlayShortcut(context: Context) {
        val shortcutManager = context.getSystemService(ShortcutManager::class.java)

        val existing = shortcutManager?.dynamicShortcuts?.any { it.id == "overlay_shortcut" } ?: false
        if (existing) return

        val shortcut = ShortcutInfo.Builder(context, "overlay_shortcut")
            .setShortLabel("Overlay")
            .setLongLabel("Show Overlay")
            .setIcon(Icon.createWithResource(context, R.mipmap.ic_launcher))
            .setIntent(
                Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                }
            )
            .build()

        shortcutManager?.requestPinShortcut(shortcut, null)
    }
}
