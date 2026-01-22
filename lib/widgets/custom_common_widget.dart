import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

// BUILD ROW TITLE VALUE
Widget buildRowTitleValue({
  required String title,
  required String value,
  Widget? customValueWidget,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        // TITLE
        SizedBox(
          width: 140,
          child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
        ),

        // COLON
        SizedBox(
          width: 20,
          child: Text(
            ":",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.grey),
          ),
        ),

        // VALUE
        Flexible(
          child:
              customValueWidget ??
              Text(
                value.isNotEmpty ? value : "-",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.ts14R(),
              ),
        ),
      ],
    ),
  );
}

// BUILD COLUMN TITLE VALUE

Widget buildColumnTitleValue({
  required String title,
  required String value,
  Widget? customValueWidget,
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
        verticalSpacing(height: 4),
        customValueWidget ??
            Text(
              value.isEmpty ? "-" : value,
              style: AppTextStyle.ts14M(color: AppColor.black),
            ),
      ],
    ),
  );
}
