package com.example.safeher

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.PendingIntent
import android.content.Intent
import android.telephony.SmsManager
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.safeher/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendSms") {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber != null && message != null) {
                        try {
                            sendSMS(phoneNumber, message)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SMS_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Phone number or message is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun sendSMS(phoneNumber: String, message: String) {
        val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            this.getSystemService(SmsManager::class.java)
        } else {
            SmsManager.getDefault()
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            Intent("SMS_SENT"),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        smsManager.sendTextMessage(phoneNumber, null, message, pendingIntent, null)
    }
}
