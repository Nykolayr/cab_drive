import UIKit
import Flutter
import GoogleMaps
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDylrUtlzkO48VEkD-fFW8aHspMnZOv2CU")

    let apiKey = Bundle.main.object(forInfoDictionaryKey: "YandexMapsAPIKey") as? String ?? ""
    if !apiKey.isEmpty {
      YMKMapKit.setApiKey(apiKey)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
