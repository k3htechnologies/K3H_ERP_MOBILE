import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
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
    this.type = ContactType.phone, // default is phone
    this.textStyle,
    this.iconColor = AppColor.mediumBlue,
    this.iconSize = 15,
  });

  Future<void> launchContact() async {
    late final Uri uri;

    if (type == ContactType.phone) {
      // tel: scheme
      uri = Uri(scheme: 'tel', path: value);
    } else {
      // mailto: scheme
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
      onTap: launchContact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              value,
              style:
                  textStyle ??
                  const TextStyle(
                    color: AppColor.mediumBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.mediumBlue,
                    decorationThickness: .8,
                    height: 1.3
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
