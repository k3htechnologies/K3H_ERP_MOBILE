import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../../utils/functions/common_function.dart';

class RefundPaymentLedgerScreen extends StatefulWidget {
  final BookingModel booking;
  const RefundPaymentLedgerScreen({super.key, required this.booking});

  @override
  State<RefundPaymentLedgerScreen> createState() =>
      _RefundPaymentLedgerScreenState();
}

class _RefundPaymentLedgerScreenState extends State<RefundPaymentLedgerScreen> {
  late RequestManagementCubit _requestManagementCubit;
  @override
  void initState() {
    super.initState();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _requestManagementCubit.getRefundAmountPaymentLedger(
      context,
      widget.booking.projectId,
      widget.booking.bookingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        if (state.refundAmountLedgerList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Refund Payment Ledger Found"),
          );
        }
        final refundData = state.refundAmountLedgerList.first;
        final approvalStatus = refundData.approvalStatus;
        final isAlreadyApproved = approvalStatus.toLowerCase() == "approved";
        final isRejected = approvalStatus.toLowerCase() == "rejected";
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColor.lightBlue,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Refund Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Total Refunded",
                            value:
                                widget.booking.totalAmountRefundedAgainstBooking
                                    .toIndianCurrency(),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Paid",
                            value:
                                widget.booking.refundedAmountOnTillDate
                                    .toIndianCurrency(),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Pending",
                            value:
                                (widget
                                            .booking
                                            .totalAmountRefundedAgainstBooking -
                                        widget.booking.refundedAmountOnTillDate)
                                    .toIndianCurrency(),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColor.formBackground,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    width: 1,
                    color: AppColor.black.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  spacing: 10.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValueNormal(
                              title: "Refunded Amount",
                              value:
                                  refundData.refundedAmount.toIndianCurrency(),
                            ),
                            verticalSpacing(),
                            buildColumnTitleValueNormal(
                              title: "Payment Mode",
                              value: refundData.paymentMode,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                final result = await goRouter.pushNamed(
                                  AppRoutes.modifiedRequestsMakePayment,
                                  extra: {
                                    "uniquekey": refundData.uniquekey,
                                    "bookingId": refundData.bookingId,
                                    "projectId": refundData.projectId,
                                    "refundData": refundData,
                                  },
                                );
                                if (result == true && context.mounted) {
                                  _requestManagementCubit
                                      .getRefundAmountPaymentLedger(
                                        context,
                                        widget.booking.projectId,
                                        widget.booking.bookingId,
                                      );
                                }
                              },
                              isDisabled:
                                  refundData.approvalStatus.toLowerCase() ==
                                  "approved",
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              onPressed: () {},
                              isDisabled:
                                  refundData.approvalStatus.toLowerCase() ==
                                  "approved",
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.3,
                      color: AppColor.black.withValues(alpha: 0.3),
                    ),
                    ApproveRejectWidget(
                      isActionAlreadyPerformed: isAlreadyApproved || isRejected,
                      actionTitle:
                          refundData.approvalStatus.isEmpty
                              ? "Pending"
                              : approvalStatus,
                      approveIcon: Icons.check,
                      onApprove: (onApprove) async {
                        final isSuccess = await context
                            .read<UtilsCubit>()
                            .updateModulesWorkflowApproval(
                              context: context,
                              moduleName: 'REFUND PAYMENT LEDGER APPROVAL',
                              id: refundData.bookingId,
                              subId: refundData.refundedAmountLedgerId,
                              projectId: refundData.projectId,
                              isApproved: true,
                              remark: onApprove.trim(),
                            );
                        if (context.mounted && isSuccess) {
                          await _requestManagementCubit
                              .getRefundAmountPaymentLedger(
                                context,
                                widget.booking.projectId,
                                widget.booking.bookingId,
                              );
                        }
                      },
                      onReject: (onReject) async {
                        await context
                            .read<UtilsCubit>()
                            .updateModulesWorkflowApproval(
                              context: context,
                              isApproved: false,
                              moduleName: 'REFUND PAYMENT LEDGER APPROVAL',
                              id: refundData.bookingId,
                              subId: refundData.refundedAmountLedgerId,
                              projectId: refundData.projectId,
                              remark: onReject.trim(),
                            );
                      },
                      onThirdTap: () async {
                        final approvalLogHistoryList = await context
                            .read<UtilsCubit>()
                            .getApprovalLogHistory(
                              context: context,
                              projectId: refundData.projectId,
                              id: refundData.bookingId,
                              subId: refundData.refundedAmountLedgerId,
                              moduleName: 'REFUND PAYMENT LEDGER APPROVAL',
                            );
                        if (context.mounted) {
                          goRouter.pushNamed(
                            AppRoutes.approvalLogHistory,
                            queryParameters: {
                              "title": Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  "REFUND PAYMENT LEDGER APPROVAL",
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
                      popupTitle: "REFUND PAYMENT LEDGER APPROVAL",
                    ),
                    verticalSpacing(),
                    Text("Payment Details", style: AppTextStyle.ts16SB()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Payment Mode",
                            value: refundData.paymentMode,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Refunded Amount",
                            value: refundData.refundedAmount.toIndianCurrency(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Transaction / Cheque / Demand Draft",
                            value:
                                refundData.transactionChequeDemandDraftNumber,
                            customValueWidget: DocumentPreviewText(
                              title: "Transaction / Cheque / Demand Draft",
                              text:
                                  refundData.transactionChequeDemandDraftNumber,
                              fileUrl:
                                  refundData.transactionChequeDemandDraftUrl,
                            ),
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Refunded Amount",
                            value: refundData.refundedAmount.toIndianCurrency(),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Text(
                      "Developers Bank Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Project Bank name",
                            value: refundData.projectBankName,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Account Number",
                            value: refundData.projectAccountNumber,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "IFSC Code",
                            value: refundData.projectIfscCode,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Nature Of Account",
                            value: refundData.projectNatureOfAccount,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Account Type",
                            value: refundData.projectAcType,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Text(
                      "Customers Bank Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Account Holder Name",
                            value: refundData.accountHolderName,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Bank Name",
                            value: refundData.bankName,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Account Number",
                            value: refundData.accountNumber,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "IFSC Code",
                            value: refundData.ifscCode,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.3,
                      color: AppColor.black.withValues(alpha: 0.3),
                    ),
                    Text("Action Details", style: AppTextStyle.ts16SB()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Created By",
                            value: refundData.createdBy,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Created Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              refundData.createdDate,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Modified By",
                            value: refundData.modifiedBy,
                          ),
                        ),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Modified Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              refundData.modifiedDate,
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
        );
      },
    );
  }
}
