import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> flatHandoverChecklistStatusConfig = {
  'yes': StatusConfig(
    backgroundColor: Color(0xffDCFCE7),
    textColor: AppColor.green20,
  ),

  'no': StatusConfig(
    backgroundColor: AppColor.lightRed,
    textColor: AppColor.missingInformationRed,
  ),

  'pending': StatusConfig(
    backgroundColor: AppColor.lightYellow,
    textColor: AppColor.brown,
  ),
};
