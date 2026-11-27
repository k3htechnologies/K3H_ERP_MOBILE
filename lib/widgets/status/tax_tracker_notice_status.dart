import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> taxTrackerNoticeStatusConfig = {
  'appeal filed': StatusConfig(
    backgroundColor: Color(0xFFE8F9F8),
    textColor: Color(0xff0AA3C5),
  ),

  'reply pending': StatusConfig(
    backgroundColor: Color(0xFFFFEDD5),
    textColor: AppColor.brownYellowText,
  ),

  'non-favourable': StatusConfig(
    backgroundColor: AppColor.lightRed,
    textColor: AppColor.missingInformationRed,
  ),
  'reply submitted': StatusConfig(
    backgroundColor: AppColor.lightBlue,
    textColor: AppColor.primary,
  ),
};
