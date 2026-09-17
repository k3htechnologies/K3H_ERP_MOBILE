import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> gatePassPurposeStatusConfig = {
  'interview': StatusConfig(
    backgroundColor: Color(0xFFD1FAE5),
    textColor: Color(0xFF065F46),
  ),

  'meeting': StatusConfig(
    backgroundColor: const Color(0xFFFBFF00).withValues(alpha: 0.15),
    textColor: const Color(0xFF7B6B28),
  ),

  'delivery': StatusConfig(
    backgroundColor: const Color(0xFF51E551).withValues(alpha: 0.29),
    textColor: const Color(0xFF48C848),
  ),
  'guest': StatusConfig(
    backgroundColor: Color(0xFFE9C4F8),
    textColor: const Color(0xFF561F64),
  ),

  'others': StatusConfig(
    backgroundColor: AppColor.lightRed,
    textColor: AppColor.missingInformationRed,
  ),
};
