import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
        Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
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

// BUILD COLUMN TITLE VALUE WITHOUT EXPANDED
Widget buildColumnTitleValueNormal({
  required String title,
  required String value,
  TextStyle? valueTextStyle,
  Widget? customValueWidget,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),

      verticalSpacing(height: 4),

      customValueWidget ??
          Text(
            value.isEmpty ? "-" : value,
            style: valueTextStyle ?? AppTextStyle.ts14M(color: AppColor.black),
          ),
    ],
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
      style: AppTextStyle.ts10M(color: txt),
    ),
  );

  if (expand) {
    return Flexible(child: chip);
  }

  return chip;
}

// BUILD COMMON ACTION CARD
Widget actionCardWidget({
  required String createdBy,
  required DateTime createdDate,
  String? modifiedBy,
  DateTime? modifiedDate,
}) {
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
            buildColumnTitleValue(title: "Created By", value: createdBy),
            buildColumnTitleValue(
              title: "Created Date",
              value: formatDate(createdDate),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColumnTitleValue(
              title: "Modified By",
              value:
                  (modifiedBy != null || modifiedBy!.isNotEmpty)
                      ? modifiedBy
                      : "-",
            ),
            buildColumnTitleValue(
              title: "Modified Date",
              value:
                  (modifiedDate == null ||
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

// BUILD DOCUMENT ROW
Widget buildDocumentRow({
  required BuildContext context,
  required String docNumber,
  required String url,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Text(
          docNumber,
          style: AppTextStyle.ts14M(color: AppColor.black),
        ),
      ),
      horizontalSpacing(),
      if (url.isNotEmpty && url != "-")
        CustomIconButton(
          onPressed: () {
            if (url.isNotEmpty && url != "-") {
              showFilePreviewDialog(context, url.split(","));
            }
          },
          icon: Icon(
            Icons.remove_red_eye_outlined,
            size: 16,
            color: AppColor.primary,
          ),
        ),
    ],
  );
}

Widget approvalStatusWidget(String status) {
  final trimmed = status.trim();

  final s = trimmed.toLowerCase();

  switch (s) {
    case 'approved':
      return statusChip(status, AppColor.lightGreen, AppColor.green);

    case 'rejected':
      return statusChip(status, AppColor.lightRed, AppColor.red);

    case 'pending':
      return statusChip(status, AppColor.lightYellow, AppColor.brown);

    case 'partial approved':
      return statusChip(status, AppColor.lightPurple, AppColor.purple);

    default:
      return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
  }
}

Widget showSiteSelectedWidget() {
  String projectName = getProject().projectName;
  return Container(
    decoration: commonCardDecoration(),
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Project : ", style: AppTextStyle.ts14M(color: AppColor.grey)),
        Flexible(
          child: Text(
            projectName.isEmpty ? "No Project Selected" : projectName,
            style:
                projectName.isEmpty
                    ? AppTextStyle.ts14R(color: AppColor.black)
                    : AppTextStyle.ts14SB(color: AppColor.black),
          ),
        ),
      ],
    ),
  );
}

// INFO HELPER CARD
Widget infoCard(
  List<Map<String, dynamic>> items, {
  String? title,
  Widget? titleWidget,
  Color? bgColor,
  Color? borderColor,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    margin: EdgeInsets.symmetric(vertical: 5.h),
    decoration: BoxDecoration(
      color: bgColor ?? AppColor.lightBlue.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: borderColor ?? AppColor.primary.withValues(alpha: 0.6),
        width: .5,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title, style: AppTextStyle.ts16SB()),
          verticalSpacing(),
        ],
        if (titleWidget != null) ...[titleWidget, verticalSpacing()],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate((items.length / 2).ceil(), (index) {
            final first = items[index * 2];
            final second =
                (index * 2 + 1 < items.length) ? items[index * 2 + 1] : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: first["title"] ?? "",
                    value: first["widget"] != null ? "" : first["value"] ?? "",
                    customValueWidget: first["widget"],
                  ),

                  second != null
                      ? buildColumnTitleValue(
                        title: second["title"] ?? "",
                        value:
                            second["widget"] != null
                                ? ""
                                : second["value"] ?? "",
                        customValueWidget: second["widget"],
                      )
                      : const Spacer(),
                ],
              ),
            );
          }),
        ),
      ],
    ),
  );
}
