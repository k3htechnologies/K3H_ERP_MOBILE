import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

Widget verticalSpacing({double height = 10.0}) => SizedBox(height: height.h);

Widget horizontalSpacing({double width = 10.0}) => SizedBox(width: width.w);

double verticalSpacingMeasure({double height = 10.0}) => height.h;

double horizontalSpacingMeasure({double width = 20.0}) => width.w;

Widget noDataWidget({String? message, double? iconSize}) => Container(
  decoration: const BoxDecoration(color: Colors.transparent),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        AppAssets.noDataImage,
        width: iconSize ?? 200.w,
        fit: BoxFit.fitHeight,
      ),
      Text(
        textAlign: TextAlign.center,
        message ?? "No Data Available!",
        style: AppTextStyle.ts14B(color: AppColor.grey),
      ),
    ],
  ),
);

// BULLET TEXT
Widget bulletText(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text("•", style: AppTextStyle.ts16M(color: AppColor.black)),
      SizedBox(width: 6.w),
      Expanded(
        child: Text(text, style: AppTextStyle.ts12M(color: AppColor.grey)),
      ),
    ],
  );
}

Widget loader() {
  return SafeArea(
    child: Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // BLUR BACKGROUND
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.15,
                ), // glass transparency
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/appLogo.png",
                  width: 100,
                  height: 100,
                ),
                verticalSpacing(),
                CircularProgressIndicator(
                  color: AppColor.primary,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
