import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
     GMSServices.provideAPIKey("AIzaSyBimNpnFGJ_dCM_d6g2JBoF8Dxa5BWC5B8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
