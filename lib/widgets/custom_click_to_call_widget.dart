import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomClickToCallText extends StatelessWidget {
  final String phoneNumber;
  final TextStyle? textStyle;
  final Color iconColor;

  const CustomClickToCallText({
    super.key,
    required this.phoneNumber,
    this.textStyle,
    this.iconColor = AppColor.primary,
  });

  Future<void> _call() async {
    final uri = Uri.parse("tel:$phoneNumber");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _call,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(
            phoneNumber,
            style:
                textStyle ??
                const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
          ),
        ],
      ),
    );
  }
}
