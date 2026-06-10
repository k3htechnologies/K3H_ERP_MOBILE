import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class GRNScreen extends StatefulWidget {
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  const GRNScreen({
    super.key,
    required this.projectId,
    required this.materialRequisitionId,
    required this.uniquekey,
  });

  @override
  State<GRNScreen> createState() => _GRNScreenState();
}

class _GRNScreenState extends State<GRNScreen> {
  late GrnCubit _grnCubit;

  @override
  void initState() {
    super.initState();
    _grnCubit = context.read<GrnCubit>();
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
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              );
            },
          ),
          verticalSpacing(),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                text: "View Summary",
                onPressed: () async {
                  await goRouter.pushNamed(
                    AppRoutes.grnSummary,
                    queryParameters: {
                      "materialRequisitionId": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          widget.materialRequisitionId.toString(),
                        ),
                      ),
                      "projectId": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          widget.projectId.toString(),
                        ),
                      ),
                      "uniquekey": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(widget.uniquekey),
                      ),
                    },
                  );
                },
                backgroundColor: AppColor.lightBlue,
                textColor: AppColor.primary,
              ),
              CustomButton(
                leading: Icon(Icons.add, color: AppColor.white, size: 16),
                text: "Add GRN",
                onPressed: () async {
                  await _grnCubit.clearMaterialList();
                  await goRouter.pushNamed(
                    AppRoutes.addGrn,
                    queryParameters: {
                      "materialRequisitionId": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          widget.materialRequisitionId.toString(),
                        ),
                      ),
                      "projectId": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          widget.projectId.toString(),
                        ),
                      ),
                      "uniquekey": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(widget.uniquekey),
                      ),
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: BlocBuilder<GrnCubit, GrnState>(
              builder: (context, state) {
                if (state.isLoading ?? true) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredGRNList.isEmpty) {
                  return Center(child: noDataWidget());
                }

                return ListView.builder(
                  itemCount: state.filteredGRNList.length,
                  itemBuilder: (context, index) {
                    final grn = state.filteredGRNList[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  goRouter.pushNamed(
                                    AppRoutes.viewGrn,
                                    queryParameters: {
                                      "grn": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(grn.toJson()),
                                        ),
                                      ),
                                    },
                                  );
                                },
                                child: Text(
                                  grn.challanNumber,
                                  style: AppTextStyle.ts14SB(
                                    color: AppColor.primary,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.primary,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 10.w,
                                children: [
                                  CustomIconButton.edit(
                                    isDisabled:
                                        (grn.isInvoicePaymentCompleted ??
                                            false),
                                    onPressed: () async {
                                      goRouter.pushNamed(
                                        AppRoutes.addGrn,
                                        queryParameters: {
                                          "grnMaterial":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(grn.toJson()),
                                                ),
                                              ),
                                          'index': index.toString(),
                                          "materialRequisitionId":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  widget.materialRequisitionId
                                                      .toString(),
                                                ),
                                              ),
                                          "projectId": Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              widget.projectId.toString(),
                                            ),
                                          ),
                                          "uniquekey": Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              widget.uniquekey,
                                            ),
                                          ),
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          verticalSpacing(height: 5),

                          buildRowTitleValue(
                            title: "Vehicle Number",
                            value: grn.vehicleNumber,
                          ),
                          buildRowTitleValue(
                            title: "Created By",
                            value: grn.createdBy,
                          ),
                          buildRowTitleValue(
                            title: "Created Date",
                            value: formatDate(grn.createdDate),
                          ),
                        ],
                      ),
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
}
