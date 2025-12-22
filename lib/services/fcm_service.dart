import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/router/services/notification_redirection.dart';

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
    // 1️⃣ Initialize local notifications FIRST
    await _initializeLocalNotifications();

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ------------------------------------------------
    // 2️⃣ SAFE PERMISSION HANDLING (iOS compliant)
    // ------------------------------------------------
    final NotificationSettings currentSettings = await messaging
        .getNotificationSettings();

    debugPrint(
      '🔔 Current notification permission status: '
      '${currentSettings.authorizationStatus}',
    );

    // Ask permission ONLY if never asked before
    if (currentSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      final NotificationSettings newSettings = await messaging
          .requestPermission(alert: true, badge: true, sound: true);

      debugPrint(
        '🔔 Permission requested, result: '
        '${newSettings.authorizationStatus}',
      );
    } else {
      debugPrint('✅ Permission already handled — skipping request');
    }

    // ------------------------------------------------
    // 3️⃣ SAVE FCM TOKEN (safe even if permission denied)
    // ------------------------------------------------
    await _saveFCMToken(messaging);

    // ------------------------------------------------
    // 4️⃣ BACKGROUND MESSAGE HANDLER
    // ------------------------------------------------
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ------------------------------------------------
    // 5️⃣ iOS APNs → Flutter MethodChannel Bridge
    // ------------------------------------------------
    _apnsChannel.setMethodCallHandler((call) async {
      if (call.method == "apnsPayload") {
        final payload = Map<String, dynamic>.from(call.arguments);

        debugPrint("📥 [Flutter] Received APNs payload = $payload");

        final RemoteMessage mockMessage = RemoteMessage(
          data: {
            "screen": payload["screen"]?.toString(),
            "leaveId": payload["leaveId"]?.toString(),
          },
        );

        NotificationRedirection.handleNotification(mockMessage);
      }
    });

    // ------------------------------------------------
    // 6️⃣ FOREGROUND FCM NOTIFICATIONS
    // ------------------------------------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 [FG] Foreground message received");
      debugPrint("📩 Data: ${message.data}");
      showLocalNotification(message);
    });

    // ------------------------------------------------
    // 7️⃣ APP OPENED FROM BACKGROUND
    // ------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🔔 Notification opened from BACKGROUND");
      NotificationRedirection.handleNotification(message);
    });

    // ------------------------------------------------
    // 8️⃣ APP OPENED FROM TERMINATED STATE
    // ------------------------------------------------
    final RemoteMessage? initialMsg = await messaging.getInitialMessage();

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
          AndroidFlutterLocalNotificationsPlugin
        >();

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
