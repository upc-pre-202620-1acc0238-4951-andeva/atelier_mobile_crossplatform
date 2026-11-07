package com.andeva.atelier.mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var obdSpp: ObdSppBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        obdSpp = ObdSppBridge(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        obdSpp?.dispose()
        obdSpp = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
