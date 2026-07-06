// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/activity_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RequestManagementCubit _requestManagementCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _requestManagementCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
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

        // case 1:
        //   await _paymentCubit.getPaymentLedgerList(
        //     context,
        //     widget.bookingId,
        //     widget.projectId,
        //   );
        //   break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(),
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ['Summary', 'Request', 'Activity'],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildSummaryTab(context),
                  RequestTabScreen(
                    projectId: widget.projectId,
                    bookingId: widget.bookingId,
                  ),
                  ActivityTabScreen(state: state),
                ],
              ),
            ),
          ],
        );
      },
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
                                            title: "Full Name",
                                            value: applicant.applicantName,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Contact Number",
                                            value:
                                                applicant.applicantMobileNumber,
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
                                            title: "PAN Card No.",
                                            value: applicant.panNumber,
                                            customValueWidget:
                                                DocumentPreviewText(
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
                                            title: "POA",
                                            value: applicant.poaurl,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  text: applicant.poaurl,
                                                  fileUrl: applicant.poaurl,
                                                ),
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Income Form 16IT",
                                            value: applicant.incomeForm16Itrurl,
                                            customValueWidget:
                                                DocumentPreviewText(
                                                  text:
                                                      applicant
                                                          .incomeForm16Itrurl,
                                                  fileUrl:
                                                      applicant
                                                          .incomeForm16Itrurl,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildColumnTitleValueNormal(
                                          title: "Parking Number",
                                          value:
                                              booking
                                                  .parkingData
                                                  .first
                                                  .parkingNumber,
                                        ),
                                        horizontalSpacing(),
                                        buildColumnTitleValueNormal(
                                          title: "Category",
                                          value:
                                              booking
                                                  .parkingData
                                                  .first
                                                  .parkingCategory,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildColumnTitleValueNormal(
                                          title: "Type",
                                          value:
                                              booking
                                                  .parkingData
                                                  .first
                                                  .parkingType,
                                        ),
                                        horizontalSpacing(),
                                        buildColumnTitleValueNormal(
                                          title: "Size",
                                          value:
                                              booking
                                                  .parkingData
                                                  .first
                                                  .parkingSubType,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildColumnTitleValueNormal(
                                          title: "Wing",
                                          value: booking.parkingData.first.wing,
                                        ),
                                        horizontalSpacing(),
                                        buildColumnTitleValueNormal(
                                          title: "Floor",
                                          value:
                                              booking.parkingData.first.floor,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildColumnTitleValueNormal(
                                          title: "Approval Status",
                                          value:
                                              booking
                                                  .parkingData
                                                  .first
                                                  .approvalStatus,
                                        ),
                                      ],
                                    ),
                                  ],
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
                                      Text(
                                        bookingData.flatAlterationRemark,
                                        style: AppTextStyle.ts14M(),
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
                    child:
                        (booking.totalAmountRefundedAgainstBooking == 0 ||
                                booking.totalAmountRefundedAgainstBooking ==
                                    null)
                            ? CustomButton(
                              text: "Initiate Refund",
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.addRefundScreen,
                                  extra: {"booking": booking},
                                );
                              },
                              backgroundColor: AppColor.primary.withValues(
                                alpha: 0.15,
                              ),
                              textColor: AppColor.primary,
                            )
                            : CustomButton(
                              text: "Make Payment",
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.modifiedRequestsMakePayment,
                                  extra: {
                                    "uniquekey": booking.uniquekey,
                                    "bookingId": booking.bookingId.toString(),
                                    "projectId": booking.projectId.toString(),
                                  },
                                );
                              },
                              backgroundColor: AppColor.green,
                              textColor: AppColor.white,
                            ),
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
