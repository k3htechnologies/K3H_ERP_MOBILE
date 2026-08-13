import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/refund_amount_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
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
  late AuthorizationModel _modifiedRequestsAuthorization;
  @override
  void initState() {
    super.initState();
    _modifiedRequestsAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.modificationRequest] ??
        AuthorizationModel();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _requestManagementCubit.getRefundAmountPaymentLedger(
      context,
      widget.booking.projectId,
      widget.booking.bookingId,
    );
  }

  Future<void> _showPopupToDeleteRefundPaymentLedger(
    BuildContext context,
    RefundedAmountLedgerModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Refunded Payment Ledger?',
      'Deleting this Refunded Payment Ledger will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _requestManagementCubit.deleteRefundedAmountLedger(
        context: context,
        refundModel: obj,
        index: index,
      );
    }
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
            child: noDataWidget(
              message: "No refunded amount details history found",
            ),
          );
        }
        final refundDataDetails = state.refundAmountLedgerList.first;

        final approvalStatus = refundDataDetails.approvalStatus;

        final isAlreadyApproved = approvalStatus.toLowerCase() == "approved";

        final isRejected = approvalStatus.toLowerCase() == "rejected";
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                itemCount: state.refundAmountLedgerList.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final refundDataDetailsDetails =
                      state.refundAmountLedgerList[index];
                  final approvalStatus =
                      refundDataDetailsDetails.approvalStatus
                          .trim()
                          .toLowerCase();

                  final isEditDeleteDisabled =
                      approvalStatus == "approved" ||
                      approvalStatus == "partial approved";
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.0),
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
                                      refundDataDetailsDetails.refundedAmount
                                          .toIndianCurrency(),
                                ),
                                verticalSpacing(),
                                buildColumnTitleValueNormal(
                                  title: "Payment Mode",
                                  value: refundDataDetailsDetails.paymentMode,
                                ),
                              ],
                            ),
                            if (_modifiedRequestsAuthorization.isAction)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomIconButton.edit(
                                    onPressed: () async {
                                      final result = await goRouter.pushNamed(
                                        AppRoutes.modifiedRequestsMakePayment,
                                        extra: {
                                          "uniquekey":
                                              refundDataDetailsDetails
                                                  .uniquekey,
                                          "bookingId":
                                              refundDataDetailsDetails
                                                  .bookingId,
                                          "projectId":
                                              refundDataDetailsDetails
                                                  .projectId,
                                          "refundData":
                                              refundDataDetailsDetails,
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
                                    isDisabled: isEditDeleteDisabled,
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton.delete(
                                    onPressed: () {
                                      _showPopupToDeleteRefundPaymentLedger(
                                        context,
                                        refundDataDetailsDetails,
                                        index,
                                      );
                                    },
                                    isDisabled: isEditDeleteDisabled,
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
                          showApproval: refundDataDetailsDetails.isApproval,
                          isActionAlreadyPerformed:
                              isAlreadyApproved || isRejected,
                          actionTitle:
                              refundDataDetailsDetails.approvalStatus.isEmpty
                                  ? "Pending"
                                  : refundDataDetailsDetails.approvalStatus,
                          subTitle:
                              "${widget.booking.applicantName} > ${widget.booking.flat} > ${refundDataDetailsDetails.refundedAmount.toIndianCurrency()}",
                          approveIcon: Icons.check,
                          onApprove: (onApprove) async {
                            final isSuccess = await context
                                .read<UtilsCubit>()
                                .updateModulesWorkflowApproval(
                                  context: context,
                                  moduleName: 'REFUND PAYMENT LEDGER APPROVAL',
                                  id: refundDataDetails.bookingId,
                                  subId:
                                      refundDataDetails.refundedAmountLedgerId,
                                  projectId: refundDataDetails.projectId,
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
                                  id: refundDataDetails.bookingId,
                                  subId:
                                      refundDataDetails.refundedAmountLedgerId,
                                  projectId: refundDataDetails.projectId,
                                  remark: onReject.trim(),
                                );
                          },
                          onThirdTap: () async {
                            final approvalLogHistoryList = await context
                                .read<UtilsCubit>()
                                .getApprovalLogHistory(
                                  context: context,
                                  projectId: refundDataDetails.projectId,
                                  id: refundDataDetails.bookingId,
                                  subId:
                                      refundDataDetails.refundedAmountLedgerId,
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
                        if (_modifiedRequestsAuthorization.isAction)
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
                                value: refundDataDetailsDetails.paymentMode,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Refunded Amount",
                                value:
                                    refundDataDetailsDetails.refundedAmount
                                        .toIndianCurrency(),
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
                                    refundDataDetailsDetails
                                        .transactionChequeDemandDraftNumber,
                                customValueWidget: DocumentPreviewText(
                                  title: "Transaction / Cheque / Demand Draft",
                                  text:
                                      refundDataDetailsDetails
                                          .transactionChequeDemandDraftNumber,
                                  fileUrl:
                                      refundDataDetailsDetails
                                          .transactionChequeDemandDraftUrl,
                                ),
                              ),
                            ),

                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title:
                                    "Transaction / Cheque / Demand Draft Date",
                                value: formatDateTimeAsDDMMMYYYY(
                                  refundDataDetailsDetails
                                      .transactionChequeDemandDraftDate,
                                ),
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
                                value: refundDataDetailsDetails.projectBankName,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Account Number",
                                value:
                                    refundDataDetailsDetails
                                        .projectAccountNumber,
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
                                value: refundDataDetailsDetails.projectIfscCode,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Nature Of Account",
                                value:
                                    refundDataDetailsDetails
                                        .projectNatureOfAccount,
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
                                value: refundDataDetails.projectAcType,
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
                                value: refundDataDetails.accountHolderName,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Bank Name",
                                value: refundDataDetails.bankName,
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
                                value: refundDataDetails.accountNumber,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "IFSC Code",
                                value: refundDataDetails.ifscCode,
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
                                value: refundDataDetails.createdBy,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Created Date",
                                value: formatDateTimeAsDDMMMYYYY(
                                  refundDataDetails.createdDate,
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
                                value: refundDataDetails.modifiedBy,
                              ),
                            ),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Modified Date",
                                value: formatDateTimeAsDDMMMYYYY(
                                  refundDataDetails.modifiedDate,
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
        );
      },
    );
  }
}
