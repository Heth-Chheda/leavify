import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  var apnsPayload: [String: Any] = [:]
  var channel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
  ) -> Bool {

    FirebaseApp.configure()

    // Setup notification center delegate
    UNUserNotificationCenter.current().delegate = self

    // Register for notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { granted, error in
      if granted {
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      }
    }

    // Setup Flutter MethodChannel
    let controller = window?.rootViewController as! FlutterViewController
    channel = FlutterMethodChannel(
      name: "leavify/apns",
      binaryMessenger: controller.binaryMessenger
    )

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Foreground notification
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("📣 [iOS] Foreground notification received")
    print("📣 Payload = \(userInfo)")

    apnsPayload = userInfo as? [String: Any] ?? [:]

    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  // USER taps the notification
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    print("👉 [iOS] User tapped notification")
    print("👉 Payload: \(userInfo)")

    apnsPayload = userInfo as? [String: Any] ?? [:]

    // Send to Flutter
    channel?.invokeMethod("apnsPayload", arguments: apnsPayload)

    completionHandler()
  }

  // Background / Terminated
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    print("📩 [iOS] Background notification received")
    print("📩 Payload: \(userInfo)")

    apnsPayload = userInfo as? [String: Any] ?? [:]

    Messaging.messaging().appDidReceiveMessage(userInfo)
    completionHandler(.newData)
  }
}
