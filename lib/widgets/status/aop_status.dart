import 'dart:ui';

import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> aopStatusConfig = {
  'aop': StatusConfig(
    backgroundColor: const Color(0xFFEFF6FF), // blue-50
    textColor: const Color(0xFF2563EB), // blue-600
  ),

  'non-aop': StatusConfig(
    backgroundColor: const Color(0xFFF3F4F6), // gray-100
    textColor: const Color(0xFF374151), // gray-700
  ),

  'expire soon': StatusConfig(
    backgroundColor: const Color(0xFFFFF7ED), // orange-50
    textColor: const Color(0xFFEA580C), // orange-600
  ),

  'expired': StatusConfig(
    backgroundColor: const Color(0xFFFEF2F2), // red-50
    textColor: const Color(0xFFDC2626), // red-600
  ),
};
