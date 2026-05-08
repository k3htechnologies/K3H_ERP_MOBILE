import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/env/env.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateType { none, patch, minor, major }

class AppUpdateHelper {
  final String appStoreId = ENV.appStoreId;
  final String androidPackageName = ENV.androidPackageName;
  static final String androidVersion = ENV.androidVersion;
  static final String iosVersion = ENV.iosVersion;

  static Future<void> checkForUpdate({
    required BuildContext context,
    required Map<String, dynamic> data,
    required VoidCallback onNoUpdate,
  }) async {
    final currentVersion = Platform.isAndroid ? androidVersion : iosVersion;

    final latestVersion =
        Platform.isAndroid ? data["AndroidVersion"] : data["IosVersion"];

    final updateType = _getUpdateType(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
    );

    if (updateType == UpdateType.none) {
      onNoUpdate();
      return;
    }

    final isForceUpdate = updateType == UpdateType.major;

    _showUpdateDialog(
      context: context,
      isForceUpdate: isForceUpdate,
      androidPackageName: AppUpdateHelper().androidPackageName,
      appStoreId: AppUpdateHelper().appStoreId,
      onSkip: onNoUpdate,
    );
  }

  static UpdateType _getUpdateType({
    required String currentVersion,
    required String latestVersion,
  }) {
    final current =
        currentVersion.split('.').map((e) {
          return int.tryParse(e) ?? 0;
        }).toList();

    final latest =
        latestVersion.split('.').map((e) {
          return int.tryParse(e) ?? 0;
        }).toList();

    while (current.length < 3) {
      current.add(0);
    }

    while (latest.length < 3) {
      latest.add(0);
    }

    // Major
    if (latest[0] > current[0]) {
      return UpdateType.major;
    }

    // Minor
    if (latest[0] == current[0] && latest[1] > current[1]) {
      return UpdateType.minor;
    }

    // Patch
    if (latest[0] == current[0] &&
        latest[1] == current[1] &&
        latest[2] > current[2]) {
      return UpdateType.patch;
    }

    return UpdateType.none;
  }

  static void _showUpdateDialog({
    required BuildContext context,
    required bool isForceUpdate,
    required String androidPackageName,
    required String appStoreId,
    required VoidCallback onSkip,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          insetPadding: isForceUpdate ? null : EdgeInsets.all(10),
          contentPadding:
              isForceUpdate
                  ? EdgeInsets.only(top: 10.h, left: 25.w, bottom: 20.h)
                  : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          title: Text(
            isForceUpdate ? "Update Required" : "Update Available",
            style: AppTextStyle.ts14SB(),
          ),

          content: Text(
            isForceUpdate
                ? "A new version of the app is available. Please update to continue."
                : "A new version of the app is available.",
            style: AppTextStyle.ts14R(),
          ),

          actions: [
            Row(
              spacing: 10,
              children: [
                if (!isForceUpdate)
                  Expanded(
                    child: CustomButton(
                      text: "Skip",
                      // backgroundColor: AppColor.black.withValues(alpha: 0.5),
                      backgroundColor: AppColor.grey,
                      onPressed: () {
                        goRouter.pop();
                        onSkip();
                      },
                    ),
                  ),

                Expanded(
                  child: CustomButton(
                    text: "Update",
                    onPressed: () async {
                      if (Platform.isIOS) {
                        final url = Uri.parse(
                          "itms-apps://itunes.apple.com/app/$appStoreId",
                        );

                        await launchUrl(url);
                      } else if (Platform.isAndroid) {
                        final url = Uri.parse(
                          "market://details?id=$androidPackageName",
                        );

                        await launchUrl(url);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
