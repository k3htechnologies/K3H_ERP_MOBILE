// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/activity_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/refund_payment_ledger.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RequestManagementScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const RequestManagementScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
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

  @override
  void initState() {
    super.initState();
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
              current.showRefundPaymentLedgerTab,
      listener: (context, state) {},
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
            ),
            ActivityTabScreen(state: state),
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
            booking.cancelBookingApprovalStatus.trim().toUpperCase() ==
            "APPROVED";

        final canMakePayment =
            booking.totalAmountRefundedAgainstBooking >
            booking.refundedAmountOnTillDate;
        Widget? actionButton;
        if (!isBookingCancelled && !isRefundStatus) {
          actionButton = CustomButton(
            text: "Cancel Booking",
            backgroundColor: AppColor.missingInformationRed.withValues(
              alpha: 0.3,
            ),
            textColor: AppColor.missingInformationRed,
            onPressed: () {
              goRouter.pushNamed(AppRoutes.cancelBookingScreen, extra: booking);
            },
          );
        } else if (isBookingCancelled && !isRefundStatus && isCancelApproved) {
          actionButton = CustomButton(
            text: "Initiate Refund",
            backgroundColor: AppColor.primary.withValues(alpha: 0.15),
            textColor: AppColor.primary,
            onPressed: () {
              goRouter.pushNamed(
                AppRoutes.addRefundScreen,
                extra: {"booking": booking},
              );
            },
          );
        } else if (isRefundStatus && canMakePayment) {
          actionButton = CustomButton(
            text: "Make Payment",
            backgroundColor: AppColor.green,
            textColor: AppColor.white,
            onPressed: () {
              goRouter.pushNamed(
                AppRoutes.modifiedRequestsMakePayment,
                extra: {
                  "uniquekey": booking.uniquekey,
                  "bookingId": booking.bookingId,
                  "projectId": booking.projectId,
                },
              );
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
                                  spacing: 16.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValueNormal(
                                      title: "Applicant Type",
                                      value: applicant.applicantType,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Applicant Name",
                                            value: applicant.applicantName,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  text: applicant.applicantName,
                                                  fileUrl: applicant.photoURL,
                                                ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Mobile Number",
                                            value:
                                                applicant.applicantMobileNumber,
                                            customValueWidget:
                                                CustomClickToContactText(
                                                  countryCode:
                                                      applicant
                                                          .applicantMobileNumberCountryCode,
                                                  value:
                                                      applicant
                                                          .applicantMobileNumber,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Email Id",
                                            value: applicant.applicantEmailId,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Aadhaar Card No.",
                                            value: applicant.aadharCardNumber,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Aadhaar Card",
                                                  text:
                                                      applicant
                                                          .aadharCardNumber,
                                                  fileUrl:
                                                      applicant.aadharCardURL,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "PAN No.",
                                            value: applicant.panNumber,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "PAN Card",
                                                  text: applicant.panNumber,
                                                  fileUrl: applicant.panCardURL,
                                                ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Driving License",
                                            value:
                                                applicant.drivingLicenseNumber,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Droivinh License",
                                                  text:
                                                      applicant
                                                          .drivingLicenseNumber,
                                                  fileUrl:
                                                      applicant
                                                          .drivingLicenseURL,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Voting ID",
                                            value: applicant.votingIdNumber,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Voting ID",
                                                  text:
                                                      applicant.votingIdNumber,
                                                  fileUrl:
                                                      applicant.votingIdURL,
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
                                                      applicant.passportNumber,
                                                  fileUrl:
                                                      applicant.passportURL,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "GST Number",
                                            value: applicant.gstNumber,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "GST Number",
                                                  text: applicant.gstNumber,
                                                  fileUrl:
                                                      applicant.gstNumberURL,
                                                ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Cancelled Cheque",
                                            value: applicant.cancelledChequeUrl,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Cancelled Cheque",
                                                  text:
                                                      applicant
                                                          .cancelledChequeUrl,
                                                  fileUrl:
                                                      applicant
                                                          .cancelledChequeUrl,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "POA (if NRI Execution)",
                                            value: applicant.poaurl,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title:
                                                      "POA (if NRI Execution)",
                                                  text: applicant.poaurl,
                                                  fileUrl: applicant.poaurl,
                                                ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title:
                                                "Income Docs (Form 16 / ITR)",
                                            value: applicant.incomeForm16Itrurl,
                                            customValueWidget: DocumentPreviewText(
                                              title:
                                                  "Income Docs (Form 16 / ITR)",
                                              text:
                                                  applicant.incomeForm16Itrurl,
                                              fileUrl:
                                                  applicant.incomeForm16Itrurl,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Nre/Nro/Bank Details",
                                            value:
                                                applicant.nreNroBankDetailsUrl,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Nre/Nro/Bank Details",
                                                  text:
                                                      applicant
                                                          .nreNroBankDetailsUrl,
                                                  fileUrl:
                                                      applicant
                                                          .nreNroBankDetailsUrl,
                                                ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Nominee Form",
                                            value: applicant.nomineeFormUrl,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Nominee Form",
                                                  text:
                                                      applicant.nomineeFormUrl,
                                                  fileUrl:
                                                      applicant.nomineeFormUrl,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title:
                                                "Statement Of Source Of Funds",
                                            value:
                                                applicant
                                                    .statementOfSourceOfFundsURL,
                                            customValueWidget: DocumentPreviewText(
                                              title:
                                                  "Statement Of Source Of Funds",
                                              text:
                                                  applicant
                                                      .statementOfSourceOfFundsURL,
                                              fileUrl:
                                                  applicant
                                                      .statementOfSourceOfFundsURL,
                                            ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Payment Proof",
                                            value: applicant.paymentProofURL,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  title: "Payment Proof",
                                                  text:
                                                      applicant.paymentProofURL,
                                                  fileUrl:
                                                      applicant.paymentProofURL,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Created By",
                                            value: applicant.createdBy,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Created Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              applicant.createdDate,
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
                                children: List.generate(booking.parkingData.length, (
                                  index,
                                ) {
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
                                                        parking.buildingNumber,
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
                                                    value: parking.parkingType,
                                                  ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child:
                                                  buildColumnTitleValueNormal(
                                                    title: "Size",
                                                    value:
                                                        parking.parkingSubType,
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
                                                        parking.parkingCategory,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  buildColumnTitleValueNormal(
                                                    title: "Approval Status",
                                                    value:
                                                        parking.approvalStatus,
                                                  ),
                                            ),
                                            horizontalSpacing(),
                                            Expanded(
                                              child: buildColumnTitleValueNormal(
                                                title: "EV Charging",
                                                value:
                                                    parking.isEVChargingAvailable
                                                        ? "Yes"
                                                        : "No",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
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
                              "Flat Specification Remark",
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
