package com.cab.drive

import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        @Volatile
        private var mapKitApiKeyApplied = false
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // setApiKey нельзя вызывать после initialize() — иначе FATAL
        // при пересоздании Activity (свёртка / возврат в приложение).
        if (!mapKitApiKeyApplied) {
            MapKitFactory.setApiKey(BuildConfig.YANDEX_MAPS_API_KEY)
            mapKitApiKeyApplied = true
        }
        super.configureFlutterEngine(flutterEngine)
    }
}
