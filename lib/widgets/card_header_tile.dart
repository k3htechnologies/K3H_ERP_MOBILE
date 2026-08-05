import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CardHeaderTile extends StatelessWidget {
  final String? svgIcon;
  final IconData? icon;
  final String title;
  final Color backgroundColor;
  final double iconSize;
  final double containerSize;
  final Color? iconColor;
  final TextStyle? textStyle;

  const CardHeaderTile({
    super.key,
    this.svgIcon,
    this.icon,
    required this.title,
    this.backgroundColor = const Color(0xffF5F6F8),
    this.iconSize = 18,
    this.containerSize = 34,
    this.iconColor,
    this.textStyle,
  }) : assert(
         svgIcon != null || icon != null,
         'Either svgIcon or icon must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: containerSize,
          width: containerSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child:
              svgIcon != null
                  ? SvgPicture.asset(
                    svgIcon!,
                    height: iconSize,
                    width: iconSize,
                  )
                  : Icon(icon, size: 22, color: iconColor ?? AppColor.darkBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: textStyle ?? AppTextStyle.ts14M(color: AppColor.black),
          ),
        ),
      ],
    );
  }
}
