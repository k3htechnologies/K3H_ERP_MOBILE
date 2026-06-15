import 'package:flutter/material.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
import 'package:k3h_erp_app/widgets/status/call_log_status.dart';
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
