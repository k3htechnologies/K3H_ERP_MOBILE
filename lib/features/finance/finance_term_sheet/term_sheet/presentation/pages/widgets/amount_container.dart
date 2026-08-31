import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildAmountWidget(
  BuildContext context, {
  required Color bgColor,
  required String title,
  required Color titleColor,
  required String value,
  required Color valueColor,
  String? subText,
  Color? valuesubTextColor,
  Color? borderColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: bgColor,
      border:
          borderColor != null ? Border.all(color: borderColor, width: 1) : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12SB(color: titleColor)),
        verticalSpacing(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTextStyle.ts14SB(color: valueColor),
                  maxLines: 1,
                ),
              ),
            ),
            if (subText != null) ...[
              horizontalSpacing(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  subText,
                  style: AppTextStyle.ts12R(
                    color: valuesubTextColor ?? Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}
