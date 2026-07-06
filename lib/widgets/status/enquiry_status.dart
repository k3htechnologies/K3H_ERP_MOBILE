import 'dart:ui';

import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> enquiryStatusConfig = {
  'booking done': StatusConfig(
    backgroundColor: const Color(0xFF51E551).withValues(alpha: 0.29),
    textColor: const Color(0xFF48C848),
  ),

  'blocked': StatusConfig(
    backgroundColor: Color(0xFFE9C4F8),
    textColor: const Color(0xFF561F64),
  ),

  'cancelled': StatusConfig(
    backgroundColor: const Color(0xFF1D1D1D).withValues(alpha: 0.15),
    textColor: const Color(0xFF333333),
  ),

  'negotiation': StatusConfig(
    backgroundColor: const Color(0xFFFBFF00).withValues(alpha: 0.15),
    textColor: const Color(0xFF7B6B28),
  ),

  'lost': StatusConfig(
    backgroundColor: const Color(0xFFFF0037).withValues(alpha: 0.15),
    textColor: const Color(0xFFFF0037),
  ),

  'retention': StatusConfig(
    backgroundColor: const Color(0xFF1AA0DB).withValues(alpha: 0.15),
    textColor: const Color(0xFF1AA0DB),
  ),

  're-visit scheduled': StatusConfig(
    backgroundColor: Color(0xFFD1FAE5),
    textColor: Color(0xFF065F46),
  ),

  're - visit scheduled': StatusConfig(
    backgroundColor: Color(0xFFD1FAE5),
    textColor: Color(0xFF065F46),
  ),

  're-visit proposed': StatusConfig(
    backgroundColor: Color(0x4AFFA500),
    textColor: Color(0xFFFF6600),
  ),

  're - visit proposed': StatusConfig(
    backgroundColor: Color(0x4AFFA500),
    textColor: Color(0xFFFF6600),
  ),

  'follow - up': StatusConfig(
    backgroundColor: Color(0xFFFFDEC7),
    textColor: Color(0xFF7E4604),
  ),

  're - visit': StatusConfig(
    backgroundColor: Color(0xFFC6E7F6),
    textColor: Color(0xFF087DB0),
  ),

  'site visit': StatusConfig(
    backgroundColor: Color(0xFFFECACA),
    textColor: Color(0xFF7F1D1D),
  ),

  'repeat re - visit': StatusConfig(
    backgroundColor: Color(0xFFDBEAFE),
    textColor: Color(0xFF1D4ED8),
  ),

  'unit selection / blocked': StatusConfig(
    backgroundColor: const Color(0xFFF3E8FF),
    textColor: const Color(0xFF6B21A8),
  ),
};
