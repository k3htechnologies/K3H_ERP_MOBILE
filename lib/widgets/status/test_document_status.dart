import 'dart:ui';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';

final Map<String, StatusConfig> testDocumentStatusConfig = {
  'applied': StatusConfig(
    backgroundColor: Color(0xffDCFCE7),
    textColor: AppColor.green20,
  ),

  'doc missing': StatusConfig(
    backgroundColor: AppColor.warning,
    textColor: AppColor.warning20,
  ),

  'in process': StatusConfig(
    backgroundColor: AppColor.brown,
    textColor: AppColor.lightYellow,
  ),
  'issued': StatusConfig(
    backgroundColor: AppColor.darkBackground.withValues(alpha: 0.29),
    textColor: AppColor.darkBackground.withValues(alpha: 0.29),
  ),
  'not applied': StatusConfig(
    backgroundColor: AppColor.grey2,
    textColor: AppColor.grey2,
  ),
  'not applicable': StatusConfig(
    backgroundColor: AppColor.grey2,
    textColor: AppColor.grey2,
  ),
  'paid': StatusConfig(
    backgroundColor: AppColor.green20,
    textColor: AppColor.green20,
  ),
  'payment due': StatusConfig(
    backgroundColor: AppColor.purple20,
    textColor: AppColor.purple20,
  ),
  'rejected': StatusConfig(
    backgroundColor: AppColor.lightRed,
    textColor: AppColor.lightRed,
  ),
};
