import UIKit
import Flutter
import GoogleMaps
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyATMi_WzfUnBfhb66_FR8c1Fg_zEwHyaCs")

    // 1. Manually create the window if it's missing
    if self.window == nil {
      self.window = UIWindow(frame: UIScreen.main.bounds)
    }

    // 2. Create a FlutterViewController and set it as the root
    let flutterViewController = FlutterViewController(project: nil, initialRoute: nil, nibName: nil, bundle: nil)
    self.window?.rootViewController = flutterViewController

    GeneratedPluginRegistrant.register(with: self)

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // 3. Force the window into the foreground
    self.window?.makeKeyAndVisible()

    return result
  }
}