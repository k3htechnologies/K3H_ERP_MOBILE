import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> gatePassDashboardStatusConfig = {
  "rejected": StatusConfig(
    backgroundColor: Color(0xffFEE2E2),
    textColor: Color(0xffDC2626),
  ),
  "overstaying": StatusConfig(
    backgroundColor: Color(0xffF3E8FF),
    textColor: Color(0xff7E22CE),
  ),
  "not checked out": StatusConfig(
    backgroundColor: Color(0xffF1F5F9),
    textColor: Color(0xff334155),
  ),
  "not arrived": StatusConfig(
    backgroundColor: Color(0xffDDF1FA),
    textColor: Color(0xff0284C7),
  ),
  "expected": StatusConfig(
    backgroundColor: Color(0xffFFEDD5),
    textColor: Color(0xffEA580C),
  ),
  "pending approval": StatusConfig(
    backgroundColor: AppColor.lightYellow,
    textColor: AppColor.rustOrange,
  ),
  "pending": StatusConfig(
    backgroundColor: AppColor.lightYellow,
    textColor: AppColor.rustOrange,
  ),
  "approved": StatusConfig(
    backgroundColor: Color(0xffDCFCE7),
    textColor: Color(0xff16A34A),
  ),
  "currently inside": StatusConfig(
    backgroundColor: Color(0xffD7F8E9),
    textColor: Color(0xff10B981),
  ),
  "currently in": StatusConfig(
    backgroundColor: Color(0xffD7F8E9),
    textColor: Color(0xff10B981),
  ),
  "checked out": StatusConfig(
    backgroundColor: Color(0xffD8E2FF),
    textColor: Color(0xff2563EB),
  ),
};
