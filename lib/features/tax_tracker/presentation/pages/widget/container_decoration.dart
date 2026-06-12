import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class TaxTrackerSection extends StatelessWidget {
  final String title;
  final Color headerBgColor;
  final Color titleColor;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const TaxTrackerSection({
    super.key,
    required this.title,
    required this.headerBgColor,
    required this.titleColor,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16.5),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(title, style: AppTextStyle.ts16B(color: titleColor)),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  color: AppColor.black.withValues(alpha: 0.05),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
