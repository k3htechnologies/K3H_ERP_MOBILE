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

enum ContactType { phone, email, landLine }

class CustomClickToContactText extends StatelessWidget {
  final String value;
  final ContactType type;
  final TextStyle? textStyle;
  final Color iconColor;
  final double iconSize;
  final String countryCode;

  const CustomClickToContactText({
    super.key,
    required this.value,
    this.type = ContactType.phone,
    this.textStyle,
    this.iconColor = AppColor.mediumBlue,
    this.iconSize = 15,
    this.countryCode = '+91',
  });

  String _getFormattedPhoneNumber() {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return '';

    // Landline should be shown as-is
    if (type == ContactType.landLine) {
      return trimmed;
    }

    String cleaned = trimmed.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');

    if (cleaned.isEmpty) return '';

    final code = countryCode.trim().isEmpty ? '+91' : countryCode.trim();

    return '$code $cleaned';
  }

  Future<void> launchContact(BuildContext context) async {
    late final Uri uri;

    if (type == ContactType.phone || type == ContactType.landLine) {
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

      final phoneNumber = _getFormattedPhoneNumber();
      uri = Uri(scheme: 'tel', path: phoneNumber);

      try {
        final service = serviceLocator<AppCallTrackerService>();
        service.setPendingCall(phoneNumber);
        service.forceStartCall(phoneNumber);
      } catch (_) {}
    } else {
      uri = Uri(scheme: 'mailto', path: value.trim());
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayValue =
        type == ContactType.email ? value.trim() : _getFormattedPhoneNumber();
    if (displayValue.isEmpty) {
      return Text(
        "-",
        style: textStyle ?? const TextStyle(fontSize: 14, color: Colors.black),
      );
    }

    return InkWell(
      onTap: () => launchContact(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          (type == ContactType.phone || type == ContactType.landLine)
              ? SvgPicture.asset(AppAssets.phoneIcon, height: 16.h, width: 16.w)
              : SvgPicture.asset(AppAssets.mailIcon, height: 16.h, width: 16.w),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              displayValue,
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
