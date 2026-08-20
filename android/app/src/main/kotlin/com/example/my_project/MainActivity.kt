package com.cab.drive

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

/**
 * Берёт кэшированный engine из [CabDriveApplication].
 * Не уничтожать engine вместе с Activity — иначе после фона старт с нуля.
 * Не трогать без явной задачи про resume / MapKit.
 */
class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get(CabDriveApplication.ENGINE_ID)
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
