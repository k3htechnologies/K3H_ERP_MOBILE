import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> activeInactiveStatusConfig = {
  'active': StatusConfig(
    backgroundColor: Color(0xffDCFCE7),
    textColor: AppColor.darkGreen,
  ),

  'inactive': StatusConfig(
    backgroundColor: AppColor.red.withValues(alpha: 0.2),
    textColor: AppColor.red, // red-600
  ),
};
