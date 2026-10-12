import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> drawingDocumentStatusConfig = {
  'Good For Construction (GFC)': StatusConfig(
    backgroundColor: const Color(0xffff9f2d).withValues(alpha: 0.33),
    textColor: const Color(0xffff9f2d),
  ),

  'Advance': StatusConfig(
    backgroundColor: AppColor.lightBlue,
    textColor: AppColor.primary,
  ),
};
