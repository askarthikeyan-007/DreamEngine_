package com.example.dream_engine_ai

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.app.ActivityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dream_engine_ai/hardware"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHardwareStats" -> {
                    val stats = mutableMapOf<String, Any>()
                    
                    // RAM Capacity & available RAM
                    try {
                        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memoryInfo = ActivityManager.MemoryInfo()
                        activityManager.getMemoryInfo(memoryInfo)
                        stats["totalRam"] = memoryInfo.totalMem // bytes
                        stats["availRam"] = memoryInfo.availMem // bytes
                    } catch (e: Exception) {
                        stats["totalRam"] = -1L
                        stats["availRam"] = -1L
                    }

                    // Temperature (battery temperature is the standard Android way to get device temp)
                    try {
                        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                        val batteryStatus = registerReceiver(null, intentFilter)
                        val temp = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
                        stats["temperature"] = temp / 10.0 // Convert to Celsius
                    } catch (e: Exception) {
                        stats["temperature"] = 0.0
                    }

                    result.success(stats)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
