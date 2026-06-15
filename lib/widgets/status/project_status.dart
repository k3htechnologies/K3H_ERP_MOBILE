import 'dart:ui';

import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> projectStatusConfig = {
  'up-coming': StatusConfig(
    backgroundColor: const Color(0xFFFFEDD5).withValues(alpha: 0.6),
    textColor: const Color(0xFFC2410C),
  ),

  'completed': StatusConfig(
    backgroundColor: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
    textColor: const Color(0xFF15803D),
  ),

  'on-going': StatusConfig(
    backgroundColor: const Color(0xFFDBEAFE).withValues(alpha: 0.6),
    textColor: const Color(0xFF1D4ED8),
  ),

  'on-hold': StatusConfig(
    backgroundColor: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
    textColor: const Color(0xFFA16207),
  ),

  'cancelled': StatusConfig(
    backgroundColor: const Color(0xFFFEE2E2).withValues(alpha: 0.6),
    textColor: const Color(0xFFB91C1C),
  ),

  'planning': StatusConfig(
    backgroundColor: const Color(0xFFEDE9FE).withValues(alpha: 0.6),
    textColor: const Color(0xFF6D28D9),
  ),
};
