package com.appwawe.YDrive

import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey(BuildConfig.YANDEX_MAPS_API_KEY)
        super.configureFlutterEngine(flutterEngine)
    }
}
