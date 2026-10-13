import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class CardHeaderTile extends StatelessWidget {
  final String? svgIcon;
  final IconData? icon;
  final String title;
  final Color backgroundColor;
  final double iconSize;
  final double containerSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final Widget? suffix;

  const CardHeaderTile({
    super.key,
    this.svgIcon,
    this.icon,
    required this.title,
    this.backgroundColor = const Color(0xffF5F6F8),
    this.iconSize = 20,
    this.containerSize = 32,
    this.iconColor,
    this.textStyle,
    this.suffix,
  }) : assert(
         svgIcon != null || icon != null,
         'Either svgIcon or icon must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconContainer(
          containerSize: containerSize,
          iconSize: iconSize,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          icon: icon,
          svgIcon: svgIcon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: textStyle ?? AppTextStyle.ts14M(color: AppColor.black),
          ),
        ),
        if (suffix != null) ...[const SizedBox(width: 12), suffix!],
      ],
    );
  }
}
