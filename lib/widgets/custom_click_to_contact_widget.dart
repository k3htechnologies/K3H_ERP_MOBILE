import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

enum ContactType { phone, email }

class CustomClickToContactText extends StatelessWidget {
  final String value;
  final ContactType type;
  final TextStyle? textStyle;
  final Color iconColor;
  final double iconSize;

  const CustomClickToContactText({
    super.key,
    required this.value,
    this.type = ContactType.phone,
    this.textStyle,
    this.iconColor = AppColor.mediumBlue,
    this.iconSize = 15,
  });

  Future<void> launchContact(BuildContext context) async {
    late final Uri uri;

    if (type == ContactType.phone) {
      PermissionStatus status = await Permission.phone.status;

      if (Platform.isAndroid) {
        // REQUEST EVERY CLICK IF NOT GRANTED
        if (!status.isGranted) {
          status = await Permission.phone.request();
        }

        // PERMISSION DENIED
        if (status.isDenied) {
          if (context.mounted) {
            showErrorMessage(
              context,
              "Permission Denied",
              "Phone permission is required to make a call.",
            );
          }
          await Future.delayed(const Duration(seconds: 1));
          await openAppSettings();

          return;
        }

        // PERMANENTLY DENIED
        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            showErrorMessage(
              context,
              "Permission Required",
              "Please enable phone permission from app settings.",
            );
          }

          await Future.delayed(const Duration(seconds: 1));
          await openAppSettings();
          return;
        }
      }
      uri = Uri(scheme: 'tel', path: value);

      try {
        final service = serviceLocator<AppCallTrackerService>();

        service.setPendingCall(value);
        service.forceStartCall(value);
      } catch (_) {}
    } else {
      uri = Uri(scheme: 'mailto', path: value);
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return Text("-");
    }
    return InkWell(
      onTap: () => launchContact(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child:
                type == ContactType.phone
                    ? SvgPicture.asset(
                      AppAssets.phoneIcon,
                      height: 16.h,
                      width: 16.w,
                    )
                    : SvgPicture.asset(
                      AppAssets.mailIcon,
                      height: 16.h,
                      width: 16.w,
                    ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              type == ContactType.phone ? value.trim() : value,
              style:
                  textStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: AppColor.mediumBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.mediumBlue,
                    decorationThickness: .8,
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
