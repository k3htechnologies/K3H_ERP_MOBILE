import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_date_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewUnitModulationCustomizationHistoryScreen extends StatefulWidget {
  final String version;
  final List<FlatAlterationRequestsModel> unitModulationDetails;
  const ViewUnitModulationCustomizationHistoryScreen({
    super.key,
    required this.unitModulationDetails,
    required this.version,
  });

  @override
  State<ViewUnitModulationCustomizationHistoryScreen> createState() =>
      _ViewUnitModulationCustomizationHistoryScreenState();
}

class _ViewUnitModulationCustomizationHistoryScreenState
    extends State<ViewUnitModulationCustomizationHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Modified Requests > Activity > Version ${widget.version}",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ...widget.unitModulationDetails.map((unitModulationDetail) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.lightGreyBackground,
                  border: Border.all(color: AppColor.grey50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValueNormal(
                      title: "Unit / Modulation / Customization Remark",
                      value: unitModulationDetail.flatAlterationRemark,
                    ),

                    verticalSpacing(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Created By",
                            value: unitModulationDetail.createdBy,
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Created Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              unitModulationDetail.createdDate,
                            ),
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Modified By",
                            value: unitModulationDetail.modifiedBy,
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Modified Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              unitModulationDetail.modifiedDate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
