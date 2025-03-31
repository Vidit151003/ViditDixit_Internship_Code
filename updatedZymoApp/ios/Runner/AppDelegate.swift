import UIKit
import Flutter
import Firebase
import GoogleMaps
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
   GMSServices.provideAPIKey("AIzaSyC4aR_R7YDAs6OQ3WoIdXt90hyvu2tuLek")
    GeneratedPluginRegistrant.register(with: self)
   if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

   Messaging.messaging().apnsToken = deviceToken
   super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
 }
}
