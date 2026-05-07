import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
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
            builder: (context, state) {
              if (state.isLoading ?? true) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.allGRNList.isEmpty) {
                return const Text("No GRN found");
              }

              return Column(
                children:
                    state.allGRNList.map((grn) {
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    goRouter.pushNamed(
                                      AppRoutes.addInvoice,
                                      extra: {
                                        'systemGeneratedCode':
                                            widget.systemGeneratedCode,
                                        "grn": grn,
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Text(
                                      "Create Invoice",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.white,
                                      ),
                                    ),
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
