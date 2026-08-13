import 'dart:ui';

import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> channelPartnerCategoryStatusConfig = {
  'ipc': StatusConfig(
    backgroundColor: Color(0xFFE9C4F8),
    textColor: const Color(0xFF561F64),
  ),

  'icp': StatusConfig(
    backgroundColor: Color(0x4AFFA500),
    textColor: Color(0xFFFF6600),
  ),

  'rcp': StatusConfig(
    backgroundColor: Color(0xFFDBEAFE),
    textColor: Color(0xFF1D4ED8),
  ),
};
