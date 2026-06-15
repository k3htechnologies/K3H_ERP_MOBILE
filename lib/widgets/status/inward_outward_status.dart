import 'package:flutter/material.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> inwardOutwardDeliveryStatus = {
  'delivered': StatusConfig(
    backgroundColor: Color(0x4AFFA500),
    textColor: Color(0xFFFF6600),
  ),
  'acknowledged': StatusConfig(
    backgroundColor: Color(0x26FF0037),
    textColor: Color(0xFFFF0037),
  ),
};
