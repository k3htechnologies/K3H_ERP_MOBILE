// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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
      provisional: true,
      sound: true,
      carPlay: true,
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
      debugPrint("FCM Token: $newToken");

      if (newToken == null) return "";

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
      debugPrint("Token error: $e");
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
      } catch (e) {
        debugPrint("Token refresh error: $e");
      }
    });
  }

  void firebaseNotificationInit() {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        initializeLocalNotification(message);
        showNotification(message);
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          handleNotificationTap(message);
        });
      }

      if (Platform.isIOS) {
        foregroundMessage();

        showNotification(message);
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          handleNotificationTap(message);
        });
      }
    });
  }

  Future initializeLocalNotification(RemoteMessage message) async {
    var androidInitializationSetting = const AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );
    var iosInitializationSetting = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      iOS: iosInitializationSetting,
      android: androidInitializationSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSetting,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          goRouter.push(response.payload!);
        }
      },
    );
  }

  Future showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.high,
          priority: Priority.high,
        );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: message.notification?.title ?? "No Title",
      body: message.notification?.body ?? "No Body",
      notificationDetails: details,
      payload: message.data['route'],
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
