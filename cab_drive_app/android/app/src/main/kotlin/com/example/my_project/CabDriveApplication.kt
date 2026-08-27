package com.cab.drive

import android.app.Application
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Один FlutterEngine на процесс: при убийстве Activity (фон / MIUI)
 * Dart-состояние и маршрут сохраняются. Не трогать без задачи про resume.
 */
class CabDriveApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // До создания engine / плагинов карт.
        MapKitFactory.setApiKey(BuildConfig.YANDEX_MAPS_API_KEY)

        val engine = FlutterEngine(this)
        GeneratedPluginRegistrant.registerWith(engine)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault(),
        )
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
    }

    companion object {
        const val ENGINE_ID = "cab_drive_engine"
    }
}
