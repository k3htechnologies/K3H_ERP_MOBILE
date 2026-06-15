import 'package:flutter/rendering.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> callLogStatusConfig = {
  'connected': StatusConfig(
    backgroundColor: Color(0x4A51E551),
    textColor: Color(0xFF48C848),
  ),

  'not connected': StatusConfig(
    backgroundColor: Color(0x4ACC00FF),
    textColor: Color(0xFF561F64),
  ),

  'wrong number': StatusConfig(
    backgroundColor: Color(0x1D1D1D26),
    textColor: Color(0xFF333333),
  ),

  'switched off': StatusConfig(
    backgroundColor: Color(0x26FBFF00),
    textColor: Color(0xFF7B6B28),
  ),

  'busy': StatusConfig(
    backgroundColor: Color(0x407E4604),
    textColor: Color(0xFF7E4604),
  ),

  'no answer': StatusConfig(
    backgroundColor: Color(0x261AA0DB),
    textColor: Color(0xFF1AA0DB),
  ),

  'disconnected': StatusConfig(
    backgroundColor: Color(0x26FF0037),
    textColor: Color(0xFFFF0037),
  ),

  'rescheduled': StatusConfig(
    backgroundColor: Color(0x33121258),
    textColor: Color(0xFF243965),
  ),
};
