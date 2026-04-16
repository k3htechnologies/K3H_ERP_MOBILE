import 'dart:developer'; // For logging
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> setupFlutterNotifications() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );

      final androidPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

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
      //  Small delay for iOS
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 2));
      }

      String? token;

      try {
        token = await _fcm.getToken();
      } catch (e) {
        log("FCM error: $e");
      }

      debugPrint("FCM TOKEN => $token");

      if (token != null) {
        final storage = LocalStorageManager();
        await storage.setString(StorageKey.fcmToken, token);
      }

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();

      if (initialMessage != null) {
        log("App opened from terminated state");
        _handleTap(initialMessage.data['route']);
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("App opened from background");
        _handleTap(message.data['route']);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });
    } catch (e) {
      log("Error during FCM initialization: $e");
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    try {
      final title = message.data['title'];
      final body = message.data['body'];

      _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['route'],
      );
    } catch (e) {
      log("Error showing local notification: $e");
    }
  }

  void _handleTap(String? payload) {
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        goRouter.push(AppRoutes.notificationScreenMobile);
      });
    } catch (e) {
      log("Error handling notification tap: $e");
    }
  }
}
