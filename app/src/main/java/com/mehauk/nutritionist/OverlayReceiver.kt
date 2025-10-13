package com.mehauk.nutritionist

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.core.content.ContextCompat

class OverlayReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (Settings.canDrawOverlays(context)) {
            val serviceIntent = Intent(context, OverlayService::class.java)
            ContextCompat.startForegroundService(context, serviceIntent)
        }
    }
}
