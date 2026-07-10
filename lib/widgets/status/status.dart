import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
import 'package:k3h_erp_app/widgets/status/aop_status.dart';
import 'package:k3h_erp_app/widgets/status/approval_status.dart';
import 'package:k3h_erp_app/widgets/status/call_log_status.dart';
import 'package:k3h_erp_app/widgets/status/channel_partner_category_status.dart';
import 'package:k3h_erp_app/widgets/status/enquiry_status.dart';
import 'package:k3h_erp_app/widgets/status/inward_outward_status.dart';
import 'package:k3h_erp_app/widgets/status/project_status.dart';

Widget enquiryStatusWidget(String status, {TextStyle? textStyle}) {
  return commonStatusWidget(
    status: status,
    config: enquiryStatusConfig,
    textStyle: textStyle,
  );
}

Widget projectStatusWidget(String status, {TextStyle? textStyle}) {
  return commonStatusWidget(
    status: status,
    config: projectStatusConfig,
    textStyle: textStyle,
  );
}

Widget callLogStatusWidget(String status, {TextStyle? textStyle}) {
  return commonStatusWidget(
    status: status,
    config: callLogStatusConfig,
    textStyle: textStyle,
  );
}

Widget inwardOutwarDeliveryStatusWidget(String status, {TextStyle? textStyle}) {
  return commonStatusWidget(
    status: status,
    config: inwardOutwardDeliveryStatus,
    textStyle: textStyle,
  );
}

String formattedStatus(String status) {
  return status
      .toLowerCase()
      .split(' ')
      .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
}

Widget approvalStatusWidget(String status, {TextStyle? textStyle}) {
  final formatted = formattedStatus(status.trim());
  return commonStatusWidget(
    status: formatted,
    config: approvalStatusConfig,
    textStyle: textStyle ?? AppTextStyle.ts10M(),
  );
}

Widget aopStatusWidget(String status, {TextStyle? textStyle}) {
  return commonStatusWidget(
    status: status,
    config: aopStatusConfig,
    textStyle: textStyle,
  );
}

Widget channelPartnerCategoryStatusWidget(
  String status, {
  TextStyle? textStyle,
  bool showDashWhenEmpty = true,
}) {
  return commonStatusWidget(
    status: status,
    config: channelPartnerCategoryStatusConfig,
    textStyle: textStyle,
    showDashWhenEmpty: showDashWhenEmpty,
  );
}
