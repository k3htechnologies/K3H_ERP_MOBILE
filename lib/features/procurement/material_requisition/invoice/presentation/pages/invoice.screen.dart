import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InvoiceScreen extends StatefulWidget {
  final String systemGeneratedCode;
  final GRNModel? grn;
  const InvoiceScreen({super.key, required this.systemGeneratedCode, this.grn});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  // CUBIT
  late GrnCubit _grnCubit;
  late MaterialRequisitionCubit _materialRequisitionCubit;

  @override
  void initState() {
    super.initState();
    _grnCubit = context.read<GrnCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initOverview();
    });
  }

  Future initOverview() async {
    await _grnCubit.getAllGRNList(
      context: context,
      materialRequisitionId:
          _materialRequisitionCubit
              .state
              .materialRequisitionOverview!
              .materialRequisitionId,
      uniqueKey:
          _materialRequisitionCubit
              .state
              .materialRequisitionOverview!
              .uniquekey,
      projectId:
          _materialRequisitionCubit
              .state
              .materialRequisitionOverview!
              .projectId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(height: 5),
          BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
            builder: (context, state) {
              return Text(
                state.materialRequisitionOverview?.systemGeneratedCode ?? "",
                style: AppTextStyle.ts16M(color: AppColor.primary),
              );
            },
          ),
          verticalSpacing(),

          BlocBuilder<GrnCubit, GrnState>(
            builder: (context, grnState) {
              if (grnState.isLoading ?? true) {
                return const Center(child: CircularProgressIndicator());
              }

              if (grnState.allGRNList.isEmpty) {
                return const Text("No GRN found");
              }
              return BlocBuilder<InvoiceCubit, InvoiceState>(
                builder: (context, invoiceState) {
                  return Column(
                    children:
                        grnState.allGRNList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final grn = entry.value;
                          final hasInvoice = invoiceState.invoiceList.any(
                            (invoice) =>
                                invoice.materialRequisitionId ==
                                grn.materialRequisitionId,
                          );
                          final invoice =
                              index < invoiceState.invoiceList.length
                                  ? invoiceState.invoiceList[index]
                                  : null;

                          final payment =
                              invoiceState.paymentList.isNotEmpty
                                  ? invoiceState.paymentList.first
                                  : null;

                          final isPaid =
                              payment?.paymentType.toLowerCase() == "full";

                          final isPartiallyPaid =
                              payment?.paymentType.toLowerCase() == "partial";
                          final buttonText =
                              !hasInvoice
                                  ? "Create Invoice"
                                  : isPaid
                                  ? "View Payment"
                                  : "Make Payment";
                          return Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRow(
                                  "Date",
                                  formatDateTimeAsDDMMMYYYY(grn.createdDate),
                                ),
                                _buildRow("Vehicle No", grn.vehicleNumber),
                                _buildRow("Challan No", grn.challanNumber),
                                verticalSpacing(),
                                isPaid || isPartiallyPaid
                                    ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Status",
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          ":   ",
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              color:
                                                  isPaid
                                                      ? AppColor.green20
                                                          .withValues(
                                                            alpha: 0.10,
                                                          )
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
                                        ),
                                      ],
                                    )
                                    : SizedBox.shrink(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomButton(
                                      text: buttonText,
                                      onPressed: () {
                                        if (!hasInvoice) {
                                          goRouter.pushNamed(
                                            AppRoutes.addInvoice,
                                            extra: {
                                              'systemGeneratedCode':
                                                  widget.systemGeneratedCode,
                                              "grn": grn,
                                            },
                                          );
                                          return;
                                        }
                                        if (isPaid) {
                                          goRouter.pushNamed(
                                            AppRoutes.viewPayment,
                                            extra: {
                                              'systemGeneratedCode':
                                                  widget.systemGeneratedCode,
                                            },
                                          );
                                          return;
                                        }
                                        goRouter.pushNamed(
                                          AppRoutes.makePayment,
                                          extra: {
                                            'systemGeneratedCode':
                                                widget.systemGeneratedCode,
                                            "grn": grn,
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              );
            },
          ),
        ],
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
