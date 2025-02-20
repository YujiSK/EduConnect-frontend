package com.example.yourapp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging

class MyFirebaseReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d("MyFirebaseReceiver", "Device rebooted, initializing Firebase and re-subscribing to FCM topics")

            // Firebase の初期化（重要）
            FirebaseApp.initializeApp(context)

            // トピックの再登録
            FirebaseMessaging.getInstance().subscribeToTopic("all_users")
                .addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        Log.d("MyFirebaseReceiver", "Successfully subscribed to FCM topic: all_users")
                    } else {
                        Log.e("MyFirebaseReceiver", "Failed to subscribe to FCM topic", task.exception)
                    }
                }
        }
    }
}
