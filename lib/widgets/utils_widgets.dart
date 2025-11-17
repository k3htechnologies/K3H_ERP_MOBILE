import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

Widget verticalSpacing({double height = 10.0}) => SizedBox(height: height);

Widget horizontalSpacing({double width = 10.0}) => SizedBox(width: width);

double verticalSpacingMeasure({double height = 10.0}) => height;

double horizontalSpacingMeasure({double width = 20.0}) => width;


Widget noDataWidget() => Container(
  width: double.infinity,
  height: double.infinity,
  decoration: const BoxDecoration(color: Colors.transparent),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(AppAssets.noDataImage, width: 150.0, height: 150.0),
      verticalSpacing(),
      Text("No Data Available!", style: AppTextStyle.ts14B()),
    ],
  ),
);

Widget loader() => Container(
  width: double.infinity,
  height: double.infinity,
  decoration: const BoxDecoration(color: Colors.transparent),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset("assets/images/logo.png", width: 100.0, height: 100.0),
      verticalSpacing(),
      CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2.0),
    ],
  ),
);