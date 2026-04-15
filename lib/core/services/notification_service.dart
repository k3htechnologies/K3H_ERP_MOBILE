import 'dart:developer'; // For logging
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> setupFlutterNotifications() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // Ensure the plugin is available before calling methods
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
      }

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          _handleTap(details.payload);
        },
      );
    } catch (e) {
      log("Error setting up Local Notifications: $e");
    }
  }

  Future<void> initNotifications() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log("User denied notification permissions.");
        return;
      }

      print("I m in");

      // ✅ Small delay for iOS
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 2));
      }

      String? token;

      try {
        token = await _fcm.getToken();
      } catch (e) {
        log("FCM error: $e");
      }

      print("FCM TOKEN => $token");

      if (token != null) {
        await LocalStorageManager().setString(StorageKey.fcmToken, token);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

    } catch (e) {
      log("Error during FCM initialization: $e");
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title:notification.title,
          body:notification.body,
          notificationDetails:NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // CHANNEL ID
              'High Importance Notifications', // CHANNEL NAME
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['route'],
        );
      }
    } catch (e) {
      log("Error showing local notification: $e");
    }
  }
  void _handleTap(String? payload) {
    try {
      if (payload != null) {
        log("Navigating to: $payload");
        // Use your GoRouter or Navigator instance here
      }
    } catch (e) {
      log("Error handling notification tap: $e");
    }
  }
}