import Flutter
import UIKit
//import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
//     GMSServices.provideAPIKey("AIzaSyD41k9DaOoiR52wvxDw582I5ktkyL2CdY4")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
