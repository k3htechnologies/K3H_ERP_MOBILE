import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CollectionReportCard extends StatelessWidget {
  final String title;
  final Color dotColor;
  final String subTitle;
  final Widget body;

  final List<Color> headerGradient;
  final Color bodyColor;
  final EdgeInsetsGeometry bodyPadding;
  const CollectionReportCard({
    super.key,
    required this.title,
    required this.dotColor,
    required this.subTitle,
    required this.body,
    this.headerGradient = const [
      Color(0xff1F518F),
      Color(0xFF17447C),
      Color(0xFF0E294B),
    ],
    this.bodyColor = AppColor.lightBlue2,
    this.bodyPadding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: headerGradient,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.sp),
              topRight: Radius.circular(8.sp),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.sp,
                    height: 10.sp,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  horizontalSpacing(width: 8.sp),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: AppTextStyle.ts14SB(color: Colors.white),
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 8.sp),
              Text(subTitle, style: AppTextStyle.ts12M(color: Colors.white)),
            ],
          ),
        ),
        // Body
        Container(color: bodyColor, padding: bodyPadding, child: body),
      ],
    );
  }
}
