import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

// BUILD ROW TITLE VALUE
Widget buildRowTitleValue({
  required String title,
  required String value,
  double fixesWidth = 140,
  TextStyle? valueTextStyle,
  Widget? customValueWidget,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        // TITLE
        SizedBox(
          width: fixesWidth,
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
                style: valueTextStyle ?? AppTextStyle.ts14R(),
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
  TextStyle? valueTextStyle,
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
              style:
                  valueTextStyle ?? AppTextStyle.ts14M(color: AppColor.black),
            ),
      ],
    ),
  );
}

Widget statusChip(String text, Color bg, Color txt) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: AppTextStyle.ts12M(color: txt)),
  );
}
