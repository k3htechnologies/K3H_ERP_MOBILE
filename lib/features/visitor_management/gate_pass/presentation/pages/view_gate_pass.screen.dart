import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/model/gate_pass.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_date_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewGatePassScreen extends StatefulWidget {
  final GatePassModel? gatePassModel;
  const ViewGatePassScreen({super.key, this.gatePassModel});

  @override
  State<ViewGatePassScreen> createState() => _ViewGatePassScreenState();
}

class _ViewGatePassScreenState extends State<ViewGatePassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Gate Pass",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gatePassPurposeWidget(widget.gatePassModel!.purpose),
            verticalSpacing(),
            SectionCard(
              title: 'Gate Pass Details',
              titleTextColor: AppColor.purple,
              headerBackgroundColor: AppColor.lightPurple,
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Visitor Name",
                      value: widget.gatePassModel!.fullName,
                      customValueWidget: DocumentPreviewText(
                        title: widget.gatePassModel!.fullName,
                        text: widget.gatePassModel!.fullName,
                        fileUrl: widget.gatePassModel!.photoUrl,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Address",
                      value: widget.gatePassModel!.address,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Mobile Number",
                      value: widget.gatePassModel!.mobileNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Appointment With",
                      value: widget.gatePassModel!.employeeName,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Appointment Date",
                      value: formatDate(widget.gatePassModel!.passDateTime),
                    ),
                    buildColumnTitleValue(
                      title: "Out Date",
                      value: formatDate(widget.gatePassModel!.outDateTime),
                    ),
                  ],
                ),
              ],
            ),

            SectionCard(
              title: 'Action Details',
              titleTextColor: AppColor.black,
              headerBackgroundColor: AppColor.grey20,
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Created By",
                      value: widget.gatePassModel!.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDate(widget.gatePassModel!.createdDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value: widget.gatePassModel!.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value: formatDate(widget.gatePassModel!.modifiedDate),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
