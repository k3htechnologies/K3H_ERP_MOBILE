import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry_followup.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewEnquiryScreen extends StatefulWidget {
  final EnquiryModel enquiryModel;
  final int index;

  const ViewEnquiryScreen({
    super.key,
    required this.enquiryModel,
    this.index = 0,
  });

  @override
  State<ViewEnquiryScreen> createState() => _ViewEnquiryScreenState();
}

class _ViewEnquiryScreenState extends State<ViewEnquiryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late EnquiryCubit _enquiryCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _enquiryCubit = context.read<EnquiryCubit>();

    // Fetch follow-up data when screen loads
    _enquiryCubit.fetchEnquiryFollowUps(
      enquiryId: widget.enquiryModel.enquiryId,
      projectId: getProject().projectId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Enquiry")),
      body: SafeArea(
        child: Column(
          children: [
            _buildEnquiryTabBar(),
            verticalSpacing(),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [buildOverviewTab(), buildRemarkActivityTimeline()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== TAB BAR =====================
  Widget _buildEnquiryTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [Tab(text: "Overview"), Tab(text: "Remark & Activity")],
          ),
        ),
      ),
    );
  }

  // ===================== OVERVIEW TAB =====================
  Widget buildOverviewTab() {
    final enquiry = widget.enquiryModel;
    final bool isChannelPartner = enquiry.source == "Channel Partner";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Enquiry Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      enquiry.systemGeneratedCode,
                      style: AppTextStyle.ts16SB(color: AppColor.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Enquiry",
                        style: AppTextStyle.ts12SB(color: AppColor.primary),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionTitle("Basic Information"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Full Name",
                          value: enquiry.name,
                        ),
                        buildColumnTitleValue(
                          title: "Contact No.",
                          value: enquiry.mobileNumber,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "E-Mail ID",
                          value: enquiry.emailId,
                        ),
                        buildColumnTitleValue(
                          title: "Location",
                          value: enquiry.villageName,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Date Of Birth",
                          value:
                              enquiry.dateOfBirth != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    enquiry.dateOfBirth!,
                                  )
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Age",
                          value: enquiry.age.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Current Accommodation",
                          value: enquiry.accommodation,
                        ),
                        buildColumnTitleValue(
                          title: "Occupation Type",
                          value: enquiry.occupationType,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Nationality",
                          value: enquiry.nationality,
                        ),
                        if (enquiry.nationality == "NRI")
                          buildColumnTitleValue(
                            title: "Country Of Residence",
                            value: enquiry.countryOfResidence,
                          ),
                      ],
                    ),
                    if (enquiry.nationality == "NRI")
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "City Of Residence",
                            value: enquiry.cityOfResidence,
                          ),
                        ],
                      ),

                    // Source Information
                    verticalSpacing(),
                    _buildSectionTitle("Source Information"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Source",
                          value: enquiry.source,
                        ),
                        buildColumnTitleValue(
                          title: "Sub-Source",
                          value: enquiry.subSource,
                        ),
                      ],
                    ),
                    if (enquiry.subSource == "Advertisement")
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Sub-Sub Source",
                            value: enquiry.subSubSource,
                          ),
                        ],
                      ),

                    // Employee Reference
                    if (enquiry.subSource == "Employee Reference") ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Employee Name",
                            value: enquiry.employeeReferenceName,
                          ),
                          buildColumnTitleValue(
                            title: "Employee Mobile",
                            value: enquiry.employeeReferenceMobileNumber,
                          ),
                        ],
                      ),
                    ],

                    // Loyalty
                    if (enquiry.subSource == "Loyalty") ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Existing Project",
                            value: enquiry.loyaltyExistingProjectName,
                          ),
                          buildColumnTitleValue(
                            title: "Existing Unit",
                            value: enquiry.loyaltyExistingUnitNumber,
                          ),
                        ],
                      ),
                    ],

                    // Referral
                    if (enquiry.subSource == "Reference") ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Referral Name",
                            value: enquiry.referelName,
                          ),
                          buildColumnTitleValue(
                            title: "Referral Mobile",
                            value: enquiry.referelMobileNumber,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Referral Project",
                            value: enquiry.referelProjectName,
                          ),
                          buildColumnTitleValue(
                            title: "Referral Unit",
                            value: enquiry.referelUnitNumber,
                          ),
                        ],
                      ),
                    ],

                    // Property Preferences
                    verticalSpacing(),
                    _buildSectionTitle("Property Preferences"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Possession Type",
                          value: enquiry.possessionType,
                        ),
                        buildColumnTitleValue(
                          title: "Requirement",
                          value: enquiry.requirement,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Area Preferred (SqFt)",
                          value: enquiry.areaPreferred.toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Timeline",
                          value: enquiry.timeline,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Desired Floor Band",
                          value: enquiry.desiredFloorBand,
                        ),
                        buildColumnTitleValue(
                          title: "Budget (Cr)",
                          value: enquiry.budget,
                        ),
                      ],
                    ),

                    // Customer Details
                    verticalSpacing(),
                    _buildSectionTitle("Customer Details"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Source Of Funding",
                          value: enquiry.sourceOfFunding,
                        ),
                        buildColumnTitleValue(
                          title: "Ethnicity",
                          value: enquiry.ethnicity,
                        ),
                      ],
                    ),

                    // Enquiry Information
                    verticalSpacing(),
                    _buildSectionTitle("Enquiry Information"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Stage",
                          value: enquiry.finalStage,
                        ),
                        buildColumnTitleValue(
                          title: "Enquiry Date",
                          value:
                              enquiry.enquiryDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    enquiry.enquiryDate!,
                                  )
                                  : "-",
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Next Follow-Up",
                          value:
                              enquiry.nextFollowUpDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    enquiry.nextFollowUpDate!,
                                  )
                                  : "-",
                        ),
                      ],
                    ),

                    // Sales Details
                    verticalSpacing(),
                    _buildSectionTitle("Sales Details"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Sales Advisor",
                          value: enquiry.salesAdvisor,
                        ),
                        buildColumnTitleValue(
                          title: "Sourcing Manager",
                          value: enquiry.sourcingManager,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Time In",
                          value: enquiry.enquiryTimeIn,
                        ),
                        buildColumnTitleValue(
                          title: "Time Out",
                          value: enquiry.enquiryTimeOut,
                        ),
                      ],
                    ),

                    // Remarks
                    if (enquiry.remark.isNotEmpty) ...[
                      verticalSpacing(),
                      _buildSectionTitle("Remarks"),
                      buildColumnTitleValue(
                        title: "Remark",
                        value: enquiry.remark,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Channel Partner Card (shown only if source is Channel Partner)
          if (isChannelPartner &&
              enquiry.channelPartnerMobileNumber.isNotEmpty) ...[
            verticalSpacing(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.lightBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Channel Partner Details",
                    style: AppTextStyle.ts16SB(color: AppColor.primary),
                  ),
                  verticalSpacing(),
                  Column(
                    spacing: 10,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Channel Partner Mobile",
                            value: enquiry.channelPartnerMobileNumber,
                          ),
                          buildColumnTitleValue(
                            title: "Team Member Name",
                            value: enquiry.channelPartnerName,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Team Member Mobile",
                            value: enquiry.channelPartnerTeamMemberMobileNumber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(title, style: AppTextStyle.ts14SB(color: AppColor.primary)),
    );
  }

  Widget buildRemarkActivityTimeline() {
    return BlocBuilder<EnquiryCubit, EnquiryState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.enquiryFollowUpList.length,
          itemBuilder: (context, index) {
            final followUp = state.enquiryFollowUpList[index];
            final isLast = index == state.enquiryFollowUpList.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left timeline line + dot
                Column(
                  children: [
                    // Dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Vertical line connecting to next dot
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 100, // adjust depending on card height
                        color: AppColor.primary,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Right content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${formatDateTimeAsDDMMMYYYY(followUp.createdDate!)} • ${formatTime(followUp.createdDate!)}",
                          style: AppTextStyle.ts12M(color: AppColor.grey),
                        ),
                        verticalSpacing(height: 4),
                        Text(followUp.remark, style: AppTextStyle.ts14R()),
                        verticalSpacing(height: 8),
                        if (followUp.nextFollowUpDate != null)
                          Text(
                            "Next Follow-up: ${formatDateTimeAsDDMMMYYYY(followUp.nextFollowUpDate!)}",
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
