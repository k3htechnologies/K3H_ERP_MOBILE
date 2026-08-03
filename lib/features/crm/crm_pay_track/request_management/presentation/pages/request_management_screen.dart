// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/activity_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/refund_payment_ledger.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RequestManagementScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? approvalStatus;
  const RequestManagementScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.approvalStatus,
  });

  @override
  State<RequestManagementScreen> createState() =>
      _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late RequestManagementCubit _requestManagementCubit;

  bool _showRefundTab = false;
  late AuthorizationModel _modifiedRequestsAuthorization;

  @override
  void initState() {
    super.initState();
    _modifiedRequestsAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.modificationRequest] ??
        AuthorizationModel();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    await _requestManagementCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );

    final show = _requestManagementCubit.state.showRefundPaymentLedgerTab;

    if (_showRefundTab != show) {
      _showRefundTab = show;
      _recreateController();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _recreateController() {
    final currentIndex = _tabController.index;

    _tabController.dispose();

    _tabController = TabController(
      length: _showRefundTab ? 4 : 3,
      vsync: this,
      initialIndex: currentIndex.clamp(0, (_showRefundTab ? 4 : 3) - 1),
    );

    _tabController.addListener(_handleTabChange);
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          await _requestManagementCubit.getBookingById(
            context,
            1,
            widget.projectId,
            widget.bookingId,
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestManagementCubit, RequestManagementState>(
      listenWhen:
          (previous, current) =>
              previous.showRefundPaymentLedgerTab !=
                  current.showRefundPaymentLedgerTab ||
              previous.showRefundPaymentSuccessMessage !=
                  current.showRefundPaymentSuccessMessage,
      listener: (context, state) {
        if (state.showRefundPaymentSuccessMessage) {
          showSuccessMessage(
            context,
            subTitle: "Refund Amount Initiated successfully",
          );

          context
              .read<RequestManagementCubit>()
              .clearRefundPaymentSuccessMessage();
        }
      },
      child: BlocBuilder<RequestManagementCubit, RequestManagementState>(
        builder: (context, state) {
          final tabs = ['Summary', 'Requests', 'Activity'];

          if (_showRefundTab) {
            tabs.add('Refund Payment Ledger');
          }

          final pages = [
            _buildSummaryTab(context),
            RequestTabScreen(
              projectId: widget.projectId,
              bookingId: widget.bookingId,
              approvalStatus: widget.approvalStatus,
            ),
            ActivityTabScreen(
              bookingId: widget.bookingId,
              projectId: widget.projectId,
            ),
          ];

          if (_showRefundTab) {
            pages.add(RefundPaymentLedgerScreen(booking: state.bookingData!));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              ChipStyleTabBar(controller: _tabController, tabs: tabs),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        if (state.isLoading ?? true && state.bookingData == null) {
          return Center(child: CircularProgressIndicator());
        }
        final bookingData = state.bookingData;
        if (bookingData == null || bookingData.bookingApplicantData.isEmpty) {
          return const Center(child: Text("No Applicant Data Found"));
        }
        final booking = bookingData;
        final applicant = bookingData.bookingApplicantData.first;
        final isBookingCancelled = booking.cancelRemark.trim().isNotEmpty;

        final isRefundStatus =
            booking.approvalStatus.trim().toUpperCase() == "REFUND";

        final isCancelApproved =
            (booking.cancelBookingApprovalStatus.trim().toUpperCase() ==
                "APPROVED");

        final canMakePayment =
            booking.totalAmountRefundedAgainstBooking >
            booking.refundedAmountOnTillDate;
        Widget? actionButton;
        if (!isBookingCancelled &&
            !isRefundStatus &&
            _modifiedRequestsAuthorization.isAction) {
          actionButton = CustomButton(
            text: "Cancel Booking",
            backgroundColor: AppColor.missingInformationRed.withValues(
              alpha: 0.3,
            ),
            textColor: AppColor.missingInformationRed,
            onPressed: () async {
              final result = await goRouter.pushNamed<bool>(
                AppRoutes.cancelBookingScreen,
                extra: booking,
              );

              if (result == true && context.mounted) {
                await context.read<PayTrackCubit>().getPayTrackList(
                  context,
                  1,
                  booking.projectId,
                );

                if (context.mounted) {
                  await context.read<RequestManagementCubit>().getBookingById(
                    context,
                    1,
                    booking.projectId,
                    booking.bookingId,
                  );
                }
              }
            },
          );
        } else if (isBookingCancelled &&
            !isRefundStatus &&
            isCancelApproved &&
            _modifiedRequestsAuthorization.isAction) {
          actionButton = CustomButton(
            text: "Initiate Refund",
            backgroundColor: AppColor.primary.withValues(alpha: 0.15),
            textColor: AppColor.primary,
            onPressed: () async {
              await goRouter.pushNamed(
                AppRoutes.addRefundScreen,
                extra: {"booking": booking},
              );

              if (!context.mounted) return;

              context.read<PayTrackCubit>().getPayTrackList(
                context,
                1,
                booking.projectId,
              );
            },
          );
        } else if (isRefundStatus &&
            canMakePayment &&
            _modifiedRequestsAuthorization.isAction) {
          actionButton = CustomButton(
            text: "Make Payment",
            backgroundColor: AppColor.green,
            textColor: AppColor.white,
            onPressed: () async {
              final result = await goRouter.pushNamed(
                AppRoutes.modifiedRequestsMakePayment,
                extra: {
                  "uniquekey": booking.uniquekey,
                  "bookingId": booking.bookingId,
                  "projectId": booking.projectId,
                },
              );

              if (result == true && context.mounted) {
                await context.read<RequestManagementCubit>().getBookingById(
                  context,
                  1,
                  booking.projectId,
                  booking.bookingId,
                );

                if (context.mounted) {
                  await context
                      .read<RequestManagementCubit>()
                      .getRefundAmountPaymentLedger(
                        context,
                        booking.projectId,
                        booking.bookingId,
                      );
                }

                _tabController.animateTo(3);
              }
            },
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bookingData.bookingApplicantData.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: commonCardDecoration(),
                          child: Center(
                            child: Text(
                              "No Applicant Details Found",
                              style: AppTextStyle.ts14M(),
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Applicant Details",
                                style: AppTextStyle.ts16SB(),
                              ),
                              verticalSpacing(),
                              ListView.builder(
                                itemCount:
                                    bookingData.bookingApplicantData.length,
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final applicantDetails =
                                      bookingData.bookingApplicantData[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: AppColor.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      spacing: 16.0,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValueNormal(
                                          title: "Applicant Type",
                                          value: applicantDetails.applicantType,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Applicant Name",
                                                value:
                                                    applicantDetails
                                                        .applicantName,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Profile Photo",
                                                      text:
                                                          applicantDetails
                                                              .applicantName,
                                                      fileUrl:
                                                          applicantDetails
                                                              .photoURL,
                                                    ),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Mobile Number",
                                                value:
                                                    applicantDetails
                                                        .applicantMobileNumber,
                                                customValueWidget:
                                                    CustomClickToContactText(
                                                      countryCode:
                                                          applicantDetails
                                                              .applicantMobileNumberCountryCode,
                                                      value:
                                                          applicantDetails
                                                              .applicantMobileNumber,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child:
                                                  buildColumnTitleValueNormal(
                                                    title: "Email Id",
                                                    value:
                                                        applicantDetails
                                                            .applicantEmailId,
                                                  ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Aadhaar Card No.",
                                                value:
                                                    applicantDetails
                                                        .aadharCardNumber,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Aadhaar Card",
                                                      text:
                                                          applicantDetails
                                                              .aadharCardNumber,
                                                      fileUrl:
                                                          applicantDetails
                                                              .aadharCardURL,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child:
                                                  buildColumnTitleValueNormal(
                                                    title: "PAN No.",
                                                    value:
                                                        applicantDetails
                                                            .panNumber,
                                                    customValueWidget:
                                                        DocumentPreviewText(
                                                          title: "PAN Card",
                                                          text:
                                                              applicantDetails
                                                                  .panNumber,
                                                          fileUrl:
                                                              applicantDetails
                                                                  .panCardURL,
                                                        ),
                                                  ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Driving License",
                                                value:
                                                    applicantDetails
                                                        .drivingLicenseNumber,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Driving License",
                                                      text:
                                                          applicantDetails
                                                              .drivingLicenseNumber,
                                                      fileUrl:
                                                          applicantDetails
                                                              .drivingLicenseURL,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Voting ID No.",
                                                value:
                                                    applicantDetails
                                                        .votingIdNumber,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Voting ID",
                                                      text:
                                                          applicantDetails
                                                              .votingIdNumber,
                                                      fileUrl:
                                                          applicantDetails
                                                              .votingIdURL,
                                                    ),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Passport No.",
                                                value: applicant.passportNumber,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Passport",
                                                      text:
                                                          applicant
                                                              .passportNumber,
                                                      fileUrl:
                                                          applicant.passportURL,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child:
                                                  buildColumnTitleValueNormal(
                                                    title: "GST No.",
                                                    value:
                                                        applicantDetails
                                                            .gstNumber,
                                                    customValueWidget:
                                                        DocumentPreviewText(
                                                          title: "GST No.",
                                                          text:
                                                              applicantDetails
                                                                  .gstNumber,
                                                          fileUrl:
                                                              applicantDetails
                                                                  .gstNumberURL,
                                                        ),
                                                  ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Cancelled Cheque",
                                                value:
                                                    applicantDetails
                                                        .cancelledChequeUrl,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Cancelled Cheque",
                                                      text:
                                                          applicantDetails
                                                                  .cancelledChequeUrl
                                                                  .isNotEmpty
                                                              ? "View"
                                                              : "-",
                                                      fileUrl:
                                                          applicantDetails
                                                              .cancelledChequeUrl,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "POA (if NRI Execution)",
                                                value: applicantDetails.poaurl,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title:
                                                          "POA (if NRI Execution)",
                                                      text:
                                                          applicantDetails
                                                                  .poaurl
                                                                  .isNotEmpty
                                                              ? "View"
                                                              : "-",
                                                      fileUrl:
                                                          applicantDetails
                                                              .poaurl,
                                                    ),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title:
                                                    "Income Docs (Form 16 / ITR)",
                                                value:
                                                    applicantDetails
                                                        .incomeForm16Itrurl,
                                                customValueWidget: DocumentPreviewText(
                                                  title:
                                                      "Income Docs (Form 16 / ITR)",
                                                  text:
                                                      applicantDetails
                                                              .incomeForm16Itrurl
                                                              .isNotEmpty
                                                          ? "View"
                                                          : "-",
                                                  fileUrl:
                                                      applicantDetails
                                                          .incomeForm16Itrurl,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Nre/Nro/Bank Details",
                                                value:
                                                    applicantDetails
                                                        .nreNroBankDetailsUrl,
                                                customValueWidget: DocumentPreviewText(
                                                  title: "Nre/Nro/Bank Details",
                                                  text:
                                                      applicantDetails
                                                              .nreNroBankDetailsUrl
                                                              .isNotEmpty
                                                          ? "View"
                                                          : "-",
                                                  fileUrl:
                                                      applicantDetails
                                                          .nreNroBankDetailsUrl,
                                                ),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Nominee Form",
                                                value: "View",
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Nominee Form",
                                                      text:
                                                          applicantDetails
                                                                  .nomineeFormUrl
                                                                  .isNotEmpty
                                                              ? "View"
                                                              : "-",
                                                      fileUrl:
                                                          applicantDetails
                                                              .nomineeFormUrl,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title:
                                                    "Statement Of Source Of Funds",
                                                value:
                                                    applicantDetails
                                                        .statementOfSourceOfFundsURL,
                                                customValueWidget: DocumentPreviewText(
                                                  title:
                                                      "Statement Of Source Of Funds",
                                                  text:
                                                      applicantDetails
                                                              .statementOfSourceOfFundsURL
                                                              .isNotEmpty
                                                          ? "View"
                                                          : "-",
                                                  fileUrl:
                                                      applicantDetails
                                                          .statementOfSourceOfFundsURL,
                                                ),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Payment Proof",
                                                value:
                                                    applicantDetails
                                                        .paymentProofURL,
                                                customValueWidget:
                                                    DocumentPreviewText(
                                                      title: "Payment Proof",
                                                      text:
                                                          applicantDetails
                                                                  .paymentProofURL
                                                                  .isNotEmpty
                                                              ? "View"
                                                              : "-",
                                                      fileUrl:
                                                          applicantDetails
                                                              .paymentProofURL,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child:
                                                  buildColumnTitleValueNormal(
                                                    title: "Created By",
                                                    value:
                                                        applicantDetails
                                                            .createdBy,
                                                  ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "Created Date",
                                                value:
                                                    formatDateTimeAsDDMMMYYYY(
                                                      applicantDetails
                                                          .createdDate,
                                                    ),
                                              ),
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
                        ),
                      if (bookingData.parkingData.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: commonCardDecoration(),
                          child: Center(
                            child: Text(
                              "No Parking Details Found",
                              style: AppTextStyle.ts14M(),
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Parking Details",
                                style: AppTextStyle.ts14SB(),
                              ),
                              verticalSpacing(),
                              Column(
                                children: List.generate(
                                  booking.parkingData.length,
                                  (index) {
                                    final parking = booking.parkingData[index];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColor.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 10.0,
                                        children: [
                                          Text(
                                            "Parking ${index + 1}",
                                            style: AppTextStyle.ts14SB(
                                              color: AppColor
                                                  .greyTitleAndValueColor
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                          verticalSpacing(),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Parking Number",
                                                      value:
                                                          parking.parkingNumber,
                                                    ),
                                              ),
                                              horizontalSpacing(),
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Building",
                                                      value:
                                                          parking
                                                              .buildingNumber,
                                                    ),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Type",
                                                      value:
                                                          parking.parkingType,
                                                    ),
                                              ),
                                              horizontalSpacing(),
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Size",
                                                      value:
                                                          parking
                                                              .parkingSubType,
                                                    ),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Wing",
                                                      value: parking.wing,
                                                    ),
                                              ),
                                              horizontalSpacing(),
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Floor",
                                                      value: parking.floor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Category",
                                                      value:
                                                          parking
                                                              .parkingCategory,
                                                    ),
                                              ),
                                              horizontalSpacing(),
                                              Expanded(
                                                child:
                                                    buildColumnTitleValueNormal(
                                                      title: "Dimensions",
                                                      value:
                                                          parking
                                                              .parkingDimensions,
                                                    ),
                                              ),
                                            ],
                                          ),

                                          horizontalSpacing(),
                                          buildColumnTitleValueNormal(
                                            title: "EV Charging",
                                            value:
                                                parking.isEVChargingAvailable
                                                    ? "Yes"
                                                    : "No",
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
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Unit / Modulation / Customization Remark",
                              style: AppTextStyle.ts14SB(),
                            ),
                            verticalSpacing(),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: AppColor.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bookingData.flatAlterationRemark,
                                          style: AppTextStyle.ts14M(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (bookingData.approvalStatus.trim().toUpperCase() ==
                              "CANCEL" ||
                          bookingData.cancelRemark.trim().isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cancellation Summary",
                                style: AppTextStyle.ts14SB(),
                              ),
                              verticalSpacing(),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: AppColor.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Cancelled Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              bookingData.cancelledDate,
                                            ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Cancelled By",
                                            value: bookingData.cancelledBy,
                                          ),
                                        ),
                                      ],
                                    ),
                                    verticalSpacing(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Remark",
                                            value: bookingData.cancelRemark,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Proof Of Document",
                                            value: bookingData.cancelledBy,
                                            customValueWidget:
                                                CustomButton.documentOutline(
                                                  onPressed: () {
                                                    if (bookingData
                                                        .proofOfDocumentUrl
                                                        .isNotEmpty) {
                                                      showFilePreviewDialog(
                                                        context,
                                                        title:
                                                            "Proof Of Document",
                                                        bookingData
                                                            .proofOfDocumentUrl
                                                            .split(","),
                                                      );
                                                    }
                                                  },
                                                  isDisable:
                                                      booking
                                                          .proofOfDocumentUrl
                                                          .isEmpty,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (bookingData.approvalStatus.trim().toUpperCase() ==
                          "REFUND")
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Refund Amount Details",
                                style: AppTextStyle.ts14SB(),
                              ),
                              verticalSpacing(),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: AppColor.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Total Refunded",
                                            value:
                                                bookingData
                                                    .totalAmountRefundedAgainstBooking
                                                    .toIndianCurrency(),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Paid",
                                            value:
                                                bookingData
                                                    .refundedAmountOnTillDate
                                                    .toIndianCurrency(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    verticalSpacing(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Pending",
                                            value:
                                                (bookingData.totalAmountRefundedAgainstBooking -
                                                        bookingData
                                                            .refundedAmountOnTillDate)
                                                    .toIndianCurrency(),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Refund Status",
                                            value: bookingData.approvalStatus,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: actionButton,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
