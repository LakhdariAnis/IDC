package com.example.idc_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.pravera.flutter_foreground_task.service.ForegroundService

class ShareReceiverActivity : Activity() {
    companion object {
        private const val TAG = "ShareReceiverActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (intent?.action == Intent.ACTION_SEND &&
            intent.type == "text/plain") {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: ""
            if (text.isNotEmpty()) {
                Log.d(TAG, "Received shared text: ${text.length} chars")
                val data = mapOf<String, Any>(
                    "command" to "clipboard_send",
                    "text" to text
                )
                ForegroundService.sendData(data)
                Log.d(TAG, "Sent to ForegroundService")
            } else {
                Log.d(TAG, "Empty text received, ignoring")
            }
        } else {
            Log.d(TAG, "Unexpected intent, ignoring")
        }

        finish()
    }
}
