package com.example.cbt_quiz_android

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

import android.provider.Settings

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private var CHANNEL = "device/info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            if (call.method == "deviceId") {
                var mid = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                result.success(mid)
            } else {
                result.notImplemented()
            }
        }
        super.configureFlutterEngine(flutterEngine)
    }
}
