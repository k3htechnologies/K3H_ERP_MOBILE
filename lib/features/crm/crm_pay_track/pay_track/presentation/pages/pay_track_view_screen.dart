// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/presentation/cubit/call_logs_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/presentation/pages/call_logs.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/pages/files.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/pages/flat_handover_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/pages/flat_handover_checklist.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/pages/loan_details_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/pages/widget/custom_message_update_parking.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/payment_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_management_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/pages/snag_checklist.screen.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/widgets/applicant_card.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_enums.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import 'widget/pay_track_tab_view.dart';

class PayTrackViewScreen extends StatefulWidget {
  final String applicantName;
  final int projectId;
  final int bookingId;
  final int enquiryId;
  final String bookingApprovalStatus;
  final String approvalStatus;
  final String flat;
  const PayTrackViewScreen({
    super.key,
    required this.applicantName,
    required this.projectId,
    required this.bookingId,
    required this.enquiryId,
    required this.bookingApprovalStatus,
    required this.approvalStatus,
    required this.flat,
  });

  @override
  State<PayTrackViewScreen> createState() => _PayTrackViewScreenState();
}

class _PayTrackViewScreenState extends State<PayTrackViewScreen> {
  late PayTrackCubit _payTrackCubit;
  late CallLogsCubit _callLogsCubit;
  late ValueNotifier<bool> isExpanded;
  // TRUE ONLY AFTER THIS BOOKING'S getBookingById HAS FINISHED
  final ValueNotifier<bool> _bookingLoaded = ValueNotifier(false);

  late AuthorizationModel _bookingPayTrackRouteAuthorizationModel,
      _bankLoansRouteAuthorizationModel,
      _paymentLedgerAuthorization,
      _paymentScheduleAuthorization,
      _modifiedRequestsAuthorizationModel,
      _snagChecklistAuthorizationModel,
      _flatHandoverChecklistAuthorizationModel,
      _flatHandoverAuthoriationModel,
      _filesAuthorizationModel,
      _callLogsAuthorizationModel;

