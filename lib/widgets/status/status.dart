import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
import 'package:k3h_erp_app/widgets/status/active_inactive_status.dart';
import 'package:k3h_erp_app/widgets/status/aop_status.dart';
import 'package:k3h_erp_app/widgets/status/approval_status.dart';
import 'package:k3h_erp_app/widgets/status/call_log_status.dart';
import 'package:k3h_erp_app/widgets/status/channel_partner_category_status.dart';
import 'package:k3h_erp_app/widgets/status/enquiry_status.dart';
import 'package:k3h_erp_app/widgets/status/flat_handover_checklist.dart';
import 'package:k3h_erp_app/widgets/status/gate_pass_purpose_status.dart';
import 'package:k3h_erp_app/widgets/status/inward_outward_status.dart';
import 'package:k3h_erp_app/widgets/status/payment_mode_status.dart';
import 'package:k3h_erp_app/widgets/status/project_status.dart';

Widget enquiryStatusWidget(String status, {TextStyle? textStyle}) {
  return commonStatusWidget(
    status: status,
    config: enquiryStatusConfig,
    textStyle: textStyle,
  );
}

Widget projectStatusWidget(
  String status, {
  TextStyle? textStyle,
  bool showLeading = false,
}) {
  final config = projectStatusConfig[status.toLowerCase()];

  return commonStatusWidget(
    status: status,
    config: projectStatusConfig,
    textStyle: textStyle,
    leading:
        showLeading
            ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: config?.textColor ?? const Color(0xFF000000),
                shape: BoxShape.circle,
              ),
            )
            : null,
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

Widget aopStatusWidget(
  String status, {
  TextStyle? textStyle,
  Widget? leading,
  Widget? trailing,
}) {
  return commonStatusWidget(
    status: status,
    config: aopStatusConfig,
    textStyle: textStyle,
    leading: leading,
    trailing: trailing,
  );
}

Widget channelPartnerCategoryStatusWidget(
  String status, {
  TextStyle? textStyle,
}) {
  String localStatus = '';
  switch (status.toLowerCase()) {
    case String s when s.contains('ipc'):
      localStatus = "IPC";
      break;

    case String s when s.contains('icp'):
      localStatus = "ICP";
      break;
    case String s when s.contains('rcp'):
      localStatus = "RCP";
      break;
    default:
      break;
  }
  return commonStatusWidget(
    status: localStatus,
    config: channelPartnerCategoryStatusConfig,
    textStyle: textStyle,
  );
}

Widget activeInactiveStatusWidget(
  String status, {
  TextStyle? textStyle,
  Widget? leading,
  Widget? trailing,
}) {
  final config = activeInactiveStatusConfig[status.toLowerCase()];
  return commonStatusWidget(
    status: status,
    config: activeInactiveStatusConfig,
    textStyle: textStyle,
    leading: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: config?.textColor ?? const Color(0xFF000000),
        shape: BoxShape.circle,
      ),
    ),
    trailing: trailing,
  );
}

Widget flatHandoverChecklistStatusWidget(
  String status, {
  TextStyle? textStyle,
}) {
  final formatted = formattedStatus(status.trim());
  return commonStatusWidget(
    status: formatted,
    config: flatHandoverChecklistStatusConfig,
    textStyle: textStyle ?? AppTextStyle.ts10M(),
  );
}

Widget paymentModeStatusWidget(
  String status, {
  TextStyle? textStyle,
  Widget? leading,
  Widget? trailing,
}) {
  return commonStatusWidget(
    status: status,
    config: paymentModeStatusConfig,
    textStyle: textStyle,
    leading: leading,
    trailing: trailing,
  );
}

Widget gatePassPurposeWidget(String status, {TextStyle? textStyle}) {
  final formatted = formattedStatus(status.trim());
  return commonStatusWidget(
    status: formatted,
    config: gatePassPurposeStatusConfig,
    textStyle: textStyle ?? AppTextStyle.ts10M(),
  );
}
