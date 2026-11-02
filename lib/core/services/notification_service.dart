// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final LocalStorageManager localStorage = LocalStorageManager();
  final baseClient = BaseClient();

  Future requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
      carPlay: true,
      providesAppNotificationSettings: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> debugFCM() async {
    try {
      String? apns = await messaging.getAPNSToken();

      await Future.delayed(const Duration(seconds: 3));

      String? token = await messaging.getToken();
    } catch (e) {
      log("ERROR => $e");
    }
  }

  Future<String> getDeviceTokenForNotification() async {
    try {
      String? newToken = await messaging.getToken();

      if (newToken == null) {
        return "";
      }

      final oldToken = localStorage.getString(StorageKey.fcmToken);

      if (oldToken != null && oldToken != newToken) {
        localStorage.setString(StorageKey.oldFcmToken, oldToken);
      }

      localStorage.setString(StorageKey.fcmToken, newToken);

      var teamMemberId = localStorage.getRawString('ProjectMemberDetailsId');

      if (teamMemberId != null && oldToken != newToken) {
        await baseClient.postRequestWithAuthentication(
          "DeviceToken/RegisterDeviceToken",
          {"OldDeviceToken": oldToken ?? "", "LatestDeviceToken": newToken},
        );
      }

      return newToken;
    } catch (e) {
      return "";
    }
  }

  void isDeviceTokenRefresh() {
    messaging.onTokenRefresh.listen((token) async {
      final oldToken = localStorage.getString(StorageKey.fcmToken);

      if (oldToken != null) {
        localStorage.setString(StorageKey.oldFcmToken, oldToken);
      }

      localStorage.setString(StorageKey.fcmToken, token);

      try {
        var teamMemberId = localStorage.getString('ProjectMemberDetailsId');

        if (teamMemberId != null) {
          await baseClient.postRequestWithAuthentication(
            "DeviceToken/RegisterDeviceToken",
            {"OldDeviceToken": oldToken ?? "", "LatestDeviceToken": token},
          );
        }
        // ignore: empty_catches
      } catch (e) {}
    });
  }

  Future<void> firebaseNotificationInit() async {
    // Request notification permission
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification Permission: ${settings.authorizationStatus}');

    // iOS foreground notification configuration
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Check APNs token
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      debugPrint('APNS TOKEN: $apnsToken');
    }

    // Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();

    debugPrint('FCM TOKEN: $fcmToken');

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Foreground Notification: ${message.notification?.title}');

      if (Platform.isAndroid) {
        await initializeLocalNotification(message);
        await showNotification(message);
      }

      if (Platform.isIOS) {
        // iOS displays notification using native
        // foreground presentation options configured above.
        debugPrint('iOS foreground notification received');
      }
    });

    // Listen when user taps notification in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened from background');
      handleNotificationTap(message);
    });

    // Handle notification tap when app was terminated
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('Notification opened from terminated state');
      handleNotificationTap(initialMessage);
    }
  }

  Future initializeLocalNotification(RemoteMessage message) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    const androidInitializationSetting = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );

    const iosInitializationSetting = DarwinInitializationSettings();

    final initializationSetting = InitializationSettings(
      iOS: iosInitializationSetting,
      android: androidInitializationSetting,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSetting,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          goRouter.push(payload);
        } else {
          goRouter.push(AppRoutes.notificationScreenMobile);
        }
      },
    );

    final androidPlugin =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(channel);
  }

  Future showNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? "No Title";

    final body = message.notification?.body ?? "No Body";

    final route = message.data['route'];

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
      payload: route,
    );
  }

  Future foregroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'];

    if (route != null && route.isNotEmpty) {
      goRouter.push(route);
    } else {
      goRouter.push(AppRoutes.notificationScreenMobile);
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleNotificationTap(initialMessage);
    }
  }
}