  final ValueNotifier<List<TenantModel>> _tenantModel = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _initAuth();
    _payTrackCubit = context.read<PayTrackCubit>();
    _callLogsCubit = context.read<CallLogsCubit>();
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
    _paymentLedgerAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.paymentLedger] ??
        AuthorizationModel();

    _paymentScheduleAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.crmPaymentSchedule] ??
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
    try {
      await _payTrackCubit.getBookingById(
        context,
        1,
        widget.projectId,
        widget.bookingId,
      );
      final booking = _payTrackCubit.state.bookingData;
      if (booking?.tenantId == 0) {
        await _payTrackCubit.getEnquiryById(
          enquiryId: widget.enquiryId,
          projectId: widget.projectId,
        );
      } else {
        _tenantModel.value = await _payTrackCubit.getTenantById(
          context: context,
          projectId: widget.projectId,
          buildingId: booking?.tenantBuildingId ?? 0,
          tenantId: booking?.tenantId ?? 0,
        );
      }
    } finally {
      if (mounted) _bookingLoaded.value = true;
    }

    if (mounted) {
      await _callLogsCubit.getCallLog(
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

  List<PayTrackTab> _buildTabs(PayTrackState state) {
    //HIDE : BANK LOAN AND ACCOUNT TAB
    final noAgreementValue =
        state.bookingData?.agreementValue == 0 &&
        state.bookingData?.tenantId != 0;

    return [
      if (_bookingPayTrackRouteAuthorizationModel.isView)
        PayTrackTab.bookingPayTrack,
      if (_bankLoansRouteAuthorizationModel.isView && !noAgreementValue)
        PayTrackTab.bankLoan,
      if ((_paymentLedgerAuthorization.isView ||
              _paymentScheduleAuthorization.isView) &&
          !noAgreementValue)
        PayTrackTab.paymentLedger,
      if (_modifiedRequestsAuthorizationModel.isView)
        PayTrackTab.modificationRequest,
      if (_snagChecklistAuthorizationModel.isView) PayTrackTab.snagChecklist,
      if (_flatHandoverChecklistAuthorizationModel.isView)
        PayTrackTab.flatHandoverChecklist,
      if (_flatHandoverAuthoriationModel.isView) PayTrackTab.flatHandover,
      if (_filesAuthorizationModel.isView) PayTrackTab.files,
      if (_callLogsAuthorizationModel.isView) PayTrackTab.payTrackCallLog,
    ];
  }

  Widget _tabContent(PayTrackTab tab, PayTrackState state) {
    switch (tab) {
      case PayTrackTab.bookingPayTrack:
        return _buildOverviewTab(state, context);
      case PayTrackTab.bankLoan:
        return LoanDetailsScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          approvalStatus: "Approved",
          bookingApprovalStatus: widget.bookingApprovalStatus,
        );
      case PayTrackTab.paymentLedger:
        return PaymentScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          applicantName: widget.applicantName,
          bookingApprovalStatus: widget.bookingApprovalStatus,
          approvalStatus: widget.approvalStatus,
          flat: widget.flat,
          bookingOtherChargesList: state.bookingData!.bookingOtherChargesData,
        );
      case PayTrackTab.modificationRequest:
        return RequestManagementScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          approvalStatus: widget.bookingApprovalStatus,
        );
      case PayTrackTab.snagChecklist:
        return SnagCheckListScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          bookingApprovalStatus: widget.bookingApprovalStatus,
        );
      case PayTrackTab.flatHandoverChecklist:
        return FlatHandoverChecklistScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          bookingApprovalStatus: widget.bookingApprovalStatus,
        );
      case PayTrackTab.flatHandover:
        return FlatHandoverScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          bookingApprovalStatus: widget.bookingApprovalStatus,
        );
      case PayTrackTab.files:
        return FilesScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          bookingApprovalStatus: widget.bookingApprovalStatus,
        );
      case PayTrackTab.payTrackCallLog:
        return CallLogsScreen(
          projectId: widget.projectId,
          bookingId: widget.bookingId,
          bookingApprovalStatus: widget.bookingApprovalStatus,
        );
    }
  }

  void _onTabSelected(PayTrackTab tab) {
    context.read<PayTrackCubit>().onTabChanged(
      context,
      tab,
      projectId: widget.projectId,
      employeeId: 0,
    );
  }

  @override
  void dispose() {
    isExpanded.dispose();
    _bookingLoaded.dispose();
    super.dispose();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: showSiteSelectedWidget(),
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _bookingLoaded,
              builder: (context, loaded, _) {
                if (!loaded) return Center(child: loader());
                return BlocBuilder<PayTrackCubit, PayTrackState>(
                  builder: (context, state) {
                    if (state.bookingData == null) {
                      return Center(child: loader());
                    }
                    final tabs = _buildTabs(state);
                    return PayTrackTabsView(
                      key: ValueKey(tabs.map((t) => t.name).join(',')),
                      tabs: tabs,
                      onTabSelected: _onTabSelected,
                      contentBuilder: _tabContent,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PayTrackState state, BuildContext context) {
    final booking = state.bookingData;
    final enquiry = state.currentEnquiryDetails;

    if (booking == null || (enquiry == null && _tenantModel.value.isEmpty)) {
      return Center(child: loader());
    }
    final bool isDirectWalking = enquiry?.source == "Direct Walkin";
    final source = enquiry?.source.toLowerCase().replaceAll("-", "").trim();

    final bool isDirectWalkingForCPDetails =
        source == "direct walkin" || source == "directwalkin";

    final bool isAdvertisement = enquiry?.subSource == "Advertisement";
    final isHtml =
        booking.termsAndConditionsDescription.contains('<') &&
        booking.termsAndConditionsDescription.contains('>');
    final pendingAmount =
        booking.totalAmountRefundedAgainstBooking -
        booking.refundedAmountOnTillDate;
    final bool isEmployeeReference =
        enquiry?.subSource.trim().toLowerCase() == "employee reference";

    final bool showUpdateRegistrationButton =
        _bookingPayTrackRouteAuthorizationModel.isAction &&
        !booking.isFinalRegistrationCompleted &&
        widget.bookingApprovalStatus.trim().toUpperCase() == "APPROVED";
    final approvalStatus = booking.approvalStatus.trim().toUpperCase();
    final List<Map<String, dynamic>> items = [];

    /// BASIC INFO
    items.addAll([
      {"title": "Enquiry Code", "value": enquiry?.systemGeneratedCode},
      {"title": "Name", "value": enquiry?.name},
      {
        "title": "Mobile No.",
        "value": enquiry?.mobileNumber,
        "widget": CustomClickToContactText(
          countryCode: enquiry?.mobileNumberCountryCode ?? "+91",
          value: enquiry?.mobileNumber ?? "",
        ),
      },
      {
        "title": "E-Mail ID",
        "value": enquiry?.emailId,
        "widget": CustomClickToContactText(
          value: enquiry?.emailId ?? '',
          type: ContactType.email,
        ),
      },
      {"title": "Current Location", "value": enquiry?.currentLocation},
      {"title": "Source", "value": enquiry?.source},
    ]);
    items.add({"title": "Sub Source", "value": enquiry?.subSource});
    if (isDirectWalking && isAdvertisement) {
      items.add({"title": "Sub Sub Source", "value": enquiry?.subSubSource});
    }

    items.addAll([
      {"title": "Sales Advisor", "value": enquiry?.salesAdvisor},
      {"title": "Sourcing Manager", "value": enquiry?.sourcingManager},
    ]);
    if (isEmployeeReference) {
      items.addAll([
        {"title": "Employee Name", "value": enquiry?.employeeReferenceName},
        {
          "title": "Employee Mobile Number",
          "value": enquiry?.employeeReferenceMobileNumber,
          "widget": CustomClickToContactText(
            countryCode: "+91",
            value: enquiry?.employeeReferenceMobileNumber ?? "",
          ),
        },
      ]);
    }

    final noAgreementValue =
        state.bookingData?.agreementValue == 0 &&
        state.bookingData?.tenantId != 0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: Text(
                  widget.applicantName,
                  style: AppTextStyle.ts14M(color: AppColor.primary),
                ),
              ),
              if (noAgreementValue)
                CustomMessageButton(
                  onWelcome: () async {
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
            ],
          ),
          if (showUpdateRegistrationButton && !noAgreementValue)
            Row(
              children: [
                Expanded(
                  child: CustomMessageButton(
                    onWelcome: () async {
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
          if (enquiry != null) ...[
            infoCard(items, title: "Enquiry Details"),
            if (!isDirectWalkingForCPDetails)
              infoCard([
                {"title": "CP Code", "value": enquiry.channelPartnerCode},
                {
                  "title": "CP E-Mail ID",
                  "value": enquiry.channelPartnerEmailId,
                },
              ]),
            verticalSpacing(),
          ] else ...[
            ValueListenableBuilder(
              valueListenable: _tenantModel,
              builder: (context, tenantM, child) {
                final tenant = tenantM.first;
                final total =
                    tenant.totalNewRERACarpetAreaSqFt +
                    tenant.deckAreaSqFt +
                    tenant.areaAgainstTerraceSqFt;
                return Column(
                  children: [
                    verticalSpacing(),
                    SectionCard(
                      title: "Existing Unit Details",
                      titleTextColor: AppColor.darkBlue29,
                      headerBackgroundColor: AppColor.darkBlue29.withValues(
                        alpha: 0.1,
                      ),
                      children: _pairRows([
                        ("Tenant Code", tenant.systemGeneratedCode),
                        (
                          "Unit / Annexure / Survey Number",
                          tenant.unitAnnexureSurveyNumber,
                        ),
                        ("Unit Type", tenant.unitType),
                        ("Unit Configuration", tenant.unitConfiguration),
                        (
                          "Unit Carpet Area (SqFt)",
                          tenant.unitCarpetAreaSqFt.addCommas(),
                        ),
                        ("Unit Facing", tenant.unitFacing),
                      ]),
                    ),
                    SectionCard(
                      title: 'Eligibility Details in Carpet Area (SqFt)',
                      titleTextColor: AppColor.brown,
                      headerBackgroundColor: AppColor.lightYellow,
                      children: [
                        ..._pairRows([
                          (
                            "Extra Free Carpet Area Offered (%)",
                            tenant.extraFreeCarpetAreaOfferedPercent
                                .addCommas(),
                          ),
                          (
                            "Free MOFA Carpet Area (SqFt)",
                            tenant.freeMOFACarpetAreaSqFt.addCommas(),
                          ),
                          (
                            "Existing Terrace Area (SqFt)",
                            tenant.existingTerraceAreaSqFt.addCommas(),
                          ),
                          (
                            "New Eligibility MOFA Carpet Area (SqFt)",
                            tenant.newEligibilityMOFACarpetAreaSqFt.addCommas(),
                          ),
                          (
                            "New Eligibility RERA Carpet Area (SqFt)",
                            tenant.newEligibilityRERACarpetAreaSqFt.addCommas(),
                          ),
                          (
                            "(A) Area Against Terrace (SqFt)",
                            tenant.areaAgainstTerraceSqFt.addCommas(),
                          ),
                          (
                            "MOFA Carpet Area Purchased (SqFt)",
                            tenant.mofaCarpetAreaPurchasedSqFt.addCommas(),
                          ),
                          (
                            "RERA Carpet Area Purchased (SqFt)",
                            tenant.reraCarpetAreaPurchasedSqFt.addCommas(),
                          ),
                          (
                            "(B) Deck Area (SqFt)",
                            tenant.deckAreaSqFt.addCommas(),
                          ),
                          (
                            "Total New MOFA Carpet Area (SqFt)",
                            tenant.totalNewMOFACarpetAreaSqFt.addCommas(),
                          ),
                          (
                            "(C) Total New RERA Carpet Area (SqFt)",
                            tenant.totalNewRERACarpetAreaSqFt.addCommas(),
                          ),
                        ]),
                        buildRowWrapper(
                          child: buildColumnTitleValue(
                            title:
                                "Area Against Terrace + Deck Area + Total New RERA Carpet Area (SqFt) (A + B + C)",
                            value: total.addCommas(),
                          ),
                        ),
                        buildRowWrapper(
                          child: buildColumnTitleValue(
                            title: "Remark",
                            value: tenant.remark,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
          SectionCard(
            title: "Applicant Details",
            headerBackgroundColor: AppColor.lightYellowBg2,
            titleTextColor: AppColor.brownYellowText,
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              SizedBox(
                height: 0.5.sh,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                  shrinkWrap: true,
                  itemCount: booking.bookingApplicantData.length,
                  itemBuilder: (_, index) {
                    final applicant = booking.bookingApplicantData[index];
                    return ApplicantCard(applicant: applicant);
                  },
                ),
              ),
            ],
          ),
          // ADDRESS DETAILS SECTION
          SectionCard(
            title: "Address Details",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Permanent Address",
                  value: booking.permanentAddress,
                ),
              ),
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Communication Address",
                  value: booking.communicationAddress,
                ),
              ),
            ],
          ),
          // PROJECT DETAILS SECTION
          SectionCard(
            title: "Project Details",
            titleTextColor: AppColor.blueBgColor,
            headerBackgroundColor: Color(0xffF6F9FF),
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
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
                  buildColumnTitleValue(title: "Unit No.", value: booking.flat),
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
          // PARKING SECTION
          if (booking.parkingData.isNotEmpty) ...{
            SectionCard(
              title: "Parking Details",
              titleTextColor: AppColor.blueBgColor,
              headerBackgroundColor: Color(0xffF6F9FF),
              border: Border.all(
                color: AppColor.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              children: [
                booking.parkingData.isEmpty
                    ? SizedBox(
                      height: 250.0,
                      child: Center(
                        child: noDataWidget(
                          message: 'No Parking Data Found',
                          iconSize: 160,
                        ),
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
                            spacing: 10,
                            children: [
                              Row(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          },
          // BOOKING DETAILS SECTION
          SectionCard(
            title: "Booking Details",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Expected Registration Date",
                    value: formatDateTimeAsDDMMMYYYY(booking.registrationDate),
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
                    value: booking.isFinalRegistrationCompleted ? "Yes" : "No",
                    customValueWidget: DocumentPreviewText(
                      title: "Final Registration Completed",
                      text: booking.isFinalRegistrationCompleted ? "Yes" : "No",
                      fileUrl: booking.finalRegistrationUrl,
                    ),
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
          // BOOKING SUMMARY
          if (enquiry != null)
            SectionCard(
              title: "Booking Summary",
              headerBackgroundColor: AppColor.lightPurpleBg2,
              titleTextColor: AppColor.purpleColor,
              border: Border.all(
                color: AppColor.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              children: [
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
          if (enquiry == null)
            SectionCard(
              title: "Booking Summary",
              headerBackgroundColor: AppColor.lightPurpleBg2,
              titleTextColor: AppColor.purpleColor,
              border: Border.all(
                color: AppColor.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Booking Registered",
                      customValueWidget: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.carpetAreaPurchasedSqFt,
                          style: AppTextStyle.ts12SB(color: AppColor.primary),
                        ),
                      ),
                      value: booking.carpetAreaPurchasedSqFt,
                    ),
                    buildColumnTitleValue(
                      title: "Carpet Area Purchased (SqFt)",
                      value:
                          booking.carpetAreaPurchasedSqFt == 'MOFA'
                              ? _tenantModel
                                  .value
                                  .first
                                  .mofaCarpetAreaPurchasedSqFt
                                  .addCommas()
                              : _tenantModel
                                  .value
                                  .first
                                  .reraCarpetAreaPurchasedSqFt
                                  .addCommas(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Adjust Purchase Area (SqFt)",
                      value: booking.adjustPurchaseAreaSqFt.addCommas(),
                    ),
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) With TDS",
                      value: booking.agreementValue.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) Without TDS",
                      value:
                          (booking.agreementValue - booking.agreementValueTDS)
                              .toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "TDS (₹)",
                      value: booking.agreementValueTDS.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "GST (%)",
                      value: "${booking.agreementValueGSTPercentage}%",
                    ),
                    buildColumnTitleValue(
                      title: "GST (₹)",
                      value: booking.agreementValueGSTAmount.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Stamp Duty (%)",
                      value: "${booking.stampDutyPercentage}%",
                    ),
                    buildColumnTitleValue(
                      title: "Stamp Duty (₹)",
                      value: booking.stampDutyAmount.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Registration Fees (₹)",
                      value: booking.registrationFees.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Booking Amount (₹)",
                      value: booking.bookingAmount.toIndianCurrency(),
                    ),
                  ],
                ),
              ],
            ),
          // PAYMENT DETAILS
          SectionCard(
            title: "Payment Details",
            headerBackgroundColor: AppColor.lightYellow,
            titleTextColor: AppColor.brown,
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
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
                            ? formatDateTimeAsDDMMMYYYY(booking.chequeRTGSDate!)
                            : "-",
                  ),
                ],
              ),
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
          // OTHER CHARGES SECTION
          SectionCard(
            title: "Other Charges",
            headerBackgroundColor: AppColor.lightPurpleBg2,
            titleTextColor: AppColor.purple,
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              SizedBox(
                height: 250.0,
                child:
                    booking.bookingOtherChargesData.isNotEmpty
                        ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: booking.bookingOtherChargesData.length,
                          itemBuilder: (_, index) {
                            final extraCharge =
                                booking.bookingOtherChargesData[index];
                            final bool isLast =
                                index ==
                                booking.bookingOtherChargesData.length - 1;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.only(
                                bottom: isLast ? 0.0 : 10.0,
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Name",
                                        value: extraCharge.chargeName,
                                      ),
                                      buildColumnTitleValue(
                                        title: "Calculated On",
                                        value: extraCharge.calculatedOn,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "GST Value (₹)",
                                        value:
                                            extraCharge.gstValue
                                                .toIndianCurrency(),
                                      ),
                                      buildColumnTitleValue(
                                        title: "Total Value (₹)",
                                        value:
                                            (extraCharge.value +
                                                    extraCharge.gstValue)
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
                            message: "No Charges Available",
                            iconSize: 160,
                          ),
                        ),
              ),
            ],
          ),
          SectionCard(
            headerBackgroundColor: AppColor.lightBlueBg2,
            titleTextColor: AppColor.blue,
            title: "Payment Schedule (${booking.paymentScheduleScheme})",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              SizedBox(
                height: 250.0,
                child:
                    booking.bookingPaymentScheduleData.isEmpty
                        ? Center(
                          child: noDataWidget(
                            iconSize: 160,
                            message: "No Payment Schedule Found",
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount: booking.bookingPaymentScheduleData.length,
                          itemBuilder: (context, index) {
                            final payment =
                                booking.bookingPaymentScheduleData[index];
                            final bool isLast =
                                index ==
                                booking.bookingPaymentScheduleData.length - 1;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.only(
                                bottom: isLast ? 0.0 : 10,
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Type",
                                        value: payment.type,
                                      ),
                                      payment.type.contains("Date")
                                          ? buildColumnTitleValue(
                                            title: "Date",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Total Amount With TDS (₹)",
                                        value:
                                            (payment.paymentScheduleAmount +
                                                    payment
                                                        .paymentScheduleTDSAmount)
                                                .toIndianCurrency(),
                                      ),
                                      Spacer(),
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
          SectionCard(
            title: "Unit / Modulation / Customization Remark",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Text(
                booking.flatAlterationRemark.isEmpty
                    ? "-"
                    : booking.flatAlterationRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Payment Remarks",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Text(
                booking.paymentRemark.isEmpty ? "-" : booking.paymentRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Other Remarks",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Text(
                booking.otherRemark.isEmpty ? "-" : booking.otherRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Terms & Conditions",
            headerBackgroundColor: AppColor.lightRed,
            titleTextColor: AppColor.missingInformationRed,
            maxContentHeight: 0.5.sh,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 1,
                    color: AppColor.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking.termsAndConditionsDescription
                        .trim()
                        .isNotEmpty) ...[
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
                    ] else ...[
                      Center(
                        child: noDataWidget(
                          message: "No Terms & Conditions Available",
                          iconSize: 160,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // CANCELLATION SUMMARY
          if (approvalStatus == "CANCEL" ||
              booking.cancelRemark.trim().isNotEmpty) ...{
            SectionCard(
              title: "Cancellation Summary",
              headerBackgroundColor: AppColor.grey10,
              titleTextColor: AppColor.black,
              border: Border.all(
                color: AppColor.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildColumnTitleValue(
                      title: "Cancelled Date",
                      value: formatDateTimeAsDDMMMYYYY(booking.cancelledDate),
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
                      title: "Cancelled By",
                      value: booking.cancelledBy,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildColumnTitleValue(
                      title: "Remark",
                      value: booking.cancelRemark,
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
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
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Status",
                      value: booking.cancelBookingApprovalStatus,
                    ),
                  ],
                ),
              ],
            ),
          },
          // REFUND AMOUNT DETAILS
          if (approvalStatus == "REFUND") ...{
            SectionCard(
              title: "Refund Amount Details",
              headerBackgroundColor: AppColor.grey10,
              titleTextColor: AppColor.black,
              border: Border.all(
                color: AppColor.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildColumnTitleValue(
                      title: "Total Refunded",
                      value:
                          booking.totalAmountRefundedAgainstBooking
                              .toIndianCurrency(),
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
                      title: "Paid",
                      value:
                          booking.refundedAmountOnTillDate.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildColumnTitleValue(
                      title: "Pending",
                      value: pendingAmount.toIndianCurrency(),
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
                      title: "Refund Status",
                      value: booking.approvalStatus,
                    ),
                  ],
                ),
              ],
            ),
          },
          BlocBuilder<CallLogsCubit, CallLogsState>(
            builder: (context, state) {
              return SectionCard(
                title: "Call Log History",
                titleTextColor: AppColor.darkGreen10,
                headerBackgroundColor: AppColor.darkGreen10.withValues(
                  alpha: 0.1,
                ),
                border: Border.all(
                  color: AppColor.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
                children: [
                  state.payTrackCallLogList.isEmpty
                      ? Center(
                        child: noDataWidget(
                          message: "No Call Logs Found",
                          iconSize: 160,
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                            callLogStatusWidget(
                                              callLog.callStatus,
                                            ),
                                          ],
                                        ),
                                        verticalSpacing(height: 8),
                                        Text(
                                          callLog.createdBy,
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                        if (callLog.callPurpose.isNotEmpty) ...[
                                          verticalSpacing(),
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
                                        ],
                                        if (callLog.promiseAmount > 0) ...[
                                          verticalSpacing(),
                                          Text(
                                            "Promise Amount: ${callLog.promiseAmount.toIndianCurrency()}",
                                            style: AppTextStyle.ts14SB(
                                              color: Colors.green,
                                            ),
                                          ),
                                          verticalSpacing(),
                                          Text(
                                            callLog.remark,
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.black,
                                            ),
                                          ),
                                        ],
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
              );
            },
          ),
          SectionCard(
            title: "Action Details",
            headerBackgroundColor: AppColor.grey.withValues(alpha: 0.2),
            titleTextColor: AppColor.black,
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
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
        ],
      ),
    );
  }


  List<Widget> _pairRows(List<(String, String)> items) => [
    for (var i = 0; i < items.length; i += 2)
      _infoRow([
        for (final e in items.skip(i).take(2))
          buildColumnTitleValue(title: e.$1, value: e.$2),
      ]),
  ];

  Widget _infoRow(List<Widget> children) => Row(
    spacing: 10,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}
