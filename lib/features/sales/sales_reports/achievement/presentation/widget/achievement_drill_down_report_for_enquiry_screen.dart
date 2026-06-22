import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/presentation/widget/common_achivement_widgets.dart';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AchievementDrillDownReportForEnquiryScreen extends StatelessWidget {
  final String? employeeName;
  final String tabName;
  final String columnName;
  final String projectName;
  final EnquiryModel enquiryModel;
  const AchievementDrillDownReportForEnquiryScreen({
    super.key,
    this.employeeName,
    required this.projectName,
    required this.tabName,
    required this.columnName,
    required this.enquiryModel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isChannelPartner = enquiryModel.source == "Channel Partner";
    final bool isDirectWalking = enquiryModel.source == "Direct Walkin";
    final bool isNRI = enquiryModel.nationality.toLowerCase() == 'nri';
    final bool isAdvertisement = enquiryModel.subSource == "Advertisement";
    final bool isEmployeeReference =
        enquiryModel.subSource == "Employee Reference";
    final bool isLoyalty = enquiryModel.subSource == "Loyalty";
    final bool isReference = enquiryModel.subSource == "Reference";
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Enquiry",
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
                    text: toTitleCase(columnName),
                    style: AppTextStyle.ts14M(),
                  ),
                ],
              ),
            ),
            verticalSpacing(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    enquiryModel.systemGeneratedCode,
                    style: AppTextStyle.ts16SB(color: AppColor.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (enquiryModel.finalStage.isNotEmpty)
                  enquiryStatusWidget(enquiryModel.finalStage),
              ],
            ),
            verticalSpacing(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    /// LEAD INFO
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Enquiry Details"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              buildColumnTitleValue(
                                title: "Enquiry Date",
                                value:
                                    enquiryModel.enquiryDate != null
                                        ? formatDateTimeAsDDMMMYYYY(
                                          enquiryModel.enquiryDate!,
                                        )
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Next Follow-Up Date",
                                value:
                                    enquiryModel.nextFollowUpDate != null
                                        ? formatDateTimeAsDDMMMYYYY(
                                          enquiryModel.nextFollowUpDate!,
                                        )
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              buildColumnTitleValue(
                                title: "Full Name",
                                value:
                                    enquiryModel.name.isNotEmpty
                                        ? enquiryModel.name
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Mobile No.",
                                value:
                                    enquiryModel.mobileNumber.isNotEmpty
                                        ? enquiryModel.mobileNumber
                                        : "-",
                                customValueWidget: CustomClickToContactText(
                                  countryCode:
                                      enquiryModel.mobileNumberCountryCode,
                                  value: enquiryModel.mobileNumber,
                                  type: ContactType.phone,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              buildColumnTitleValue(
                                title: "E-Mail ID",
                                value:
                                    enquiryModel.emailId.isNotEmpty
                                        ? enquiryModel.emailId
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Date of Birth",
                                value:
                                    enquiryModel.dateOfBirth != null
                                        ? formatDateTimeAsDDMMMYYYY(
                                          enquiryModel.dateOfBirth!,
                                        )
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              buildColumnTitleValue(
                                title: "Age",
                                value: calculateAge(enquiryModel.dateOfBirth),
                              ),
                              buildColumnTitleValue(
                                title: "Accommodation",
                                value:
                                    enquiryModel.accommodation.isNotEmpty
                                        ? enquiryModel.accommodation
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Occupation Type",
                                value:
                                    enquiryModel.occupationType.isNotEmpty
                                        ? enquiryModel.occupationType
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Nationality",
                                value:
                                    enquiryModel.nationality.isNotEmpty
                                        ? enquiryModel.nationality
                                        : "-",
                              ),
                            ],
                          ),
                          if (isNRI)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildColumnTitleValue(
                                  title: "Country Of Residence",
                                  value:
                                      enquiryModel.countryOfResidence.isNotEmpty
                                          ? enquiryModel.countryOfResidence
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "City Of Residence",
                                  value:
                                      enquiryModel.cityOfResidence.isNotEmpty
                                          ? enquiryModel.cityOfResidence
                                          : "-",
                                ),
                              ],
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Customer Time In",
                                value:
                                    enquiryModel.enquiryTimeIn.isNotEmpty
                                        ? enquiryModel.enquiryTimeIn
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Customer Time Out",
                                value:
                                    enquiryModel.enquiryTimeOut.isNotEmpty
                                        ? enquiryModel.enquiryTimeOut
                                        : "-",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// SOURCE INFO
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Source"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              buildColumnTitleValue(
                                title: "Source",
                                value:
                                    enquiryModel.source.isNotEmpty
                                        ? enquiryModel.source
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Sub Source",
                                value:
                                    enquiryModel.subSource.isNotEmpty
                                        ? enquiryModel.subSource
                                        : "-",
                              ),
                            ],
                          ),

                          // CHANNEL PARTNER
                          if (isChannelPartner) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildColumnTitleValue(
                                  title: "CP Code",
                                  value:
                                      enquiryModel.channelPartnerCode.isNotEmpty
                                          ? enquiryModel.channelPartnerCode
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "CP Name",
                                  value:
                                      enquiryModel.channelPartnerName.isNotEmpty
                                          ? enquiryModel.channelPartnerName
                                          : "-",
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildColumnTitleValue(
                                  title: "CP Mobile No.",
                                  value:
                                      enquiryModel
                                              .channelPartnerMobileNumber
                                              .isNotEmpty
                                          ? enquiryModel
                                              .channelPartnerMobileNumber
                                          : "-",
                                  customValueWidget: CustomClickToContactText(
                                    countryCode:
                                        enquiryModel
                                            .channelPartnerMobileNumberCountryCode,
                                    value:
                                        enquiryModel.channelPartnerMobileNumber,
                                    type: ContactType.phone,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "CP Designation",
                                  value:
                                      enquiryModel
                                              .channelPartnerDesignation
                                              .isNotEmpty
                                          ? enquiryModel
                                              .channelPartnerDesignation
                                          : "-",
                                ),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                buildColumnTitleValue(
                                  title: "CP Company Name",
                                  value:
                                      enquiryModel
                                              .channelPartnerCompany
                                              .isNotEmpty
                                          ? enquiryModel.channelPartnerCompany
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "CP Firms Type",
                                  value:
                                      enquiryModel
                                              .channelPartnerFirmsType
                                              .isNotEmpty
                                          ? enquiryModel.channelPartnerFirmsType
                                          : "-",
                                ),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "CP Type",
                                  value:
                                      enquiryModel.channelPartnerType.isNotEmpty
                                          ? enquiryModel.channelPartnerType
                                          : "-",
                                ),

                                if (enquiryModel
                                    .channelPartnerTeamMemberName
                                    .isNotEmpty) ...[
                                  buildColumnTitleValue(
                                    title: "CP Team Member Name",
                                    value:
                                        enquiryModel
                                                .channelPartnerTeamMemberName
                                                .isNotEmpty
                                            ? enquiryModel
                                                .channelPartnerTeamMemberName
                                            : "-",
                                  ),
                                ] else ...[
                                  Spacer(),
                                ],
                              ],
                            ),
                            if (enquiryModel
                                .channelPartnerTeamMemberMobileNumber
                                .isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "CP Team Member Mobile No.",
                                    value:
                                        enquiryModel
                                                .channelPartnerTeamMemberMobileNumber
                                                .isNotEmpty
                                            ? enquiryModel
                                                .channelPartnerTeamMemberMobileNumber
                                            : "-",
                                    customValueWidget: CustomClickToContactText(
                                      countryCode:
                                          enquiryModel
                                              .channelPartnerTeamMemberMobileNumberCountryCode,
                                      value:
                                          enquiryModel
                                              .channelPartnerTeamMemberMobileNumber,
                                      type: ContactType.phone,
                                    ),
                                  ),
                                  buildColumnTitleValue(
                                    title: "CP Team Member E-Mail ID",
                                    value:
                                        enquiryModel
                                                .channelPartnerTeamMemberEmailId
                                                .isNotEmpty
                                            ? enquiryModel
                                                .channelPartnerTeamMemberEmailId
                                            : "-",
                                    customValueWidget: CustomClickToContactText(
                                      value:
                                          enquiryModel
                                              .channelPartnerTeamMemberEmailId,
                                      type: ContactType.email,
                                    ),
                                  ),
                                ],
                              ),
                          ],

                          // ADVERTISEMENT
                          if (isDirectWalking && isAdvertisement)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Sub Sub Source",
                                  value:
                                      enquiryModel.subSubSource.isNotEmpty
                                          ? enquiryModel.subSubSource
                                          : "-",
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),

                          // EMPLOYEE REFERENCE
                          if (isDirectWalking && isEmployeeReference)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Employee Reference Name",
                                  value:
                                      enquiryModel
                                              .employeeReferenceName
                                              .isNotEmpty
                                          ? enquiryModel.employeeReferenceName
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "Employee Reference Mobile No.",
                                  value:
                                      enquiryModel
                                              .employeeReferenceMobileNumber
                                              .isNotEmpty
                                          ? enquiryModel
                                              .employeeReferenceMobileNumber
                                          : "-",
                                  customValueWidget: CustomClickToContactText(
                                    countryCode: "+91",
                                    value:
                                        enquiryModel
                                            .employeeReferenceMobileNumber,
                                    type: ContactType.phone,
                                  ),
                                ),
                              ],
                            ),

                          // LOYALTY
                          if (isDirectWalking && isLoyalty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Existing Project Name",
                                  value:
                                      enquiryModel
                                              .loyaltyExistingProjectName
                                              .isNotEmpty
                                          ? enquiryModel
                                              .loyaltyExistingProjectName
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "Existing Unit Number",
                                  value:
                                      enquiryModel
                                              .loyaltyExistingUnitNumber
                                              .isNotEmpty
                                          ? enquiryModel
                                              .loyaltyExistingUnitNumber
                                          : "-",
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Unit Owner",
                                  value:
                                      enquiryModel
                                              .loyaltyExistingUnitOwnerName
                                              .isNotEmpty
                                          ? enquiryModel
                                              .loyaltyExistingUnitOwnerName
                                          : "-",
                                ),
                              ],
                            ),
                          ],

                          // REFERENCE
                          if (isDirectWalking && isReference) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Referral Project Name",
                                  value:
                                      enquiryModel
                                              .referralProjectName
                                              .isNotEmpty
                                          ? enquiryModel.referralProjectName
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "Referral Unit Number",
                                  value:
                                      enquiryModel.referralUnitNumber.isNotEmpty
                                          ? enquiryModel.referralUnitNumber
                                          : "-",
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Unit Owner",
                                  value:
                                      enquiryModel
                                              .referralUnitOwnerName
                                              .isNotEmpty
                                          ? enquiryModel.referralUnitOwnerName
                                          : "-",
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    /// ADDRESS
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Address"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Current Location",
                                value:
                                    enquiryModel.currentLocation.isNotEmpty
                                        ? enquiryModel.currentLocation
                                        : "-",
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// PROPERTY PREFERENCES
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Property Preferences"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Budget (In CR)",
                                value:
                                    enquiryModel.budget.isNotEmpty
                                        ? enquiryModel.budget
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Possession Type",
                                value:
                                    enquiryModel.possessionType.isNotEmpty
                                        ? enquiryModel.possessionType
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Requirement",
                                value:
                                    enquiryModel.requirement.isNotEmpty
                                        ? enquiryModel.requirement
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Type",
                                value:
                                    enquiryModel.requirementType.isNotEmpty
                                        ? enquiryModel.requirementType
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Location",
                                value:
                                    enquiryModel.villageName.isNotEmpty
                                        ? enquiryModel.villageName
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Timeline of Purchase",
                                value:
                                    enquiryModel.timeline.isNotEmpty
                                        ? enquiryModel.timeline
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Area Preferred (SqFt)",
                                value:
                                    enquiryModel.areaPreferred > 0
                                        ? enquiryModel.areaPreferred
                                            .toStringAsFixed(0)
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Desired Floor Band",
                                value:
                                    enquiryModel.desiredFloorBand.isNotEmpty
                                        ? enquiryModel.desiredFloorBand
                                        : "-",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// CUSTOMER DETAILS
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Customer Details"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Customer Classification",
                                value:
                                    enquiryModel
                                            .customerClassification
                                            .isNotEmpty
                                        ? enquiryModel.customerClassification
                                        : "-",
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Ethnicity",
                                value:
                                    enquiryModel.ethnicity.isNotEmpty
                                        ? enquiryModel.ethnicity
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Source Of Funding",
                                value:
                                    enquiryModel.sourceOfFunding.isNotEmpty
                                        ? enquiryModel.sourceOfFunding
                                        : "-",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// ENQUIRY INFORMATION
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Enquiry Information"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Stage",
                                value:
                                    enquiryModel.finalStage.isNotEmpty
                                        ? enquiryModel.finalStage
                                        : "-",
                              ),
                              if (enquiryModel.finalStageDetail.isNotEmpty)
                                buildColumnTitleValue(
                                  title: "Stage Reason",
                                  value:
                                      enquiryModel.finalStageDetail.isNotEmpty
                                          ? enquiryModel.finalStageDetail
                                          : "-",
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// SALES DETAILS
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Sales Details"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Sales Advisor",
                                value:
                                    enquiryModel.salesAdvisor.isNotEmpty
                                        ? enquiryModel.salesAdvisor
                                        : "-",
                              ),
                              buildColumnTitleValue(
                                title: "Sourcing Manager",
                                value:
                                    enquiryModel.sourcingManager.isNotEmpty
                                        ? enquiryModel.sourcingManager
                                        : "-",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// ENQUIRY REMARK
                    buildCard(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Enquiry Remark"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Remark",
                                value:
                                    enquiryModel.remark.isNotEmpty
                                        ? enquiryModel.remark
                                        : "-",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ACTION DETAILS
                    actionCardWidget(
                      createdBy: enquiryModel.createdBy,
                      createdDate: enquiryModel.createdDate,
                      modifiedBy: enquiryModel.modifiedBy,
                      modifiedDate: enquiryModel.modifiedDate,
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
