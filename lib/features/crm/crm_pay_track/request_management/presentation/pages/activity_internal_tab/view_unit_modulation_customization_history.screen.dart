import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_date_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewUnitModulationCustomizationHistoryScreen extends StatefulWidget {
  final FlatAlterationRequestsModel unitModulationDetail;
  const ViewUnitModulationCustomizationHistoryScreen({
    super.key,
    required this.unitModulationDetail,
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
        screenTitle:
            "Modified Requests > Activity > Version ${widget.unitModulationDetail.versionNumber}",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.lightGreyBackground,
            border: Border.all(color: AppColor.grey50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "Unit / Modulation / Customization Remark",
                      value: widget.unitModulationDetail.flatAlterationRemark,
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "Created By",
                      value: widget.unitModulationDetail.createdBy,
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "Created Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.unitModulationDetail.createdDate,
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacing(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "Modified By",
                      value: widget.unitModulationDetail.modifiedBy,
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "Modified Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.unitModulationDetail.modifiedDate,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
