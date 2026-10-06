import 'dart:ui';

import '../custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> budgetLevelConfig = {
  'L1': StatusConfig(
    backgroundColor: const Color(0xFF00236F),
    textColor: const Color(0xFFFFFFFF),
  ),
  'L2': StatusConfig(
    backgroundColor: const Color(0xFF4F46E5),
    textColor: const Color(0xFFFFFFFF),
  ),
  'L3': StatusConfig(
    backgroundColor: const Color.fromARGB(255, 69, 85, 109),
    textColor: const Color(0xFFFFFFFF),
  ),
  'L4': StatusConfig(
    backgroundColor: const Color(0xFF0F766E),
    textColor: const Color(0xFFFFFFFF),
  ),
};
