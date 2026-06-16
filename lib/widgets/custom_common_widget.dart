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

// STATUS CHIP
Widget statusChip(
  String text,
  Color bg,
  Color txt, {
  bool expand = false,
  TextStyle? textStyle,
}) {
  final chip = Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: textStyle ?? AppTextStyle.ts10M(color: txt),
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
  final formatted = formattedStatus(trimmed);

  switch (trimmed.toLowerCase()) {
    case 'approved':
      return statusChip(formatted, Color(0xffDCFCE7), AppColor.green20);

    case 'rejected':
      return statusChip(
        formatted,
        AppColor.lightRed,
        AppColor.missingInformationRed,
      );

    case 'pending':
      return statusChip(formatted, AppColor.lightYellow, AppColor.brown);

    case 'partial approved':
      return statusChip(formatted, AppColor.lightPurple, Color(0xff561F64));

    default:
      return statusChip(
        formatted,
        AppColor.lightGreyBackground,
        AppColor.black,
      );
  }
}

String formattedStatus(String status) {
  return status
      .toLowerCase()
      .split(' ')
      .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
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

// ENQUIRY STATUS WIDGET
Widget enquiryStatusWidget(String status, {TextStyle? textStyle}) {
  final trimmed = status.trim();

  // IF STATUS IS EMPTY THEN SHOW DASH WITH DEFAULT STYLE
  final defaultStyle = AppTextStyle.ts12M();

  // SHOW DASH IF STATUS IS EMPTY
  if (trimmed.isEmpty) {
    return statusChip(
      "-",
      AppColor.lightGreyBackground,
      AppColor.black,
      textStyle: textStyle ?? defaultStyle,
    );
  }

  final s = trimmed.toLowerCase();

  switch (s) {
    case 'booking done':
      return statusChip(
        status,
        const Color(0xFF51E551).withValues(alpha: 0.29),
        const Color(0xFF48C848),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF48C848),
        ),
      );

    case 'blocked':
      return statusChip(
        status,
        const Color(0xFFCC00FF).withValues(alpha: 0.29),
        const Color(0xFF561F64),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF561F64),
        ),
      );

    case 'cancelled':
      return statusChip(
        status,
        const Color(0xFF1D1D1D).withValues(alpha: 0.15),
        const Color(0xFF333333),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF333333),
        ),
      );

    case 'negotiation':
      return statusChip(
        status,
        const Color(0xFFFBFF00).withValues(alpha: 0.15),
        const Color(0xFF7B6B28),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF7B6B28),
        ),
      );

    case 'lost':
      return statusChip(
        status,
        const Color(0xFFFF0037).withValues(alpha: 0.15),
        const Color(0xFFFF0037),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFFFF0037),
        ),
      );

    case 'retention':
      return statusChip(
        status,
        const Color(0xFF1AA0DB).withValues(alpha: 0.15),
        const Color(0xFF1AA0DB),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF1AA0DB),
        ),
      );

    case 're-visit scheduled':
    case 're - visit scheduled':
      return statusChip(
        status,
        const Color(0xFFD1FAE5),
        const Color(0xFF065F46),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF065F46),
        ),
      );

    case 're-visit proposed':
    case 're - visit proposed':
    case 'follow - up':
      return statusChip(
        status,
        const Color(0xFFFFA500).withValues(alpha: 0.29),
        const Color(0xFFFF6600),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFFFF6600),
        ),
      );

    case 're - visit':
      return statusChip(
        status,
        const Color(0xFFC6E7F6),
        const Color(0xFF087DB0),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF087DB0),
        ),
      );

    case 'site visit':
    case 'unit selection / blocked':
      return statusChip(
        status,
        const Color(0xFFFECACA),
        const Color(0xFF7F1D1D),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF7F1D1D),
        ),
      );

    default:
      return statusChip(
        status,
        AppColor.lightGreyBackground,
        AppColor.black,
        textStyle: textStyle ?? defaultStyle,
      );
  }
}

