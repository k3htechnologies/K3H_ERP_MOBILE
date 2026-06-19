import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/channel_partner_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/pages/achievement_drill_down_report_screen.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/widget/common_achivement_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AchievementDrillDownReportForChannelPartnerScreen
    extends StatelessWidget {
  final ChannelPartnerSourcingModel channelPartnerModel;
  final String? employeeName;
  final String tabName;
  final String columnName;
  final String projectName;

  const AchievementDrillDownReportForChannelPartnerScreen({
    super.key,
    this.employeeName,
    required this.channelPartnerModel,
    required this.projectName,
    required this.tabName,
    required this.columnName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Channel Partner",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (projectName.isNotEmpty) ...[
              showSiteSelectedWidget(projectName: projectName),
              verticalSpacing(),
            ],
            if (employeeName != null && employeeName!.isNotEmpty) ...[
              Text(employeeName!, style: AppTextStyle.ts14M()),

              verticalSpacing(),
            ],
            RichText(
              text: TextSpan(
                style: AppTextStyle.ts14R(),
                children: [
                  TextSpan(
                    text: "Tab: ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),
                  TextSpan(text: tabName, style: AppTextStyle.ts14M()),
                  TextSpan(
                    text: " | ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),
                  TextSpan(
                    text: "Column: ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),
                  TextSpan(
                    text: formattedColumnName(columnName),
                    style: AppTextStyle.ts14M(),
                  ),
                ],
              ),
            ),

            verticalSpacing(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: [
                    buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          buildSectionTitle("Channel Partner Details"),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Name",
                                value: channelPartnerModel.name,
                              ),
                              buildColumnTitleValue(
                                title: "CP Code",
                                value: channelPartnerModel.systemGeneratedCode,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Firm Type",
                                value: channelPartnerModel.firmsType,
                              ),
                              buildColumnTitleValue(
                                title: "Type",
                                value: channelPartnerModel.type,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Designation",
                                value: channelPartnerModel.designation,
                              ),
                              buildColumnTitleValue(
                                title: "RERA Number",
                                value: channelPartnerModel.reraNumber,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "GST Number",
                                value: channelPartnerModel.gstNumber,
                              ),
                              buildColumnTitleValue(
                                title: "Speciality",
                                value: channelPartnerModel.speciality,
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "IBM / OBM",
                                value: channelPartnerModel.ibmObm,
                              ),
                            ],
                          ),

                          buildRowWrapper(
                            child: buildColumnTitleValue(
                              title: "Office Address",
                              value: channelPartnerModel.officeAddress,
                            ),
                          ),

                          buildRowWrapper(
                            child: buildColumnTitleValue(
                              title: "Sourcing Remark",
                              value: channelPartnerModel.sourcingRemark,
                            ),
                          ),

                          buildRowWrapper(
                            child: buildColumnTitleValue(
                              title: "Support",
                              value: channelPartnerModel.support,
                            ),
                          ),
                        ],
                      ),
                    ),

                    actionCardWidget(
                      createdBy: channelPartnerModel.createdBy,
                      createdDate: channelPartnerModel.createdDate,
                      modifiedBy: channelPartnerModel.modifiedBy,
                      modifiedDate: channelPartnerModel.modifiedDate,
                    ),

                    verticalSpacing(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
