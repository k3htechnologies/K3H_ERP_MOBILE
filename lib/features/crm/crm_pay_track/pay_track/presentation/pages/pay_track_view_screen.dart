import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/presentation/pages/call_logs.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/pages/files.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/pages/flat_handover_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/pages/flat_handover_checklist.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/pages/loan_details_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/payment_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_management_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/pages/snag_checklist.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_enums.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayTrackViewScreen extends StatefulWidget {
  final String applicantName;
  final int projectId;
  final int bookingId;
  final int enquiryId;
  final String bookingApprovalStatus;
  final String approvalStatus;
  const PayTrackViewScreen({
    super.key,
    required this.applicantName,
    required this.projectId,
    required this.bookingId,
    required this.enquiryId,
    required this.bookingApprovalStatus,
    required this.approvalStatus,
  });

  @override
  State<PayTrackViewScreen> createState() => _PayTrackViewScreenState();
}

class _PayTrackViewScreenState extends State<PayTrackViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;
  late PayTrackCubit _payTrackCubit;
  late ValueNotifier<bool> isExpanded;
  late AuthorizationModel _bookingPayTrackRouteAuthorizationModel,
      _bankLoansRouteAuthorizationModel,
      _accountRouteAuthorizationModel,
      _modifiedRequestsAuthorizationModel,
      _snagChecklistAuthorizationModel,
      _flatHandoverChecklistAuthorizationModel,
      _flatHandoverAuthoriationModel,
      _filesAuthorizationModel,
      _callLogsAuthorizationModel;

  late List<PayTrackTab> _tabs;

  @override
  void initState() {
    super.initState();
    _initAuth();
    _tabs = [
      if (_bookingPayTrackRouteAuthorizationModel.isView)
        PayTrackTab.bookingPayTrack,
      if (_bankLoansRouteAuthorizationModel.isView) PayTrackTab.bankLoan,

      if (_accountRouteAuthorizationModel.isView) PayTrackTab.paymentLedger,
      if (_modifiedRequestsAuthorizationModel.isView)
        PayTrackTab.modificationRequest,
      if (_snagChecklistAuthorizationModel.isView) PayTrackTab.snagChecklist,
      if (_flatHandoverChecklistAuthorizationModel.isView)
        PayTrackTab.flatHandoverChecklist,
      if (_flatHandoverAuthoriationModel.isView) PayTrackTab.flatHandover,
      if (_filesAuthorizationModel.isView) PayTrackTab.files,
      if (_callLogsAuthorizationModel.isView) PayTrackTab.payTrackCallLog,
    ];

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _payTrackCubit = context.read<PayTrackCubit>();
    isExpanded = ValueNotifier(false);
    initOverview();
  }

  void _initAuth() {
    _bookingPayTrackRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.bookingPayTrack] ??
        AuthorizationModel();
    _bankLoansRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.bankLoans] ??
        AuthorizationModel();
    _accountRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.paymentLedger] ??
        AuthorizationModel();
    _modifiedRequestsAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.modificationRequest] ??
        AuthorizationModel();
    _snagChecklistAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.snagChecklist] ??
        AuthorizationModel();
    _flatHandoverChecklistAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.flatHandoverChecklist] ??
        AuthorizationModel();
    _flatHandoverAuthoriationModel =
        Authorization.routeAuthorizationMap[AppRoutes.flatHandover] ??
        AuthorizationModel();
    _filesAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.files] ??
        AuthorizationModel();
    _callLogsAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.payTrackCallLog] ??
        AuthorizationModel();
  }

  void initOverview() async {
    await _payTrackCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
    await _payTrackCubit.getEnquiryById(
      enquiryId: widget.enquiryId,
      projectId: widget.projectId,
    );
    if (mounted) {
      await _payTrackCubit.getPayTrackCallLog(
        context,
        1,
        widget.projectId,
        widget.bookingId,
      );
    }
    if (mounted) {
      await _payTrackCubit.getPayTrackList(context, 1, widget.projectId);
    }
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    final index = _tabController.index;
    final selectedTab = _tabs[index];
    context.read<PayTrackCubit>().onTabChanged(
      context,
      selectedTab,
      projectId: widget.projectId,
      employeeId: 0,
    );
    // if (!_tabController.indexIsChanging) {
    //   if (_tabController.index == 0) {
    //     switch (_tabController.index) {
    //       case 0:
    //         initOverview();
    //         break;
    //     }
    //   }
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    isExpanded.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Pay Track",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            isSecondaryStyle: true,
            tabs: _tabs.map((m) => m.title).toList(),
          ),
          BlocBuilder<PayTrackCubit, PayTrackState>(
            builder: (context, state) {
              return Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    if (_bookingPayTrackRouteAuthorizationModel.isView)
                      _buildOverviewTab(state, context),
                    if (_bankLoansRouteAuthorizationModel.isView) ...{
                      LoanDetailsScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                        approvalStatus: "Approved",
                      ),
                    },
                    if (_accountRouteAuthorizationModel.isView) ...{
                      PaymentScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                        applicantName: widget.applicantName,
                        bookingApprovalStatus: widget.bookingApprovalStatus,
                        approvalStatus: widget.approvalStatus,
                      ),
                    },
                    if (_modifiedRequestsAuthorizationModel.isView)
                      RequestManagementScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                        approvalStatus: widget.bookingApprovalStatus,
                      ),
                    if (_snagChecklistAuthorizationModel.isView)
                      SnagCheckListScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                      ),
                    if (_flatHandoverChecklistAuthorizationModel.isView)
                      FlatHandoverChecklistScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                      ),
                    if (_flatHandoverAuthoriationModel.isView)
                      FlatHandoverScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                      ),
                    if (_filesAuthorizationModel.isView)
                      FilesScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                      ),
                    if (_callLogsAuthorizationModel.isView)
                      CallLogsScreen(
                        projectId: widget.projectId,
                        bookingId: widget.bookingId,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PayTrackState state, BuildContext context) {
    if ((state.isLoading ?? false)) {
      return const Center(child: CircularProgressIndicator());
    }

    final booking = state.bookingData;
    if (booking == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final enquiry = state.currentEnquiryDetails;
    if (enquiry == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final bool isDirectWalking = enquiry.source == "Direct Walkin";
    final source = enquiry.source.toLowerCase().replaceAll("-", "").trim();

    final bool isDirectWalkingForCPDetails =
        source == "direct walkin" || source == "directwalkin";

    final bool isAdvertisement = enquiry.subSource == "Advertisement";
    final isHtml =
        booking.termsAndConditionsDescription.contains('<') &&
        booking.termsAndConditionsDescription.contains('>');
    final pendingAmount =
        booking.totalAmountRefundedAgainstBooking -
        booking.refundedAmountOnTillDate;
    final bool isEmployeeReference =
        enquiry.subSource.trim().toLowerCase() == "employee reference";

    final bool showUpdateRegistrationButton =
        _bookingPayTrackRouteAuthorizationModel.isAction &&
        _tabController.index == 0 &&
        !booking.isFinalRegistrationCompleted &&
        widget.bookingApprovalStatus.trim().toUpperCase() == "APPROVED";
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(height: 5),
          Text(
            widget.applicantName,
            style: AppTextStyle.ts16M(color: AppColor.primary),
          ),
          if (showUpdateRegistrationButton)
            Row(
              children: [
                Expanded(
                  child: CustomMessageButton(
                    onMessage: () async {
                      final result = await _payTrackCubit.getBookingById(
                        context,
                        1,
                        widget.projectId,
                        widget.bookingId,
                        exportType: "WELCOME MESSAGE",
                      );

                      if (result != null && context.mounted) {
                        showSuccessMessage(
                          context,
                          subTitle: "Message sent successfully.",
                        );
                      }
                    },
                    onEmail: () async {
                      final result = await _payTrackCubit.getBookingById(
                        context,
                        1,
                        widget.projectId,
                        widget.bookingId,
                        exportType: "WELCOME MESSAGE ON MAIL",
                      );

                      if (result != null && context.mounted) {
                        showSuccessMessage(
                          context,
                          subTitle: "Email sent successfully.",
                        );
                      }
                    },
                  ),
                ),
                horizontalSpacing(),
                CustomButton(
                  text: "Update Registration Date & Parking",
                  onPressed: () {
                    goRouter.pushNamed(
                      AppRoutes.updateRegistrationDateAndParking,
                      extra: {
                        "projectId": widget.projectId,
                        "bookingId": widget.bookingId,
                      },
                    );
                  },
                ),
              ],
            ),

          Container(
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enquiry Details",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unique Code",
                      value: enquiry.systemGeneratedCode,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Name", value: enquiry.name),
                    buildColumnTitleValue(
                      title: "Mobile No.",
                      value: enquiry.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        countryCode: enquiry.mobileNumberCountryCode,
                        value: enquiry.mobileNumber,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Source",
                      value: enquiry.source,
                    ),
                    buildColumnTitleValue(
                      title: "Sub Source",
                      value: enquiry.subSource,
                    ),
                  ],
                ),
                if (isDirectWalking && isAdvertisement)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Sub Sub Source",
                        value: enquiry.subSubSource,
                      ),
                    ],
                  ),
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
                      title: "Current Location",
                      value: enquiry.currentLocation,
                    ),
                  ],
                ),
                if (isEmployeeReference)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Employee Name",
                          value: enquiry.employeeReferenceName,
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Employee Mobile Number",
                          value: enquiry.employeeReferenceMobileNumber,
                          customValueWidget: CustomClickToContactText(
                            countryCode: "+91",
                            value: enquiry.employeeReferenceMobileNumber,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!isDirectWalkingForCPDetails)
            Container(
              decoration: BoxDecoration(
                color: AppColor.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 10.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "CP Code",
                        value: enquiry.channelPartnerCode,
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "CP E-mail ID",
                        value: enquiry.channelPartnerEmailId,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "CP Name",
                        value: enquiry.channelPartnerName,
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "CP Mobile No.",
                        value: enquiry.channelPartnerMobileNumber,
                        customValueWidget: CustomClickToContactText(
                          countryCode:
                              enquiry.channelPartnerMobileNumberCountryCode,
                          value: enquiry.channelPartnerMobileNumber,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "CP Team Member Name",
                        value: enquiry.channelPartnerTeamMemberName,
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "CP Team Mobile No.",
                        value: enquiry.channelPartnerTeamMemberMobileNumber,
                        customValueWidget: CustomClickToContactText(
                          countryCode:
                              enquiry
                                  .channelPartnerTeamMemberMobileNumberCountryCode,
                          value: enquiry.channelPartnerTeamMemberMobileNumber,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "CP Team E-Mail ID",
                        value: enquiry.channelPartnerTeamMemberEmailId,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Container(
            height: 450,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Applicant Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: booking.bookingApplicantData.length,
                    itemBuilder: (_, index) {
                      final applicant = booking.bookingApplicantData[index];

                      return infoCard(
                        bgColor: AppColor.white,
                        borderColor: AppColor.primary,

                        titleWidget: Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                applicant.applicantName,
                                style: AppTextStyle.ts14M(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            horizontalSpacing(),
                            _buildApplicantTypeWidget(applicant.applicantType),
                          ],
                        ),

                        [
                          {
                            "title": "Mobile Number",
                            "value": applicant.applicantMobileNumber,
                            "widget": CustomClickToContactText(
                              countryCode:
                                  applicant.applicantMobileNumberCountryCode,
                              value: applicant.applicantMobileNumber,
                              type: ContactType.phone,
                            ),
                          },
                          {
                            "title": "Email ID",
                            "value": applicant.applicantEmailId,
                            "widget": CustomClickToContactText(
                              value: applicant.applicantEmailId,
                              type: ContactType.email,
                            ),
                          },
                          {
                            "title": "Aadhaar Card No.",
                            "value": applicant.aadharCardNumber,
                          },
                          {
                            "title": "Aadhaar Card",
                            "value": applicant.aadharCardURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.aadharCardURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    title: "Aadhaar Card",
                                    context,
                                    applicant.aadharCardURL.split(","),
                                  );
                                }
                              },

                              isDisable: applicant.aadharCardURL.isEmpty,
                            ),
                          },
                          {
                            "title": "PAN Card No.",
                            "value": applicant.panNumber,
                          },
                          {
                            "title": "PAN Card",
                            "value": applicant.panCardURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.panCardURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "PAN Card",
                                    applicant.panCardURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.panCardURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Driving License",
                            "value": applicant.drivingLicenseNumber,
                          },
                          {
                            "title": "Driving License",
                            "value": applicant.drivingLicenseURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.drivingLicenseURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Driving License",
                                    applicant.drivingLicenseURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.drivingLicenseURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Voting ID No.",
                            "value": applicant.votingIdNumber,
                          },
                          {
                            "title": "Voting ID",
                            "value": applicant.votingIdURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.votingIdURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Voting ID",
                                    applicant.votingIdURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.votingIdURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Passport No.",
                            "value": applicant.passportNumber,
                          },
                          {
                            "title": "Passport",
                            "value": applicant.passportURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.passportURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Passport",
                                    applicant.passportURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.passportURL.isEmpty,
                            ),
                          },
                          {"title": "GST No.", "value": applicant.gstNumber},
                          {
                            "title": "GST Certificate",
                            "value": applicant.gstNumberURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.gstNumberURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "GST Certificate",
                                    applicant.gstNumberURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.gstNumberURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Cancelled Cheque",
                            "value": applicant.cancelledChequeUrl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.cancelledChequeUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Cancelled Cheque",
                                    applicant.cancelledChequeUrl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.cancelledChequeUrl.isEmpty,
                            ),
                          },
                          {
                            "title": "POA (if NRI Execution)",
                            "value": applicant.poaurl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.poaurl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "POA (if NRI Execution)",
                                    applicant.poaurl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.poaurl.isEmpty,
                            ),
                          },
                          {
                            "title": "Income Docs (Form 16 / ITR)",
                            "value": applicant.incomeForm16Itrurl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.incomeForm16Itrurl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Income Docs (Form 16 / ITR)",
                                    applicant.incomeForm16Itrurl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.incomeForm16Itrurl.isEmpty,
                            ),
                          },
                          {
                            "title": "NRE / NRO Bank Details",
                            "value": applicant.nreNroBankDetailsUrl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.nreNroBankDetailsUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "NRE / NRO Bank Details",
                                    applicant.nreNroBankDetailsUrl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.nreNroBankDetailsUrl.isEmpty,
                            ),
                          },
                          {
                            "title": "Nominee Form",
                            "value": applicant.nomineeFormUrl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.nomineeFormUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Nominee Form",
                                    applicant.nomineeFormUrl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.nomineeFormUrl.isEmpty,
                            ),
                          },
                          {
                            "title": "Statement Of Source Of Funds",
                            "value": applicant.statementOfSourceOfFundsURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant
                                    .statementOfSourceOfFundsURL
                                    .isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Statement Of Source Of Funds",
                                    applicant.statementOfSourceOfFundsURL.split(
                                      ",",
                                    ),
                                  );
                                }
                              },
                              isDisable:
                                  applicant.statementOfSourceOfFundsURL.isEmpty,
                            ),
                          },

                          {
                            "title": "Payment Proof",
                            "value": applicant.paymentProofURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.paymentProofURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Payment Proof",
                                    applicant.paymentProofURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.paymentProofURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Profile Photo",
                            "value": applicant.photoURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.photoURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    title: "Profile Photo",
                                    applicant.photoURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.photoURL.isEmpty,
                            ),
                          },
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // PROJECT DETAILS SECTION
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Name",
                      value: booking.projectName,
                    ),
                    buildColumnTitleValue(
                      title: "Booking Type",
                      value: booking.bookingType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit No.",
                      value: booking.flat,
                    ),
                    buildColumnTitleValue(title: "Wing", value: booking.wing),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Floor", value: booking.floor),
                    buildColumnTitleValue(
                      title: "Building Number",
                      value: booking.buildingNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Flat Type",
                      value: booking.flatType,
                    ),
                    buildColumnTitleValue(
                      title: "Flat Configuration",
                      value: booking.flatConfiguration,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Carpet Area (SqFt)",
                      value: booking.reraCarpetAreaSqFt.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Parking Number",
                      value: booking.parkingNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PARKING SECTION
          Container(
            height: 350,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Parking Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child:
                      booking.parkingData.isEmpty
                          ? Center(
                            child: noDataWidget(
                              message: 'No Parking Data Found',
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: booking.parkingData.length,
                            itemBuilder: (_, index) {
                              final parking = booking.parkingData[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.primary,
                                    width: .3,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    Text(
                                      "Parking ${index + 1}",
                                      style: AppTextStyle.ts14SB(
                                        color: AppColor.greyTitleAndValueColor
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Parking Number",
                                          value: parking.parkingNumber,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Building",
                                          value: parking.buildingNumber,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Wing",
                                          value: parking.wing,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Floor",
                                          value: parking.floor,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Category",
                                          value: parking.parkingCategory,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Type",
                                          value: parking.parkingType,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Size",
                                          value: parking.parkingSubType,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Dimensions",
                                          value: parking.parkingDimensions,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "EV Charging",
                                          value:
                                              parking.isEVChargingAvailable
                                                  ? "Yes"
                                                  : "No",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          // BOOKING DETAILS SECTION
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Expected Registration Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        booking.registrationDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Final Registration Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        booking.finalRegistrationDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Final Registration Completed",
                      value:
                          booking.isFinalRegistrationCompleted ? "Yes" : "No",
                    ),
                    buildColumnTitleValue(
                      title: "Handover Type",
                      value: booking.handoverType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Source Of Funding",
                      value: booking.sourceOfFunding,
                    ),
                    buildColumnTitleValue(
                      title: "Number Of Parking",
                      value: booking.numberOfParking.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // BOOKING SUMMARY
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking Summary", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) With TDS",
                      value: booking.agreementValue.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) Without TDS",
                      value:
                          (booking.agreementValue - booking.agreementValueTDS)
                              .toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "TDS (₹)",
                      value: booking.agreementValueTDS.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "GST (%)",
                      value: "${booking.agreementValueGSTPercentage}%",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "GST (₹)",
                      value: booking.agreementValueGSTAmount.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Stamp Duty (%)",
                      value: "${booking.stampDutyPercentage}%",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Stamp Duty (₹)",
                      value: booking.stampDutyAmount.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Registration Fees (₹)",
                      value: booking.registrationFees.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Booking Amount (₹)",
                      value: booking.bookingAmount.toIndianCurrency(),
                    ),
                  ],
                ),
                if (booking.loyaltyAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Loyalty (%)",
                        value: "${booking.loyaltyPercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Loyalty Amount (₹)",
                        value: booking.loyaltyAmount.toIndianCurrency(),
                      ),
                    ],
                  ),
                if (booking.brokerageAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Brokerage (%)",
                        value: "${booking.brokeragePercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Brokerage Amount (₹)",
                        value: booking.brokerageAmount.toIndianCurrency(),
                      ),
                    ],
                  ),
                if (booking.employeeReferenceAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Employee Reference (%)",
                        value: "${booking.employeeReferencePercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Employee Reference Amount (₹)",
                        value:
                            booking.employeeReferenceAmount.toIndianCurrency(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // PAYMENT DETAILS
          Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Cheque / RTGS No.",
                      value: booking.chequeRTGSNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Cheque / RTGS Date",
                      value:
                          booking.chequeRTGSDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                booking.chequeRTGSDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Bank Name",
                      value: booking.bankName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // OTHER CHARGES SECTION
          Container(
            height: 450,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Other Charges", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child:
                      booking.bookingOtherChargesData.isNotEmpty
                          ? ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: booking.bookingOtherChargesData.length,
                            itemBuilder: (_, index) {
                              final extraCharge =
                                  booking.bookingOtherChargesData[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.primary,
                                    width: .3,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Charges",
                                          value: extraCharge.chargeName,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Calculated On",
                                          value: extraCharge.calculatedOn,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Value (In ₹)",
                                          value:
                                              extraCharge.value
                                                  .toIndianCurrency(),
                                        ),
                                        buildColumnTitleValue(
                                          title: "GST (%)",
                                          value:
                                              extraCharge.gstPercentage
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "GST Value (₹)",
                                          value:
                                              extraCharge.gstValue
                                                  .toIndianCurrency(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                          : Center(
                            child: noDataWidget(
                              message: "No Other Charges Available",
                              iconSize: 180,
                            ),
                          ),
                ),
              ],
            ),
          ),
          // PAYMENT SCHEDULE SECTION
          Container(
            height: 250,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Schedule", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Scheme",
                        style: AppTextStyle.ts14SB(
                          color: AppColor.greyTitleAndValueColor.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: " : ",
                        style: AppTextStyle.ts14SB(
                          color: AppColor.greyTitleAndValueColor.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: booking.paymentScheduleScheme,
                        style: AppTextStyle.ts14SB(),
                      ),
                    ],
                  ),
                ),
                verticalSpacing(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: booking.bookingPaymentScheduleData.length,
                    itemBuilder: (context, index) {
                      final payment = booking.bookingPaymentScheduleData[index];
                      final totalAmountWithTDS =
                          payment.paymentScheduleAmount -
                          payment.paymentScheduleTDSAmount;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primary,
                            width: .3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                payment.type.contains("Date")
                                    ? buildColumnTitleValue(
                                      title: "Date / Type",
                                      value:
                                          payment.date != null
                                              ? formatDateTimeAsDDMMMYYYY(
                                                payment.date!,
                                              )
                                              : "-",
                                    )
                                    : buildColumnTitleValue(
                                      title: "Stage",
                                      value: payment.name,
                                    ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Percentage (%)",
                                  value:
                                      "${payment.paymentSchedulePercentage} %",
                                ),
                                buildColumnTitleValue(
                                  title: "Amount Without TDS (₹)",
                                  value:
                                      payment.paymentScheduleAmount
                                          .toIndianCurrency(),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "GST Amount (₹)",
                                  value:
                                      payment.paymentScheduleGSTAmount
                                          .toIndianCurrency(),
                                ),
                                buildColumnTitleValue(
                                  title: "TDS Amount (₹)",
                                  value:
                                      payment.paymentScheduleTDSAmount
                                          .toIndianCurrency(),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Amount With TDS (₹)",
                                  value: totalAmountWithTDS.toIndianCurrency(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // FLAT ALTERATION REMARKS SECTION
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Flat Alteration Remarks", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: booking.flatAlterationRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PAYMENT REMARK
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Remarks", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: booking.paymentRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // OTHER REMARK
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Other Remarks", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: booking.otherRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // TERMS AND CONDITIONS
          Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, value, child) {
                final hasData =
                    booking.termsAndConditionsDescription.trim().isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        isExpanded.value = !isExpanded.value;
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Terms & Conditions",
                                style: AppTextStyle.ts16SB(),
                              ),
                            ),
                            Icon(
                              value
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (value && hasData) ...[
                      const SizedBox(height: 10),
                      isHtml
                          ? Html(
                            data: booking.termsAndConditionsDescription,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                            },
                          )
                          : Text(
                            booking.termsAndConditionsDescription,
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                    ] else if (value && !hasData) ...[
                      Center(
                        child: noDataWidget(
                          message: "No Terms & Conditions Available",
                          iconSize: 180,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          // CANCELLATION SUMMARY
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cancellation Summary", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Cancelled Date",
                        value: formatDateTimeAsDDMMMYYYY(booking.cancelledDate),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Cancelled By",
                        value: booking.cancelledBy,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Remark",
                        value: booking.cancelRemark,
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Proof Of Document",
                        value: booking.cancelledBy,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (booking.proofOfDocumentUrl.isNotEmpty) {
                              showFilePreviewDialog(
                                context,
                                title: "Proof Of Document",
                                booking.proofOfDocumentUrl.split(","),
                              );
                            }
                          },
                          isDisable: booking.proofOfDocumentUrl.isEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // REFUND AMOUNT DETAILS
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Refund Amount Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Total Refunded",
                        value:
                            booking.totalAmountRefundedAgainstBooking
                                .toIndianCurrency(),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Paid",
                        value:
                            booking.refundedAmountOnTillDate.toIndianCurrency(),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Pending",
                        value: pendingAmount.toIndianCurrency(),
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Refund Status",
                        value: booking.approvalStatus,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Created By",
                      value: booking.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDate(booking.createdDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value: booking.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value: formatDate(booking.modifiedDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Approval Status",
                      value: booking.approvalStatus,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Call Log History", style: AppTextStyle.ts16SB()),

                const SizedBox(height: 20),

                state.payTrackCallLogList.isEmpty
                    ? Center(
                      child: noDataWidget(
                        message: "No Call Logs Found",
                        iconSize: 180,
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.payTrackCallLogList.length,
                      itemBuilder: (context, index) {
                        final callLog = state.payTrackCallLogList[index];

                        final bool isLast =
                            index == state.payTrackCallLogList.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT TIMELINE
                              Column(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppColor.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 3,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        color: AppColor.primary,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 16),

                              // RIGHT CONTENT
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // DATE + STATUS
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatDateTimeAsDDMMMYYYY(
                                                callLog.createdDate,
                                              ),
                                              style: AppTextStyle.ts16SB(),
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusBgColor(
                                                callLog.callStatus,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              callLog.callStatus.toUpperCase(),
                                              style: AppTextStyle.ts12M(
                                                color: _getStatusTextColor(
                                                  callLog.callStatus,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // CREATED BY
                                      Text(
                                        callLog.createdBy,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // PURPOSE
                                      RichText(
                                        text: TextSpan(
                                          text: "Purpose: ",
                                          style: AppTextStyle.ts14SB(
                                            color: AppColor.black,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: callLog.callPurpose,
                                              style: AppTextStyle.ts14SB(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // PROMISE AMOUNT
                                      Text(
                                        "Promise Amount: ${callLog.promiseAmount.toIndianCurrency()}",
                                        style: AppTextStyle.ts14SB(
                                          color: Colors.green,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // REMARK
                                      Text(
                                        callLog.remark,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.black,
                                        ),
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
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return Colors.green.withValues(alpha: .12);

      case "assigned":
        return Colors.blue.withValues(alpha: .12);

      case "in progress":
        return Colors.orange.withValues(alpha: .12);

      case "resolved":
        return Colors.amber.withValues(alpha: .18);

      case "pending":
        return Colors.grey.withValues(alpha: .15);

      default:
        return Colors.grey.withValues(alpha: .12);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return AppColor.green;

      case "assigned":
        return AppColor.primary;

      case "in progress":
        return AppColor.orange;

      case "resolved":
        return Colors.brown;

      case "pending":
        return AppColor.black;

      default:
        return AppColor.black;
    }
  }

  // BUILD APPLICANT TYPE WIDGET
  Widget _buildApplicantTypeWidget(String type) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            type.toLowerCase() == "applicant"
                ? AppColor.lightBlue
                : AppColor.purple.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: AppTextStyle.ts12M(
          color:
              type.toLowerCase() == "applicant"
                  ? AppColor.primary
                  : AppColor.purple,
        ),
      ),
    );
  }
}

class CustomMessageButton extends StatefulWidget {
  final bool isDisabled;
  final VoidCallback onMessage;
  final VoidCallback onEmail;

  const CustomMessageButton({
    super.key,
    required this.onMessage,
    required this.onEmail,
    this.isDisabled = false,
  });

  @override
  State<CustomMessageButton> createState() => _CustomMessageButtonState();
}

class _CustomMessageButtonState extends State<CustomMessageButton> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    const double dropdownWidth = 160.0;

    final RenderBox buttonBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;

    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);

    final double screenWidth = MediaQuery.of(context).size.width;

    double shiftX = 0;

    final overflowRight = buttonPosition.dx + dropdownWidth - screenWidth;

    if (overflowRight > 0) {
      shiftX = -overflowRight - 8;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(shiftX, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropdownWidth,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildItem(
                        icon: Icons.message_outlined,
                        label: "Send Message",
                        onTap: () {
                          _removeOverlay();
                          widget.onMessage();
                        },
                      ),
                      _buildItem(
                        icon: Icons.email_outlined,
                        label: "Send e-mail",
                        onTap: () {
                          _removeOverlay();
                          widget.onEmail();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomButton(
        key: _buttonKey,
        text: "Message",
        isDisable: widget.isDisabled,
        onPressed: _toggleOverlay,
      ),
    );
  }
}
