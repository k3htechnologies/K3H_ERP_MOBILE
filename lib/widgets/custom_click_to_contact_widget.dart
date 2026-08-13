import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
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

  final Future<void> Function(String phoneNumber)? onCall;

  const CustomClickToContactText({
    super.key,
    required this.value,
    this.type = ContactType.phone,
    this.textStyle,
    this.iconColor = AppColor.mediumBlue,
    this.iconSize = 15,
    this.countryCode = '+91',
    this.onCall,
  });

  String _getFormattedPhoneNumber() {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return '';

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
        if (!status.isGranted) {
          status = await Permission.phone.request();
        }

        if (status.isDenied) {
          if (context.mounted) {
            showErrorMessage(
              context,
              "Permission Denied",
              "Phone permission is required to make a call.",
            );
          }
          return;
        }

        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            showErrorMessage(
              context,
              "Permission Required",
              "Please enable phone permission from app settings.",
            );
          }

          await openAppSettings();
          return;
        }
      }

      final phoneNumber = _getFormattedPhoneNumber();

      if (phoneNumber.isEmpty) return;

      // Tell parent screen that a call is starting
      if (onCall != null) {
        await onCall!(phoneNumber);
      } else {
        try {
          final service = serviceLocator<AppCallTrackerService>();
          service.setPendingCall(phoneNumber);
        } catch (_) {}
      }

      uri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));
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
                  AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
