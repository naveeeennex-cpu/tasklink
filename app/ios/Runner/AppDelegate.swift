import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps SDK — ⚠️ restrict this key by iOS bundle ID in Google
    // Cloud Console (Credentials → the key → Application restrictions →
    // iOS apps). Otherwise anyone who decompiles the IPA can abuse it.
    GMSServices.provideAPIKey("AIzaSyCRoRzp4kOtaSxQGKOBP4Ke8L1oe8Xn5zA")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
