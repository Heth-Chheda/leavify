import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leavify/core/storage/app_storage.dart';

class FCMService {
  // 🔸 Step 1: Add a local notifications instance
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await _initializeLocalNotifications();
    await _requestPermissions(messaging);

    if (Platform.isIOS) {
      await _printAPNSToken();
    }

    await _saveFCMToken(messaging);

    // 🔸 Step 2: Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '📩 Foreground message received: ${message.notification?.title}',
      );
      _showLocalNotification(message);
    });

    // 🔸 Step 3: When user taps a notification and opens the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notification clicked: ${message.data}');
    });

    // 🔸 Step 4: Handle token refresh
    messaging.onTokenRefresh.listen((newToken) {
      AppStorage.saveString("USER_FCM_TOKEN", newToken);
      debugPrint('🔄 FCM Token Refreshed: $newToken');
    });
  }

  // 🔸 Step 5: Initialize flutter_local_notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('📲 Notification tapped: ${details.payload}');
      },
    );

    // ✅ Explicitly ask iOS for notification permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // 🔸 Step 6: Show local notification manually for foreground messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final bigTextStyle = BigTextStyleInformation(
      notification.body ?? '',
      contentTitle: notification.title,
      htmlFormatContent: true,
      htmlFormatContentTitle: true,
    );

    final androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'General Notifications',
      channelDescription: 'Used for showing important notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: bigTextStyle,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
    );
  }

  static Future<void> _requestPermissions(FirebaseMessaging messaging) async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  static Future<void> _printAPNSToken() async {
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken == null) {
      await Future.delayed(const Duration(seconds: 1));
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    }
    debugPrint('📱 APNS Token: $apnsToken');
  }

  static Future<void> _saveFCMToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token != null) {
      AppStorage.saveString('USER_FCM_TOKEN', token);
      debugPrint('📲 FCM Token: $token');
    }
  }
}
