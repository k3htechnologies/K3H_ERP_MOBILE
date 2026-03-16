import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

// BUILD ROW TITLE VALUE
Widget buildRowTitleValue({
  required String title,
  required String value,
  double fixesWidth = 140,
  TextStyle? valueTextStyle,
  Widget? customValueWidget,
  bool singleLine = true,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: singleLine ? 1 : null,
                overflow:
                    singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
                style: valueTextStyle ?? AppTextStyle.ts14M(),
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

// STATUS CHIP
Widget statusChip(String text, Color bg, Color txt, {bool expand = false}) {
  final chip = Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyle.ts12M(color: txt),
    ),
  );

  if (expand) {
    return Flexible(child: chip);
  }

  return chip;
}

// BUILD COMMON ACTION CARD
Widget actionCardWidget({required String createdBy, required DateTime createdDate, String? modifiedBy,DateTime? modifiedDate}){
  return Container(
    padding: EdgeInsets.all(16),
    decoration: commonCardDecoration(),
    child: Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Action Details", style: AppTextStyle.ts16SB()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColumnTitleValue(
              title: "Created By",
              value: createdBy,
            ),
            buildColumnTitleValue(
              title: "Created Date",
              value: formatDate(
                createdDate,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColumnTitleValue(
              title: "Modified By",
              value:
              (modifiedBy!=null || modifiedBy!.isNotEmpty)
                  ? modifiedBy
                  : "-",
            ),
            buildColumnTitleValue(
              title: "Modified Date",
              value: (modifiedDate == null ||
                  modifiedDate.toString().trim().isEmpty ||
                  modifiedDate.toString().contains('1970-01-01') ||
                  modifiedDate.toString().contains('01 Jan 1970'))
                  ? "-"
                  : formatDate(modifiedDate),
            ),
          ],
        ),
      ],
    ),
  );
}
