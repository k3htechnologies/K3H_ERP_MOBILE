import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
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

Widget buildRowTitleCount({
  required String title,
  required String value,
  TextStyle? valueTextStyle,
  bool singleLine = true,
  VoidCallback? onValueTap,
  double? fixesWidth,
}) {
  return buildRowTitleValue(
    fixesWidth: fixesWidth ?? 140,
    title: title,
    value: value,
    customValueWidget: InkWell(
      onTap: (double.tryParse(value) ?? 0) > 0 ? onValueTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          value.isNotEmpty ? (double.tryParse(value) ?? 0).addCommas() : "-",
          maxLines: singleLine ? 1 : null,
          overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
          style: AppTextStyle.ts14SB(
            color:
                ((double.tryParse(value) ?? 0) > 0 && onValueTap != null)
                    ? AppColor.primary
                    : AppColor.grey,
          ),
        ),
      ),
    ),
  );
}

// BUILD COLUMN TITLE VALUE
Widget buildColumnTitleValue({
  required String title,
  required String? value,
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
              (value == null || value.isEmpty) ? "-" : value,
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
            horizontalSpacing(width: 20.0),
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
            horizontalSpacing(width: 20.0),
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
  required String title,
  bool? iconWithoutBg,
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
        (iconWithoutBg != null && iconWithoutBg == true)
            ? GestureDetector(
              onTap: () {
                if (url.isNotEmpty && url != "-") {
                  showFilePreviewDialog(context, url.split(","), title: title);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  size: 16,
                  color: AppColor.primary,
                ),
              ),
            )
            : CustomIconButton(
              onPressed: () {
                if (url.isNotEmpty && url != "-") {
                  showFilePreviewDialog(context, url.split(","), title: title);
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

Widget showSiteSelectedWidget({String? projectName}) {
  String localProject =
      (projectName != null && projectName.trim().isNotEmpty)
          ? projectName
          : getProject().projectName.trim();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        decoration: commonCardDecoration(),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Project : ",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              TextSpan(
                text:
                    localProject.isEmpty ? "No Project Selected" : localProject,
                style:
                    localProject.isEmpty
                        ? AppTextStyle.ts14R(color: AppColor.black)
                        : AppTextStyle.ts14SB(color: AppColor.black),
              ),
            ],
          ),
        ),
      ),
    ],
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
                children: [
                  buildColumnTitleValue(
                    title: first["title"] ?? "",
                    value: first["widget"] != null ? "" : first["value"] ?? "",
                    customValueWidget: first["widget"],
                  ),

                  if (second != null) ...[
                    const SizedBox(width: 10),
                    buildColumnTitleValue(
                      title: second["title"] ?? "",
                      value:
                          second["widget"] != null ? "" : second["value"] ?? "",
                      customValueWidget: second["widget"],
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    ),
  );
}

// GETTER FOR FOLLOWUP STATUS
Widget followUpStatusTextWidget(String? enquiryFollowUpDays) {
  if (enquiryFollowUpDays == null || enquiryFollowUpDays.isEmpty) {
    return Text("-", style: AppTextStyle.ts14M());
  }
  final String status = enquiryFollowUpDays.toLowerCase();

  Color statusColor;

  switch (status) {
    case "no follow up":
      statusColor = AppColor.black;
      break;
    case var s when s.toLowerCase().contains("today"):
      statusColor = Color(0xFF1AA0DB);
      break;
    case var s when s.toLowerCase().contains("overdue"):
      statusColor = AppColor.red;
      break;
    default:
      statusColor = AppColor.green;
  }

  return Text(
    enquiryFollowUpDays,
    style: AppTextStyle.ts14M(color: statusColor),
  );
}

Widget buildRowWrapper({required Widget child}) {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [child]);
}

class DottedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DottedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
