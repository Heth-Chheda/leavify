import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leavify/router/services/notification_redirection.dart';
import 'package:leavify/core/storage/app_storage.dart';

// 1. Define the background handler as a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // We call the public method in FCMService
  await FCMService.showLocalNotification(message);
}

class FCMService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const MethodChannel _apnsChannel = MethodChannel("leavify/apns");

  static RemoteMessage? _pendingInitialMessage;

  static Future<void> initialize() async {
    await _initializeLocalNotifications();

    final messaging = FirebaseMessaging.instance;

    // -----------------------------
    // 2. REQUEST PERMISSION HERE
    // -----------------------------
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
      // You might want to return here if permission is denied,
      // but we continue to save the token just in case.
    }

    await _saveFCMToken(messaging);

    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // -----------------------------
    // iOS APNs → Flutter receiver
    // -----------------------------
    _apnsChannel.setMethodCallHandler((call) async {
      if (call.method == "apnsPayload") {
        final payload = Map<String, dynamic>.from(call.arguments);

        debugPrint("📥 [Flutter] Received APNs payload = $payload");

        final mockMessage = RemoteMessage(data: {
          "screen": payload["screen"]?.toString(),
          "leaveId": payload["leaveId"]?.toString(),
        });

        NotificationRedirection.handleNotification(mockMessage);
      }
    });

    // NORMAL FCM foreground notifications
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("📩 [FG] Foreground message received");
      debugPrint("📩 Data: ${message.data}");
      showLocalNotification(message);
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("🔔 Notification opened from BACKGROUND");
      NotificationRedirection.handleNotification(message);
    });

    // App opened from terminated
    final initialMsg = await messaging.getInitialMessage();
    if (initialMsg != null) {
      debugPrint("🚀 App opened from TERMINATED via FCM");
      _pendingInitialMessage = initialMsg;
    }
  }

  static Future<void> handlePendingNotification() async {
    if (_pendingInitialMessage != null) {
      NotificationRedirection.handleNotification(_pendingInitialMessage!);
      _pendingInitialMessage = null;
    }
  }

  // LOCAL NOTIFICATION TAP HANDLER
  static Future<void> _handleNotificationResponse(
      NotificationResponse response,
      ) async {
    debugPrint("👉 Local notification tapped");

    if (response.payload == null) return;

    final data = jsonDecode(response.payload!);
    final mock = RemoteMessage(data: Map<String, dynamic>.from(data));

    NotificationRedirection.handleNotification(mock);
  }

  // SHOW LOCAL NOTIFICATION
  // Note: I removed the underscore (_) to make this public so the
  // background handler can access it.
  static Future<void> showLocalNotification(RemoteMessage message) async {
    final payload = jsonEncode(message.data);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      0, // ID 0 means it replaces previous notifs. Change if you want stacking.
      message.notification?.title ?? "New Notification",
      message.notification?.body ?? "You have a new message",
      details,
      payload: payload,
    );
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(channel);

    debugPrint("📣 Android Notification Channel Created");

    // Initialize plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  static Future<void> _saveFCMToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token != null) AppStorage.saveString("USER_FCM_TOKEN", token);
  }
}