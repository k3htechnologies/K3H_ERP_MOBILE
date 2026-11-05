import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> gatePassDashboardStatusConfig = {
  "checked out": StatusConfig(
    backgroundColor: AppColor.checkedOutBgColor,
    textColor: AppColor.checkedOut,
  ),
  "currently in": StatusConfig(
    backgroundColor: Color(0xffD7F8E9),
    textColor: Color(0xff10B981),
  ),
  "not checked out": StatusConfig(
    backgroundColor: Color(0xffFFE4E6),
    textColor: Color(0xffE11D48),
  ),
  "overstaying": StatusConfig(
    backgroundColor: Color(0xffF3E8FF),
    textColor: Color(0xff7E22CE),
  ),
  "expected": StatusConfig(
    backgroundColor: Color(0xffFFEDD5),
    textColor: Color(0xffEA580C),
  ),
  "pending approval": StatusConfig(
    backgroundColor: AppColor.lightYellow,
    textColor: AppColor.rustOrange,
  ),
  "approved": StatusConfig(
    backgroundColor: Color(0xffDCFCE7),
    textColor: Color(0xff16A34A),
  ),
  "rejected": StatusConfig(
    backgroundColor: AppColor.lightRed,
    textColor: Color(0xffDC2626),
  ),
  "not arrived": StatusConfig(
    backgroundColor: AppColor.lightBlueBg2,
    textColor: AppColor.slightDarkBlue,
  ),
};
