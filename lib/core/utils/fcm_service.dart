import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'token_storage.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('[FCM] Background message: ${message.messageId}');
  }
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    _messaging.onTokenRefresh.listen((token) async {
      await TokenStorage.saveDeviceToken(token);
      if (kDebugMode) {
        debugPrint('[FCM] Token refreshed');
      }
    });

    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await TokenStorage.saveDeviceToken(token);
      if (kDebugMode) {
        debugPrint('[FCM] Token initialized');
      }
    }

    _initialized = true;
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<String?> getToken() async {
    final cached = await TokenStorage.getDeviceToken();
    if (cached != null && cached.isNotEmpty) return cached;

    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await TokenStorage.saveDeviceToken(token);
      return token;
    }
    return null;
  }

  static String get deviceType => Platform.isIOS ? 'ios' : 'android';

  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
    }
  }

  static void _handleMessageOpened(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Message opened: ${message.messageId}');
    }
  }
}
