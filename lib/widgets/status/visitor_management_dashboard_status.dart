import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> visitorManagementDashboardStatusConfig = {
  "delivery": StatusConfig(
    backgroundColor: AppColor.lightGreen,
    textColor: AppColor.bookingDoneColorText,
  ),
  "guest": StatusConfig(
    backgroundColor: AppColor.lightPurple,
    textColor: AppColor.purple,
  ),
  "interview": StatusConfig(
    backgroundColor: Color(0x1D1D1D26),
    textColor: Color(0xff333333),
  ),
  "meeting": StatusConfig(
    backgroundColor: AppColor.lightYellow,
    textColor: AppColor.brown,
  ),
};
