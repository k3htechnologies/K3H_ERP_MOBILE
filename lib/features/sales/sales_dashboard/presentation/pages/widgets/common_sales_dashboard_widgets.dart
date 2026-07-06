import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final Widget? customWidget;
  final VoidCallback? onValueTap;

  const InfoColumn({
    super.key,
    required this.title,
    required this.value,
    this.customWidget,
    this.onValueTap,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = Padding(
      padding:
          (onValueTap != null && value != '0')
              ? EdgeInsets.only(right: 50.0)
              : EdgeInsets.zero,
      child:
          customWidget ??
          Text(
            value.trim().isEmpty ? "-" : value,
            style:
                (onValueTap != null && value != '0')
                    ? AppTextStyle.ts14SB(color: AppColor.primary)
                    : AppTextStyle.ts14M(color: AppColor.black),
          ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        (onValueTap != null && value != '0')
            ? GestureDetector(
              onTap: onValueTap,
              behavior: HitTestBehavior.opaque,
              child: valueWidget,
            )
            : valueWidget,
      ],
    );
  }
}
