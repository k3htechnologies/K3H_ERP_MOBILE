import 'package:flutter/material.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> paymentModeStatusConfig = {
  'cheque': StatusConfig(
    backgroundColor: Color(0x1A2196F3),
    textColor: Color(0xFF2196F3),
  ),
  'demand draft': StatusConfig(
    backgroundColor: Color(0x1A9C27B0),
    textColor: Color(0xFF9C27B0),
  ),
  'imps': StatusConfig(
    backgroundColor: Color(0x1A4CAF50),
    textColor: Color(0xFF4CAF50),
  ),
  'neft': StatusConfig(
    backgroundColor: Color(0x1AFF9800),
    textColor: Color(0xFFFF9800),
  ),
  'online transfer': StatusConfig(
    backgroundColor: Color(0x1A009688),
    textColor: Color(0xFF009688),
  ),
  'rtgs': StatusConfig(
    backgroundColor: Color(0x1A673AB7),
    textColor: Color(0xFF673AB7),
  ),
  'upi': StatusConfig(
    backgroundColor: Color(0x1AF44336),
    textColor: Color(0xFFF44336),
  ),
};
