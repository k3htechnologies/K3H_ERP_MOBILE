import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> clientLoanReportStatusConfig = {
  'active': StatusConfig(
    backgroundColor: Color(0xffECFDF5),
    textColor: Color(0xff047857),
  ),

  'closed': StatusConfig(
    backgroundColor: AppColor.lightRed,
    textColor: AppColor.missingInformationRed,
  ),
};
