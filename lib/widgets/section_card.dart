import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final TextStyle? titleTextStyle;
  final Color? titleTextColor;
  final Color iconContainerColor;
  final Color? iconColor;
  final List<Widget> children;
  final double? childSpacing;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.titleTextStyle,
    this.titleTextColor,
    this.iconContainerColor = AppColor.lightBlue,
    this.iconColor,
    this.childSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeaderTile(
            title: title,
            textStyle:
                titleTextStyle ??
                AppTextStyle.ts14SB().copyWith(color: titleTextColor),
            icon: icon,
            backgroundColor: iconContainerColor,
            iconColor: iconColor,
          ),
          verticalSpacing(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              children.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == children.length - 1 ? 0 : childSpacing ?? 10,
                ),
                child: children[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