// PROJECT STATUS WIDGET
Widget projectStatusWidget(String projectStatus, {TextStyle? textStyle}) {
  final trimmed = projectStatus.trim();

  final defaultStyle = AppTextStyle.ts12M();

  // SHOW DASH IF STATUS IS EMPTY
  if (trimmed.isEmpty) {
    return statusChip(
      "-",
      AppColor.lightGreyBackground,
      AppColor.black,
      textStyle: textStyle ?? defaultStyle,
    );
  }

  final s = trimmed.toLowerCase();

  switch (s) {
    case 'up-coming':
      return statusChip(
        projectStatus,
        const Color(0xFFFFEDD5).withValues(alpha: 0.6),
        const Color(0xFFC2410C),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFFC2410C),
        ),
      );

    case 'completed':
      return statusChip(
        projectStatus,
        const Color(0xFFDCFCE7).withValues(alpha: 0.6),
        const Color(0xFF15803D),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF15803D),
        ),
      );

    case 'on-going':
      return statusChip(
        projectStatus,
        const Color(0xFFDBEAFE).withValues(alpha: 0.6),
        const Color(0xFF1D4ED8),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF1D4ED8),
        ),
      );

    case 'on-hold':
      return statusChip(
        projectStatus,
        const Color(0xFFFEF3C7).withValues(alpha: 0.6),
        const Color(0xFFA16207),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFFA16207),
        ),
      );

    case 'cancelled':
      return statusChip(
        projectStatus,
        const Color(0xFFFEE2E2).withValues(alpha: 0.6),
        const Color(0xFFB91C1C),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFFB91C1C),
        ),
      );

    case 'planning':
      return statusChip(
        projectStatus,
        const Color(0xFFEDE9FE).withValues(alpha: 0.6),
        const Color(0xFF6D28D9),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF6D28D9),
        ),
      );

    default:
      return statusChip(
        projectStatus,
        AppColor.lightGreyBackground,
        AppColor.black,
        textStyle: textStyle ?? defaultStyle,
      );
  }
}

Widget callLogStatusWidget(String callLogStatus, {TextStyle? textStyle}) {
  final trimmed = callLogStatus.trim();

  final defaultStyle = AppTextStyle.ts12M();

  // SHOW DASH IF STATUS IS EMPTY
  if (trimmed.isEmpty) {
    return Text("-", style: textStyle ?? defaultStyle);
  }

  final s = trimmed.toLowerCase();

  switch (s) {
    case 'connected':
      return statusChip(
        callLogStatus,
        const Color(0x4A51E551),
        const Color(0xFF48C848),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF48C848),
        ),
      );

    case 'not connected':
      return statusChip(
        callLogStatus,
        const Color(0x4ACC00FF),
        const Color(0xFF561F64),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF561F64),
        ),
      );

    case 'wrong number':
      return statusChip(
        callLogStatus,
        const Color(0x1D1D1D26),
        const Color(0xFF333333),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF333333),
        ),
      );

    case 'switched off':
      return statusChip(
        callLogStatus,
        const Color(0x26FBFF00),
        const Color(0xFF7B6B28),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF7B6B28),
        ),
      );

    case 'busy':
      return statusChip(
        callLogStatus,
        const Color(0x407E4604),
        const Color(0xFF7E4604),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF7E4604),
        ),
      );

    case 'no answer':
      return statusChip(
        callLogStatus,
        const Color(0x261AA0DB),
        const Color(0xFF1AA0DB),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF1AA0DB),
        ),
      );

    case 'disconnected':
      return statusChip(
        callLogStatus,
        const Color(0x26FF0037),
        const Color(0xFFFF0037),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFFFF0037),
        ),
      );

    case 'rescheduled':
      return statusChip(
        callLogStatus,
        const Color(0x33121258),
        const Color(0xFF243965),
        textStyle: (textStyle ?? defaultStyle).copyWith(
          color: const Color(0xFF243965),
        ),
      );

    default:
      return statusChip(
        callLogStatus,
        AppColor.lightGreyBackground,
        AppColor.black,
        textStyle: textStyle ?? defaultStyle,
      );
  }
}

// GETTER FOR FOLLOWUP STATUS
Widget followUpStatusTextWidget(DateTime? nextFollowUpDate) {
  String getFollowUpStatus(DateTime? nextFollowUpDate) {
    if (nextFollowUpDate == null) return "No Follow up";

    final DateTime today = DateTime.now();

    if (nextFollowUpDate.year == 1970) {
      return "No Follow up";
    }

    final DateTime currentDate = DateTime(today.year, today.month, today.day);

    final DateTime followUpDate = DateTime(
      nextFollowUpDate.year,
      nextFollowUpDate.month,
      nextFollowUpDate.day,
    );

    final int difference = followUpDate.difference(currentDate).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference > 0) {
      return "Follow up in $difference day(s)";
    } else {
      return "Follow up overdue by ${difference.abs()} day(s)";
    }
  }

  final String status = getFollowUpStatus(nextFollowUpDate);

  Color statusColor;

  switch (status) {
    case "No Follow up":
      statusColor = AppColor.black;
      break;
    case "Today":
      statusColor = Color(0xFF1AA0DB);
      break;
    case var s when s.toLowerCase().contains("overdue"):
      statusColor = AppColor.red;
      break;
    default:
      statusColor = AppColor.green;
  }

  return Text(status, style: AppTextStyle.ts14M(color: statusColor));
}

Widget buildRowWrapper({required Widget child}) {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [child]);
}
