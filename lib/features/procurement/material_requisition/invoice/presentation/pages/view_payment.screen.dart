import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPaymentScreen extends StatefulWidget {
  final String systemgeneratedCode;
  final String invoiceNumber;
  const ViewPaymentScreen({
    super.key,
    required this.systemgeneratedCode,
    required this.invoiceNumber,
  });

  @override
  State<ViewPaymentScreen> createState() => _ViewPaymentScreenState();
}

class _ViewPaymentScreenState extends State<ViewPaymentScreen> {
  late InvoiceCubit _invoiceCubit;
  late MaterialRequisitionCubit _materialRequisitionCubit;

  @override
  void initState() {
    super.initState();

    _invoiceCubit = context.read<InvoiceCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final overview =
          _materialRequisitionCubit.state.materialRequisitionOverview;

      if (overview == null) return;

      if (_invoiceCubit.state.invoiceList.isNotEmpty) {
        final invoiceId =
            _invoiceCubit.state.invoiceList.first.materialRequisitionInvoiceId;

        await _invoiceCubit.getPayment(
          context: context,
          projectId: overview.projectId,
          materialRequisitionInvoiceId: invoiceId,
          materialRequisitionId: overview.materialRequisitionId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Payment",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.systemgeneratedCode,
                    style: AppTextStyle.ts16M(color: AppColor.primary),
                  ),
                  TextSpan(text: " > ", style: AppTextStyle.ts16M()),
                  TextSpan(
                    text: widget.invoiceNumber,
                    style: AppTextStyle.ts16M(),
                  ),
                ],
              ),
            ),
            verticalSpacing(),
            BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state.isLoading ?? false) {
                  return Center(child: loader());
                }

                if (state.paymentList.isEmpty) {
                  return const Center(child: Text("No Payment Found"));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      state.paymentList.map((payment) {
                        final paymentType = payment.paymentType.toLowerCase();

                        final isPaid = paymentType == "full";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10.0,
                            children: [
                              _buildRow(
                                "Payment Amount",
                                "₹${payment.amountPaid}",
                              ),
                              _buildRow("Payment Mode", payment.paymentMode),
                              _buildRow("Bank Name", payment.bankName),
                              _buildRow("Account No.", payment.accountNumber),
                              _buildRow(
                                "IFSC Code",
                                payment.ifscCode.isEmpty
                                    ? '-'
                                    : payment.ifscCode,
                              ),
                              _buildRow("Type", payment.paymentType),

                              _buildRow(
                                "Transaction No.",
                                payment.transactionNumber,
                              ),
                              _buildRow(
                                "TDS Amount",
                                payment.tdsAmount.toString(),
                              ),
                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "Transaction Receipt",
                                    value: payment.transactionReceiptUrl,
                                    customValueWidget:
                                        CustomButton.documentOutline(
                                          onPressed: () {
                                            if (payment
                                                .transactionReceiptUrl
                                                .isNotEmpty) {
                                              showFilePreviewDialog(
                                                context,
                                                payment.transactionReceiptUrl
                                                    .split(","),
                                              );
                                            }
                                          },
                                        ),
                                  ),

                                  horizontalSpacing(),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Status",
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),

                                        verticalSpacing(height: 6),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color:
                                                isPaid
                                                    ? AppColor.green20
                                                        .withValues(alpha: 0.10)
                                                    : AppColor.orange
                                                        .withValues(
                                                          alpha: 0.10,
                                                        ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              isPaid
                                                  ? "Paid"
                                                  : "Partially Paid",
                                              style: AppTextStyle.ts12M(
                                                color:
                                                    isPaid
                                                        ? AppColor.green
                                                        : AppColor.orange,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {Color? valueColor}) {
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
              style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
            ),
          ),
        ],
      ),
    );
  }
}
