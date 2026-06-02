// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
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
  late InvoiceCubit _invoiceCubit;
  late AuthorizationModel _addInvoiceAuthorizationModel,
      _makePaymentAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _grnCubit = context.read<GrnCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _invoiceCubit = context.read<InvoiceCubit>();
    _addInvoiceAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addInvoiceTab]!;
    _makePaymentAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.makePayments]!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initOverview();
    });
  }

  Future<void> initOverview() async {
    final overview =
        _materialRequisitionCubit.state.materialRequisitionOverview;

    if (overview == null) return;

    await _grnCubit.getAllGRNList(
      context: context,
      materialRequisitionId: overview.materialRequisitionId,
      uniqueKey: overview.uniquekey,
      projectId: overview.projectId,
    );

    await _invoiceCubit.getInvoice(
      context: context,
      projectId: overview.projectId,
      materialRequisitionId: overview.materialRequisitionId,
      uniqueKey: overview.uniquekey,
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

          Expanded(
            child: BlocBuilder<GrnCubit, GrnState>(
              builder: (context, grnState) {
                return BlocBuilder<InvoiceCubit, InvoiceState>(
                  builder: (context, invoiceState) {
                    return ListView.builder(
                      itemCount: grnState.allGRNList.length,
                      itemBuilder: (context, index) {
                        final grn = grnState.allGRNList[index];
                        final grnId = grn.materialRequisitionGrnId;
                        final invoice =
                            invoiceState.invoiceList
                                .where(
                                  (e) => e.materialRequisitionGrnId == grnId,
                                )
                                .firstOrNull;

                        final hasInvoice = grn.isInvoiceCreated ?? false;

                        final paidTillDate =
                            invoice?.invoiceAmountPaidTillDate ?? 0;

                        final totalAmount = invoice?.invoiceAmount ?? 0;

                        final hasPayment =
                            grn.isInvoicePaymentCompleted ?? false;

                        final isFullyPaid =
                            hasPayment && paidTillDate >= totalAmount;

                        final paymentType =
                            !hasPayment
                                ? ""
                                : isFullyPaid
                                ? "Paid"
                                : "Partially Paid";

                        final showStatus = hasPayment;

                        final buttonText =
                            !hasInvoice
                                ? "Create Invoice"
                                : !hasPayment
                                ? "Make Payment"
                                : "View Payment";
                        final disable =
                            !hasInvoice
                                ? !_addInvoiceAuthorizationModel.isAction
                                : !hasPayment
                                ? !_makePaymentAuthorizationModel.isAction
                                : false;
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
                              showStatus
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Status",
                                              style: AppTextStyle.ts14R(
                                                color: AppColor.black
                                                    .withValues(alpha: 0.5),
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
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color:
                                                    hasPayment
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
                                                  paymentType,
                                                  style: AppTextStyle.ts12M(
                                                    color:
                                                        hasPayment
                                                            ? AppColor.green
                                                            : AppColor.orange,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpacing(height: 6.0),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    text: buttonText,
                                    isDisable: disable,
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
                                      if (hasPayment) {
                                        goRouter.pushNamed(
                                          AppRoutes.viewPayment,
                                          extra: {
                                            'systemGeneratedCode':
                                                widget.systemGeneratedCode,
                                            'invoiceNumber':
                                                invoiceState
                                                    .invoiceList
                                                    .first
                                                    .invoiceNumber,
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
                      },
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
