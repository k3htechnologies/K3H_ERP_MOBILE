import 'dart:ui';
import '../custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> litigationPriorityStatusConfig = {
  'critical': StatusConfig(
    backgroundColor: const Color(0xE5FECACA),
    textColor: const Color(0xFFB91C1C),
  ),
  'non - critical': StatusConfig(
    backgroundColor: const Color(0xFFF3F4F6), // gray-100
    textColor: const Color(0xFF374151), // gray-700
  ),
};
