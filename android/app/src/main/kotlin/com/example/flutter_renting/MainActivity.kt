package com.onezu.rentingEverything

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

import android.util.Log

class MainActivity: FlutterActivity() {

    private val CHANNEL_WECHAT_LOGIN = "com.onezu.rentingEverything/wechat"
    private val CACHED_ENGINE_ID = "com.onezu.rentingEverything/cachedEngine"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // cache flutterEngine for later use
        flutterEngine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(CACHED_ENGINE_ID, flutterEngine)

        var methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_WECHAT_LOGIN);
        methodChannel.setMethodCallHandler {
            call, result ->
            // Note: this method is invoked on the main thread
            if (call.method == "wxLogin") {
                wxLogin()
                result.success(0)
            } else {
                result.notImplemented()
            }

        }
    }

    private fun wxLogin() {
        Log.e("onezu", "hello world from android native code!")
        var flutterEngine = FlutterEngineCache.getInstance().get(CACHED_ENGINE_ID)
        if (flutterEngine != null) {
            var methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_WECHAT_LOGIN)
            methodChannel.invokeMethod("onWXLoginResp", "wx login resp from android")
        }
    }
}
