package com.oynika.app

import android.view.WindowManager
import android.view.Surface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "oynika/who_motion")
            .setMethodCallHandler { call, result ->
                if (call.method == "landscapeUpSign") {
                    @Suppress("DEPRECATION")
                    val rotation = windowManager.defaultDisplay.rotation
                    result.success(when (rotation) {
                        Surface.ROTATION_90 -> 1.0
                        Surface.ROTATION_270 -> -1.0
                        else -> null
                    })
                } else result.notImplemented()
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "oynika/undercover_privacy")
            .setMethodCallHandler { call, result ->
                val secure = call.arguments as? Boolean
                if (call.method != "setSecure" || secure == null) {
                    result.notImplemented()
                } else {
                    if (secure) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
            }
    }
}
