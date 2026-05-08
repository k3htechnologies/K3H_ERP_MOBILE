import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/services/notification_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/env/env.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashMobileScreenState();
}

class _SplashMobileScreenState extends State<SplashScreen> {
  late NotificationService notificationService;

  bool isUpdateRequired = false;

  final String appStoreId = ENV.appStoreId;
  final String androidPackageName = ENV.androidPackageName;
  static final String androidVersion = ENV.androidVersion;
  static final String iosVersion = ENV.iosVersion;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    handleNotification();

    checkVersionAndProceed();
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

  Future<void> checkVersionAndProceed() async {
    try {
      final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

      final result = await utilsRepository.getAppVersion();

      result.fold(
        (failure) {
          _proceedToApp();
        },
        (response) {
          isUpdateRequired = _checkAppVersion(response);

          if (isUpdateRequired) {
            _showUpdateDialog();
          } else {
            _proceedToApp();
          }
        },
      );
    } catch (e) {
      _proceedToApp();
    }
  }

  bool _checkAppVersion(Map<String, dynamic> data) {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      return androidVersion != data["AndroidVersion"];
    } else if (Platform.isIOS) {
      return iosVersion != data["IosVersion"];
    }
    return false;
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),

            title: Text("Update Required", style: AppTextStyle.ts14M()),
            content: Text(
              "A new version of the app is available. Please update to continue.",
              style: AppTextStyle.ts14R(),
            ),
            actions: [CustomButton(text: "Update", onPressed: _launchStore)],
          ),
    );
  }

  Future<void> _launchStore() async {
    if (Platform.isIOS) {
      final url = Uri.parse("itms-apps://itunes.apple.com/app/$appStoreId");
      await launchUrl(url);
    } else if (Platform.isAndroid) {
      final url = Uri.parse("market://details?id=$androidPackageName");
      await launchUrl(url);
    }
  }

  Future<void> _proceedToApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final localStorage = LocalStorageManager();

    final token = localStorage.getString(StorageKey.authorizationToken);
    final menu = localStorage.getString(StorageKey.menu);

    final bool isLoggedIn = token != null && token.isNotEmpty;

    if (!isLoggedIn) {
      goRouter.goNamed(AppRoutes.login);
      return;
    }

    try {
      final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

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
          localStorage.setString(StorageKey.menu, jsonEncode(data["menuData"]));

          await updateRouteAuthorization(data["menuData"] as List<ModuleModel>);

          goRouter.goNamed(AppRoutes.dashboardScreen);
        },
      );
    } catch (e) {
      goRouter.goNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset(AppAssets.splashLogoGif)));
  }
}
