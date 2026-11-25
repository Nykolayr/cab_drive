# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn org.bouncycastle.jce.provider.BouncyCastleProvider
-dontwarn org.bouncycastle.pqc.jcajce.provider.BouncyCastlePQCProvider
-keep class org.xmlpull.v1.** { *; }

# --- Flutter engine & plugins ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# --- App classes (legacy package) ---
-keep class com.example.my_project.** { *; }

# --- JNI entry points of plugins ---
-keepclasseswithmembernames class * { native <methods>; }

# --- Firebase / Google services ---
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.** { *; }
# splitcompat/splitinstall отсутствуют в classpath (deferred components не используются),
# Flutter engine их референсит — missing_rules.txt: dontwarn на весь пакет
-dontwarn com.google.android.play.core.**
-keep class com.google.android.datatransport.** { *; }
-keep class com.google.firebase.components.** { *; }
-dontwarn com.google.firebase.**

# --- Kotlin metadata / coroutines (kotlinx.serialization в плагинах) ---
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata { *; }
-keep class kotlin.coroutines.** { *; }
-keepclassmembers class kotlinx.serialization.** { *; }
-keepclasseswithmembers class * { @kotlinx.serialization.Serializable <fields>; }
-dontwarn kotlinx.**

# --- Yandex MapKit ---
-keep class com.yandex.** { *; }
-keep class ru.yandex.** { *; }
-keep class com.unact.** { *; }
-dontwarn com.yandex.**

# --- WebView / JS-interfaces плагинов ---
-keepclassmembers class * { @android.webkit.JavascriptInterface <methods>; }

# --- awesome_notifications (receivers/services в манифесте; без keep пуши молча не показываются) ---
-keep class me.carda.** { *; }
-dontwarn me.carda.**

# --- geolocator / permission_handler (foreground location service — трекинг водителя) ---
-keep class com.baseflow.** { *; }
-dontwarn com.baseflow.**

# --- method-channel плагины проекта (страховка от рефлексии) ---
-keep class com.tekartik.sqflite.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.aboutyou.dart_packages.sign_in_with_apple.** { *; }
-dontwarn com.tekartik.sqflite.**
-dontwarn com.mr.flutter.plugin.filepicker.**
-dontwarn dev.fluttercommunity.plus.**
-dontwarn com.it_nomads.**
-dontwarn com.aboutyou.**
