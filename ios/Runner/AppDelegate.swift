import UIKit
import Flutter
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()

    GMSServices.provideAPIKey("AIzaSyATMi_WzfUnBfhb66_FR8c1Fg_zEwHyaCs")

    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self

    application.registerForRemoteNotifications()

    Messaging.messaging().delegate = self
    Messaging.messaging().isAutoInitEnabled = true

    let controller = window?.rootViewController as! FlutterViewController
    
    let appIconChannel = FlutterMethodChannel(
      name: "com.k3h.app/app_icon",
      binaryMessenger: controller.binaryMessenger
    )

    appIconChannel.setMethodCallHandler { call, result in

      if call.method == "changeAppIcon" {

        let arguments = call.arguments as? [String: Any]
        let iconName = arguments?["iconName"] as? String

        guard UIApplication.shared.supportsAlternateIcons else {
          result(
            FlutterError(
              code: "UNSUPPORTED",
              message: "Alternate app icons are not supported on this device",
              details: nil
            )
          )
          return
        }

        // Don't change if this icon is already active
        if UIApplication.shared.alternateIconName == iconName {
          result(nil)
          return
        }

        UIApplication.shared.setAlternateIconName(iconName) { error in
          if let error = error {
            result(
              FlutterError(
                code: "ICON_CHANGE_ERROR",
                message: error.localizedDescription,
                details: nil
              )
            )
          } else {
            result(nil)
          }
        }

      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    super.application(
      application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
    )

    Messaging.messaging().apnsToken = deviceToken
  }

  func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String?
  ) {
    print("\(fcmToken ?? "")")
  }
}