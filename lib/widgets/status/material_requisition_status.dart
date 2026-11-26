import 'dart:ui';

import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> materialRequisitionStatusConfig = {
  'completed': StatusConfig(
    backgroundColor: const Color(0x4A51E551),
    textColor: const Color(0xFF48C848),
  ),

  'ongoing': StatusConfig(
    backgroundColor: const Color(0xFFDBEAFE),
    textColor: const Color(0xFF2563EB),
  ),

  'closed': StatusConfig(
    backgroundColor: const Color(0x26FF0037),
    textColor: const Color(0xFFFF0037),
  ),
};
