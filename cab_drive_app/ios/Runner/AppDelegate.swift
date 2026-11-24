import UIKit
import Flutter
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // MapKit API key must be set before the Flutter engine / plugins initialize.
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "YandexMapsAPIKey") as? String ?? ""
    if !apiKey.isEmpty {
      YMKMapKit.setApiKey(apiKey)
    }

    // Enable foreground notifications display
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // UIScene-приложения: firebase_messaging может пропустить вызов
    // registerForRemoteNotifications (flutterfire #18555) — делаем сами,
    // иначе getAPNSToken() навсегда null и FCM-токен не регистрируется.
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("[Push] APNs registration failed: %@", error.localizedDescription)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Show notifications when app is in foreground
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}
