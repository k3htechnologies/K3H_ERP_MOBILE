import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/services/notification_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashMobileScreenState();
}

class _SplashMobileScreenState extends State<SplashScreen> {
  late NotificationService notificationService;
  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    handleNotification();
    Future.delayed(const Duration(seconds: 2), () async {
      final localStorage = LocalStorageManager();

      final token = localStorage.getString(StorageKey.authorizationToken);
      final menu = localStorage.getString(StorageKey.menu);

      final bool isLoggedIn = token != null && token.isNotEmpty;

      if (!isLoggedIn) {
        goRouter.goNamed(AppRoutes.login);
        return;
      }

      try {
        final UtilsRepository utilsRepository =
            serviceLocator<UtilsRepository>();

        if (menu != null && menu.isNotEmpty) {
          goRouter.goNamed(AppRoutes.dashboardScreen);
          return;
        }

        final userJson = localStorage.getString(StorageKey.currentUser) ?? '';

        if (userJson.isEmpty) {
          goRouter.goNamed(AppRoutes.login);
          return;
        }

        final user = UserModel.fromJson(jsonDecode(userJson));

        var result = await utilsRepository.getMenu(employeeId: user.employeeId);

        result.fold(
          (failure) {
            goRouter.goNamed(AppRoutes.login);
          },
          (data) async {
            localStorage.setString(
              StorageKey.menu,
              jsonEncode(data["menuData"]),
            );

            await updateRouteAuthorization(
              data["menuData"] as List<ModuleModel>,
            );

            goRouter.goNamed(AppRoutes.dashboardScreen);
          },
        );
      } catch (e) {
        goRouter.goNamed(AppRoutes.login);
      }
    });
  }

  Future handleNotification() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      bool permissionGranted =
          await notificationService.requestNotificationPermission();

      if (!mounted || !permissionGranted) return;

      await notificationService.getDeviceTokenForNotification();

      if (!mounted) return;

      notificationService.isDeviceTokenRefresh();

      notificationService.firebaseNotificationInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset(AppAssets.splashLogoGif)));
  }
}
