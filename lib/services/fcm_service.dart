import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:leavify/core/storage/app_storage.dart';

class FCMService {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await _requestPermissions(messaging);

    if (Platform.isIOS) {
      await _printAPNSToken();
    }

    await _saveFCMToken(messaging);

    messaging.onTokenRefresh.listen((newToken) {
      AppStorage.saveString("USER_FCM_TOKEN", newToken);
      debugPrint('🔄 FCM Token Refreshed: $newToken');
    });
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
