import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_state.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPaymentLedgerScreen extends StatefulWidget {
  final PayTrackPaymentLedgerSummaryModel summary;
  const ViewPaymentLedgerScreen({super.key, required this.summary});

  @override
  State<ViewPaymentLedgerScreen> createState() =>
      _ViewPaymentLedgerScreenState();
}

class _ViewPaymentLedgerScreenState extends State<ViewPaymentLedgerScreen> {
  late PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paymentCubit.getPaymentLedgerSummaryList(
        context,
        widget.summary.bookingId,
        widget.summary.projectId,
        widget.summary.paymentFor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Payment Ledger",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.summary.paymentFor, style: AppTextStyle.ts14M()),
                ListView.builder(
                  itemCount: state.payTrackPaymentLedgerSummaryList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final summary =
                        state.payTrackPaymentLedgerSummaryList[index];
                    final approvalStatus = summary.approvalStatus;

                    final isAlreadyApproved =
                        approvalStatus.toLowerCase() == "approved";
                    final isRejected =
                        approvalStatus.toLowerCase() == "rejected";
                    final isEditDeleteDisabled =
                        isAlreadyApproved || isRejected;
                    return Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: commonCardDecoration(),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          iconColor: AppColor.black,
                          collapsedIconColor: AppColor.black,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildRow(
                                  "Amount",
                                  summary.receivedAmount.toIndianCurrency(),
                                ),
                              ),
                              horizontalSpacing(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomIconButton.edit(
                                    isDisabled: isEditDeleteDisabled,
                                    onPressed: () async {
                                      goRouter.pushNamed(
                                        AppRoutes.addPaymentLedger,
                                        queryParameters: {
                                          'paymentLedger': Uri.encodeComponent(
                                            jsonEncode([summary.toJson()]),
                                          ),
                                        },
                                      );
                                    },
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton.delete(
                                    isDisabled: isEditDeleteDisabled,
                                    onPressed: () {
                                      _paymentCubit.deletePayTrackPaymentLedger(
                                        context: context,
                                        payTrackPaymentLedgerId:
                                            summary.payTrackPaymentLedgerId,
                                        uniqueKey: summary.uniquekey,
                                        bookingId: summary.bookingId,
                                        projectId: summary.projectId,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6.0,
                              children: [
                                buildRowTitleValue(
                                  title: "Payment Mode",
                                  value: summary.paymentFor,
                                ),
                                ApproveRejectWidget(
                                  isActionAlreadyPerformed:
                                      isAlreadyApproved || isRejected,
                                  actionTitle:
                                      approvalStatus.isEmpty
                                          ? "Pending"
                                          : approvalStatus,
                                  approveIcon: Icons.check,
                                  onApprove: (remark) async {
                                    final isSuccess = await context
                                        .read<LoginCubit>()
                                        .updateModulesWorkflowApproval(
                                          context: context,
                                          moduleName:
                                              'PAY TRACK LEDGER APPROVAL',
                                          id: summary.payTrackPaymentLedgerId,
                                          projectId: summary.projectId,
                                          isApproved: true,
                                          remark: remark.trim(),
                                        );

                                    if (context.mounted && isSuccess) {
                                      await _paymentCubit
                                          .getPaymentLedgerSummaryList(
                                            context,
                                            summary.bookingId,
                                            summary.projectId,
                                            summary.paymentFor,
                                          );
                                    }
                                  },
                                  onReject: (remark) async {
                                    await context
                                        .read<LoginCubit>()
                                        .updateModulesWorkflowApproval(
                                          context: context,
                                          moduleName:
                                              'PAY TRACK LEDGER APPROVAL',
                                          id: summary.bookingId,
                                          projectId: summary.projectId,
                                          isApproved: false,
                                          remark: remark.trim(),
                                        );
                                  },
                                  onThirdTap: () async {
                                    final approvalLogHistoryList = await context
                                        .read<LoginCubit>()
                                        .getApprovalLogHistory(
                                          context: context,
                                          projectId: summary.projectId,
                                          id: summary.bookingId,
                                          moduleName:
                                              'PAY TRACK LEDGER APPROVAL',
                                        );
                                    if (context.mounted) {
                                      goRouter.pushNamed(
                                        AppRoutes.approvalLogHistory,
                                        queryParameters: {
                                          "title": Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              "PAY TRACK LEDGER APPROVAL",
                                            ),
                                          ),
                                          "approvalList": Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(
                                                approvalLogHistoryList
                                                    .map((e) => e.toJson())
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        },
                                      );
                                    }
                                  },
                                  popupTitle: "PAY TRACK LEDGER APPROVAL",
                                ),
                                Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: AppColor.lightGreyBackground,
                                    border: Border.all(
                                      color: AppColor.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    spacing: 12.0,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Our Bank Details",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      buildColumnTitleValueNormal(
                                        title: "Bank Name",
                                        value: summary.bankName,
                                      ),
                                      buildColumnTitleValueNormal(
                                        title: "Account Number",
                                        value: summary.projectAccountNumber,
                                      ),
                                      buildColumnTitleValueNormal(
                                        title: "IFSC Code",
                                        value: summary.projectIfscCode,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: AppColor.lightGreyBackground,
                                    border: Border.all(
                                      color: AppColor.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    spacing: 12.0,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Opposite Party Bank Details",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      buildColumnTitleValueNormal(
                                        title: "Bank Name",
                                        value: summary.bankName,
                                      ),
                                      buildColumnTitleValueNormal(
                                        title:
                                            "Transaction / Cheque / Demand Draft No",
                                        value:
                                            summary
                                                .transactionChequeDemandDraftNumber,
                                      ),
                                      buildColumnTitleValueNormal(
                                        title:
                                            "Transaction / Cheque / Demand Draft Date",
                                        value: formatDateTimeAsDDMMMYYYY(
                                          summary
                                              .transactionChequeDemandDraftDate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: AppColor.lightGreyBackground,
                                    border: Border.all(
                                      color: AppColor.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    spacing: 12.0,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Others",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Created By",
                                              value: summary.createdBy,
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Created Date",
                                              value: formatDateTimeAsDDMMMYYYY(
                                                summary.createdDate,
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
                                              title: "Modified By",
                                              value: summary.modifiedBy,
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Modified Date",
                                              value: formatDateTimeAsDDMMMYYYY(
                                                summary.modifiedDate,
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts14R(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            ":   ",
            style: AppTextStyle.ts14R(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.ts14M(color: AppColor.black),
            ),
          ),
        ],
      ),
    );
  }
}
