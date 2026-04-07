import 'dart:io';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/services/app_call_tracker_service.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/style/app_color.dart';
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
      uri = Uri(scheme: 'tel', path: value);
      if (Platform.isAndroid) {
        final status = await Permission.phone.request();
        if (status.isGranted) {
          try {
            serviceLocator<AppCallTrackerService>().setPendingCall(value);
          } catch (_) {}
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Phone permission is needed to show this call on Dashboard.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        try {
          serviceLocator<AppCallTrackerService>().setPendingCall(value);
        } catch (_) {}
      }
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
          Icon(
            type == ContactType.phone ? Icons.phone : Icons.email_outlined,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              type == ContactType.phone
                  ? (value.trim().length == 10
                      ? '+91 ${value.trim()}'
                      : value.trim())
                  : value,
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
