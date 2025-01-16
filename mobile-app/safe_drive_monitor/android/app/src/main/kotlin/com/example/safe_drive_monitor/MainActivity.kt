package com.example.safe_drive_monitor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.app.Service

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.safe_drive_monitor/background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val serviceIntent = Intent(this, MonitorService::class.java)
                    startForegroundService(serviceIntent)
                    result.success(null)
                }
                "stopService" -> {
                    val serviceIntent = Intent(this, MonitorService::class.java)
                    stopService(serviceIntent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
