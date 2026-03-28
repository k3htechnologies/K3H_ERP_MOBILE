import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry_followup.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewEnquiryScreen extends StatefulWidget {
  final int enquiryId;

  const ViewEnquiryScreen({super.key, required this.enquiryId});

  @override
  State<ViewEnquiryScreen> createState() => _ViewEnquiryScreenState();
}

class _ViewEnquiryScreenState extends State<ViewEnquiryScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late EnquiryCubit _enquiryCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // TAB CONTROLLER
  late TabController _tabController;
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);

  // VARIABLE FOR FORM VALIDATION
  final GlobalKey<FormState> _statusFormKey = GlobalKey<FormState>();

  // DROPDOWN VARIABLE
  Map<String, dynamic>? _selectedStatus;
  Map<String, dynamic>? _selectedLostReason;
  // DATETIME VARIABLE
  DateTime? _nextFollowupDate;

  // TEXT CONTROLLER
  final TextEditingController _remarkC = TextEditingController();

  // STATIC DROPDOWNS
  final List<Map<String, dynamic>> _statusList = [
    {'zAttributesId': 1, 'DisplayName': 'Booking Done'},
    {'zAttributesId': 2, 'DisplayName': 'Blocked'},
    {'zAttributesId': 3, 'DisplayName': 'Cancelled'},
    {'zAttributesId': 4, 'DisplayName': 'Negotiation'},
    {'zAttributesId': 5, 'DisplayName': 'Lost'},
    {'zAttributesId': 6, 'DisplayName': 'Retention'},
    {'zAttributesId': 7, 'DisplayName': 'Re - Visit Scheduled'},
    {'zAttributesId': 8, 'DisplayName': 'Re - Visit Proposed'},
    {'zAttributesId': 9, 'DisplayName': 'Site Visit'},
    {'zAttributesId': 10, 'DisplayName': 'Unit Selection / Blocked'},
  ];

  final List<Map<String, dynamic>> _lostReasonList = [
    {'DisplayName': 'Purchased with competition'},
    {'DisplayName': 'Purchased somewhere else'},
    {'DisplayName': 'Not connected calls >7'},
    {'DisplayName': 'Low Budget'},
    {'DisplayName': 'Ready Possession'},
    {'DisplayName': 'Location'},
    {'DisplayName': 'Product Issue'},
    {'DisplayName': 'Pricing Issue'},
    {'DisplayName': 'Payment Issue'},
    {'DisplayName': 'Loan Issue'},
    {'DisplayName': 'Inventory Issue'},
    {'DisplayName': 'General Enquiry'},
    {'DisplayName': 'Wrong Number'},
    {'DisplayName': 'Dropped The Idea Of Buying'},
    {'DisplayName': 'Booked Somewhere Else'},
  ]; // VARIABLE GET FILLED WHEN TEAM MEMBER ID IS THERE

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _enquiryCubit = context.read<EnquiryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.enquiry]!;

    _enquiryCubit.clearEnquiryFollowUp();
    // FOR OVERVIEW
    _enquiryCubit.getEnquiryById(
      enquiryId: widget.enquiryId,
      projectId: getProject().projectId,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _tabIndexNotifier.value = _tabController.index;
        _onTabChange();
      }
    });
  }

  void _onTabChange() {
    final enquiryId = widget.enquiryId;
    final projectId = getProject().projectId;

    if (_tabController.index == 0) {
      /// FETCH FRESH DATA
      _enquiryCubit.getEnquiryById(enquiryId: enquiryId, projectId: projectId);
    } else if (_tabController.index == 1) {
      ///  FETCH FRESH FOLLOWUPS
      _enquiryCubit.fetchEnquiryFollowUps(
        enquiryId: enquiryId,
        projectId: projectId,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Enquiry",
        authorization: AuthorizationModel(),
      ),
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
      bottomNavigationBar: BlocBuilder<EnquiryCubit, EnquiryState>(
        builder: (context, state) {
          // 1️. SHOW ONLY ON TIMELINE TAB
          if (_tabIndexNotifier.value != 1) {
            return const SizedBox.shrink();
          }

          // 2️. IF LOADING → HIDE
          if (state.isFetchingEnquiryDetails == true) {
            return const SizedBox.shrink();
          }

          // 3️. IF NO CURRENT ENQUIRY → HIDE
          final enquiry = state.currentEnquiryDetails;
          if (enquiry == null) {
            return const SizedBox.shrink();
          }

          // 4️. CLOSED STATUS CHECK
          final closedStatuses = ['booking done', 'cancelled', 'lost'];

          if (closedStatuses.contains(enquiry.finalStage.toLowerCase()) ||
              !_routeAuthorizationModel.isAction) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: "Follow Up",
                onPressed:
                    () => _showAddUpdateEnquiryFollowUpBottomSheet(context),
              ),
            ),
          );
        },
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
    return BlocBuilder<EnquiryCubit, EnquiryState>(
      builder: (context, state) {
        if (state.isFetchingEnquiryDetails == true) {
          return loader();
        }

        if (state.currentEnquiryDetails == null) {
          return noDataWidget();
        }

        final enquiry = state.currentEnquiryDetails!;
        final bool isChannelPartner = enquiry.source == "Channel Partner";
        final bool isDirectWalking = enquiry.source == "Direct Walking";
        final bool isNRI = enquiry.nationality.toLowerCase() == 'nri';
        final bool isAdvertisement = enquiry.subSource == "Advertisement";
        final bool isEmployeeReference =
            enquiry.subSource == "Employee Reference";
        final bool isLoyalty = enquiry.subSource == "Loyalty";
        final bool isReference = enquiry.subSource == "Reference";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    enquiry.systemGeneratedCode,
                    style: AppTextStyle.ts16SB(color: AppColor.primary),
                  ),
                  statusWidget(enquiry.finalStage),
                ],
              ),

              /// LEAD INFO
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Enquiry Details"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        buildColumnTitleValue(
                          title: "Enquiry Date",
                          value:
                              enquiry.enquiryDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    enquiry.enquiryDate!,
                                  )
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Next Follow-Up Date",
                          value:
                              enquiry.nextFollowUpDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    enquiry.nextFollowUpDate!,
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
                          value: enquiry.name.isNotEmpty ? enquiry.name : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Mobile No.",
                          value:
                              enquiry.mobileNumber.isNotEmpty
                                  ? enquiry.mobileNumber
                                  : "-",
                          customValueWidget: CustomClickToContactText(
                            value: enquiry.mobileNumber,
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
                              enquiry.emailId.isNotEmpty
                                  ? enquiry.emailId
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Date of Birth",
                          value:
                              enquiry.dateOfBirth != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    enquiry.dateOfBirth!,
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
                          value: calculateAge(enquiry.dateOfBirth),
                        ),
                        buildColumnTitleValue(
                          title: "Accommodation",
                          value:
                              enquiry.accommodation.isNotEmpty
                                  ? enquiry.accommodation
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
                              enquiry.occupationType.isNotEmpty
                                  ? enquiry.occupationType
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Nationality",
                          value:
                              enquiry.nationality.isNotEmpty
                                  ? enquiry.nationality
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
                                enquiry.countryOfResidence.isNotEmpty
                                    ? enquiry.countryOfResidence
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "City Of Residence",
                            value:
                                enquiry.cityOfResidence.isNotEmpty
                                    ? enquiry.cityOfResidence
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
                              enquiry.enquiryTimeIn.isNotEmpty
                                  ? enquiry.enquiryTimeIn
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Customer Time Out",
                          value:
                              enquiry.enquiryTimeOut.isNotEmpty
                                  ? enquiry.enquiryTimeOut
                                  : "-",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// SOURCE INFO
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Source"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        buildColumnTitleValue(
                          title: "Source",
                          value:
                              enquiry.source.isNotEmpty ? enquiry.source : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Sub Source",
                          value:
                              enquiry.subSource.isNotEmpty
                                  ? enquiry.subSource
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
                            title: "CP Name",
                            value:
                                enquiry.channelPartnerName.isNotEmpty
                                    ? enquiry.channelPartnerName
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "CP Mobile No.",
                            value:
                                enquiry.channelPartnerMobileNumber.isNotEmpty
                                    ? enquiry.channelPartnerMobileNumber
                                    : "-",
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          buildColumnTitleValue(
                            title: "CP Designation",
                            value:
                                enquiry.channelPartnerDesignation.isNotEmpty
                                    ? enquiry.channelPartnerDesignation
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "CP Company Name",
                            value:
                                enquiry.channelPartnerCompany.isNotEmpty
                                    ? enquiry.channelPartnerCompany
                                    : "-",
                          ),
                        ],
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          buildColumnTitleValue(
                            title: "CP Firms Type",
                            value:
                                enquiry.channelPartnerFirmsType.isNotEmpty
                                    ? enquiry.channelPartnerFirmsType
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "CP Type",
                            value:
                                enquiry.channelPartnerType.isNotEmpty
                                    ? enquiry.channelPartnerType
                                    : "-",
                          ),
                        ],
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (enquiry.channelPartnerTeamMemberName.isNotEmpty)
                            buildColumnTitleValue(
                              title: "Team Member Name",
                              value:
                                  enquiry
                                          .channelPartnerTeamMemberName
                                          .isNotEmpty
                                      ? enquiry.channelPartnerTeamMemberName
                                      : "-",
                            ),

                          if (enquiry
                              .channelPartnerTeamMemberMobileNumber
                              .isNotEmpty)
                            buildColumnTitleValue(
                              title: "Team Member Mobile",
                              value:
                                  enquiry
                                          .channelPartnerTeamMemberMobileNumber
                                          .isNotEmpty
                                      ? enquiry
                                          .channelPartnerTeamMemberMobileNumber
                                      : "-",
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
                                enquiry.subSubSource.isNotEmpty
                                    ? enquiry.subSubSource
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
                                enquiry.employeeReferenceName.isNotEmpty
                                    ? enquiry.employeeReferenceName
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "Employee Reference Mobile No.",
                            value:
                                enquiry.employeeReferenceMobileNumber.isNotEmpty
                                    ? enquiry.employeeReferenceMobileNumber
                                    : "-",
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
                                enquiry.loyaltyExistingProjectName.isNotEmpty
                                    ? enquiry.loyaltyExistingProjectName
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "Existing Unit Number",
                            value:
                                enquiry.loyaltyExistingUnitNumber.isNotEmpty
                                    ? enquiry.loyaltyExistingUnitNumber
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
                                enquiry.loyaltyExistingUnitOwnerName.isNotEmpty
                                    ? enquiry.loyaltyExistingUnitOwnerName
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
                                enquiry.referelProjectName.isNotEmpty
                                    ? enquiry.referelProjectName
                                    : "-",
                          ),
                          buildColumnTitleValue(
                            title: "Referral Unit Number",
                            value:
                                enquiry.referelUnitNumber.isNotEmpty
                                    ? enquiry.referelUnitNumber
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
                                enquiry.referralUnitOwnerName.isNotEmpty
                                    ? enquiry.referralUnitOwnerName
                                    : "-",
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              /// ADDRESS
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Address"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Current Location",
                          value:
                              enquiry.currentLocation.isNotEmpty
                                  ? enquiry.currentLocation
                                  : "-",
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

              /// PROPERTY PREFERENCES
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Property Preferences"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Budget (In CR)",
                          value:
                              enquiry.budget.isNotEmpty ? enquiry.budget : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Possession Type",
                          value:
                              enquiry.possessionType.isNotEmpty
                                  ? enquiry.possessionType
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
                              enquiry.requirement.isNotEmpty
                                  ? enquiry.requirement
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Type",
                          value:
                              enquiry.requirementType.isNotEmpty
                                  ? enquiry.requirementType
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
                              enquiry.villageName.isNotEmpty
                                  ? enquiry.villageName
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Timeline",
                          value:
                              enquiry.timeline.isNotEmpty
                                  ? enquiry.timeline
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
                              enquiry.areaPreferred > 0
                                  ? enquiry.areaPreferred.toStringAsFixed(0)
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Desired Floor Band",
                          value:
                              enquiry.desiredFloorBand.isNotEmpty
                                  ? enquiry.desiredFloorBand
                                  : "-",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// CUSTOMER DETAILS
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Customer Details"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Customer Classification",
                          value:
                              enquiry.customerClassification.isNotEmpty
                                  ? enquiry.customerClassification
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
                              enquiry.ethnicity.isNotEmpty
                                  ? enquiry.ethnicity
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Source Of Funding",
                          value:
                              enquiry.sourceOfFunding.isNotEmpty
                                  ? enquiry.sourceOfFunding
                                  : "-",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// ENQUIRY INFORMATION
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Enquiry Information"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Stage",
                          value:
                              enquiry.finalStage.isNotEmpty
                                  ? enquiry.finalStage
                                  : "-",
                        ),
                        if (enquiry.finalStageDetail.isNotEmpty)
                          buildColumnTitleValue(
                            title: "Stage Reason",
                            value:
                                enquiry.finalStageDetail.isNotEmpty
                                    ? enquiry.finalStageDetail
                                    : "-",
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              /// SALES DETAILS
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Sales Details"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Sales Advisor",
                          value:
                              enquiry.salesAdvisor.isNotEmpty
                                  ? enquiry.salesAdvisor
                                  : "-",
                        ),
                        buildColumnTitleValue(
                          title: "Sourcing Manager",
                          value:
                              enquiry.sourcingManager.isNotEmpty
                                  ? enquiry.sourcingManager
                                  : "-",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// ENQUIRY REMARK
              _buildCard(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Enquiry Remark"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Remark",
                          value:
                              enquiry.remark.isNotEmpty ? enquiry.remark : "-",
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

              // ACTION DETAILS
              actionCardWidget(
                createdBy: enquiry.createdBy,
                createdDate: enquiry.createdDate,
                modifiedBy: enquiry.modifiedBy,
                modifiedDate: enquiry.modifiedDate,
              ),
              verticalSpacing(),
            ],
          ),
        );
      },
    );
  }

  // ===================== REMARK AND ACTIVITY TAB =====================
  Widget buildRemarkActivityTimeline() {
    return BlocBuilder<EnquiryCubit, EnquiryState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return loader();
        }

        if (state.enquiryFollowUpList.isEmpty) {
          return noDataWidget();
        }

        final items = state.enquiryFollowUpList;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.currentEnquiryDetails!.systemGeneratedCode,
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
              verticalSpacing(),

              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===================== CUSTOM TIMELINE =====================
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        final isExtraDot = index == items.length;
                        final item = !isExtraDot ? items[index] : items[0];

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                children: [
                                  // Dot
                                  Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          isExtraDot
                                              ? AppColor.lightBlue
                                              : AppColor.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  // Connector
                                  if (!isExtraDot)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        color: AppColor.primary,
                                      ),
                                    ),
                                ],
                              ),
                              horizontalSpacing(),
                              // Timeline Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child:
                                      isExtraDot
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Visibility(
                                                visible:
                                                    ![
                                                      'booking done',
                                                      'cancelled',
                                                      'lost',
                                                    ].contains(
                                                      item.status.toLowerCase(),
                                                    ),
                                                child: Text(
                                                  dateFormatterDDMMYYYYDAY(
                                                    item.nextFollowUpDate!,
                                                    isDayNotRequired: true,
                                                  ),
                                                  style: AppTextStyle.ts12M(
                                                    color: AppColor.grey,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "Next Follow-up",
                                                style: AppTextStyle.ts12M(
                                                  color: AppColor.grey,
                                                ),
                                              ),
                                            ],
                                          )
                                          : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.createdBy,
                                                          style:
                                                              AppTextStyle.ts14SB(),
                                                        ),
                                                        verticalSpacing(),

                                                        RichText(
                                                          text: TextSpan(
                                                            text: dateFormatterDDMMYYYYDAY(
                                                              item.createdDate!,
                                                            ),
                                                            style:
                                                                AppTextStyle.ts12M(
                                                                  color:
                                                                      AppColor
                                                                          .black,
                                                                ),
                                                            children: [
                                                              const TextSpan(
                                                                text: "  ",
                                                              ),
                                                              TextSpan(
                                                                text: dateFormatterHhMmAm(
                                                                  item.createdDate!,
                                                                ),
                                                                style: AppTextStyle.ts12M(
                                                                  color:
                                                                      AppColor
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (index == 0 &&
                                                      ![
                                                        'booking done',
                                                        'cancelled',
                                                        'lost',
                                                      ].contains(
                                                        item.status
                                                            .toLowerCase(),
                                                      ))
                                                    if (_routeAuthorizationModel
                                                        .isAction)
                                                      Row(
                                                        spacing: 5,
                                                        children: [
                                                          CustomIconButton.edit(
                                                            onPressed: () {
                                                              _showAddUpdateEnquiryFollowUpBottomSheet(
                                                                context,
                                                                followUpModel:
                                                                    item,
                                                                index: index,
                                                              );
                                                            },
                                                          ),
                                                          CustomIconButton.delete(
                                                            onPressed: () {
                                                              _showPopupToDeleteFollowUp(
                                                                index: index,
                                                                followUpModel:
                                                                    item,
                                                                enquiryId:
                                                                    widget
                                                                        .enquiryId,
                                                                context:
                                                                    context,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                ],
                                              ),
                                              verticalSpacing(),
                                              statusWidget(item.status),
                                              verticalSpacing(),

                                              Text(
                                                item.remark,
                                                style: AppTextStyle.ts14R(),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── SHARED CARD WRAPPER ───────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(title, style: AppTextStyle.ts14SB(color: AppColor.black)),
    );
  }

  // ── STATUS HELPER WIDGETS ───────────────────────────────────────────
  Widget statusWidget(String status) {
    final trimmed = status.trim();

    if (trimmed.isEmpty) {
      return statusChip("-", AppColor.lightGreyBackground, AppColor.black);
    }

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'booking done':
        return statusChip(status, AppColor.green20, AppColor.green);

      case 'blocked':
        return statusChip(status, AppColor.purple20, AppColor.purple);

      case 'cancelled':
        return statusChip(status, AppColor.black10, AppColor.darkGrey);

      case 'negotiation':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'lost':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'retention':
        return statusChip(status, AppColor.lightBlue2, AppColor.info);

      case 're - visit scheduled':
        return statusChip(status, AppColor.lightGreenBg, AppColor.darkGreen);

      case 're - visit proposed':
        return statusChip(status, AppColor.lightOrangenBg, AppColor.orange);

      case 'site visit':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      case 'unit selection / blocked':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }

  // ADD UPDATE ENQUIRY FOLLOW UP BOTTOM SHEET
  Future<void> _showAddUpdateEnquiryFollowUpBottomSheet(
    BuildContext context, {
    EnquiryFollowUpModel? followUpModel,
    int? index,
  }) async {
    // ===================== PREFILL FOR EDIT =====================
    if (followUpModel != null) {
      _selectedStatus = _statusList.firstWhere(
        (e) => e['DisplayName'] == followUpModel.status,
        orElse: () => {},
      );

      _selectedLostReason =
          (followUpModel.lostReason.isEmpty)
              ? _lostReasonList.firstWhere(
                (e) => e['DisplayName'] == followUpModel.lostReason,
                orElse: () => {},
              )
              : null;

      _remarkC.text = followUpModel.remark;
      _nextFollowupDate = followUpModel.nextFollowUpDate;
    }

    // ===================== STATUS IDs THAT REQUIRE NEXT FOLLOWUP DATE =====================
    final followUpStatusIds = [
      2, // Blocked
      4, // Negotiation
      6, // Retention
      7, // Re-Visit Scheduled
      8, // Re-Visit Proposed
      9, // Site Visit
      10, // Unit Selection / Blocked
    ];

    await DialogHelper.showCustomBottomSheet(
      context,
      index != null ? "Update Follow Up" : "Add Follow Up",
      StatefulBuilder(
        builder: (context, innerBottomsheetState) {
          final statusId = _selectedStatus?['zAttributesId'];
          final statusName = _selectedStatus?['DisplayName'];

          // ===================== CONDITIONAL WIDGETS =====================
          Widget followUpDateWidget() =>
              ((statusId != null && followUpStatusIds.contains(statusId) ||
                      statusId == null))
                  ? CustomDatePicker(
                    title: "Next Followup Date",
                    initialDate: _nextFollowupDate,
                    isRequired: true,
                    startDate: DateTime.now(),
                    setValue:
                        (date) => innerBottomsheetState(
                          () => _nextFollowupDate = date,
                        ),
                    validator:
                        (value) =>
                            value == null
                                ? "Next Followup Date is required"
                                : null,
                  )
                  : const SizedBox.shrink();

          Widget lostReasonWidget() =>
              (statusName == "Lost")
                  ? CustomDropDownWidget(
                    title: "Lost Reason",
                    isRequired: true,
                    dataList: _lostReasonList,
                    initialValue: _selectedLostReason,
                    onSelected:
                        (val) => innerBottomsheetState(
                          () => _selectedLostReason = val,
                        ),
                    validator:
                        (val) => val == null ? "Lost reason is required" : null,
                  )
                  : const SizedBox.shrink();

          return Form(
            key: _statusFormKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDropDownWidget(
                    title: "Status",
                    isRequired: true,
                    hintText: "Select Status",
                    dataList: _statusList,
                    initialValue: _selectedStatus,
                    onSelected:
                        (val) => innerBottomsheetState(() {
                          _selectedStatus = val;
                          _selectedLostReason = null;
                          _nextFollowupDate = null;
                        }),
                    validator:
                        (val) => val == null ? "Status is required" : null,
                  ),

                  followUpDateWidget(),
                  lostReasonWidget(),
                  CustomTextField(
                    title: 'Remark',
                    hint: "Enter remark",
                    isRequired: true,

                    textController: _remarkC,
                    maxLines: 3,
                    minLines: 3,
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? "Remark is required"
                                : null,
                  ),
                  CustomButton(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    text: index != null ? "Update" : "Save",
                    onPressed: () {
                      if (!_statusFormKey.currentState!.validate()) return;

                      _submitForm(followUpModel: followUpModel, index: index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    _clearStatusSheet();
  }

  void _clearStatusSheet() {
    _selectedStatus = null;
    _selectedLostReason = null;
    _nextFollowupDate = null;
    _remarkC.clear();
  }

  void _submitForm({EnquiryFollowUpModel? followUpModel, int? index}) {
    if (!_statusFormKey.currentState!.validate()) return;

    final statusName = _selectedStatus?['DisplayName'];
    final lostReasonName = _selectedLostReason?['DisplayName'];

    final payload = {
      "EnquiryFollowUpId":
          (index != null) ? followUpModel!.enquiryFollowUpId : 0,

      if (index != null) "Uniquekey": followUpModel!.uniquekey,

      "EnquiryId": widget.enquiryId,
      "ProjectId": getProject().projectId,

      "Status": statusName,
      "LostReason": statusName == "Lost" ? lostReasonName : null,
      "NextFollowUpDate": _nextFollowupDate?.toIso8601String(),
      "Remark": _remarkC.text,
    };

    _enquiryCubit.addUpdateEnquiryFollowUp(
      context: context,
      body: payload,
      index: index,
    );
  }

  void _showPopupToDeleteFollowUp({
    required int index,
    required EnquiryFollowUpModel followUpModel,
    required int enquiryId,

    required BuildContext context,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this Follow-Up?',
      'Deleting this Follow-Up will permanently remove its contents.',
    );

    if (result && context.mounted) {
      _enquiryCubit.deleteFollowUp(
        index: index,
        followUpModel: followUpModel,
        enquiryId: enquiryId,
        context: context,
      );
    }
  }
}
