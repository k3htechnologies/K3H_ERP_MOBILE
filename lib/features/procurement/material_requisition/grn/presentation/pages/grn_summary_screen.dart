import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class GrnSummaryScreen extends StatefulWidget {
  const GrnSummaryScreen({super.key});

  @override
  State<GrnSummaryScreen> createState() => _GrnSummaryScreenState();
}

class _GrnSummaryScreenState extends State<GrnSummaryScreen> {
  late GrnCubit _grnCubit;
  late MaterialRequisitionCubit _materialRequisitionCubit;
  final ValueNotifier<List<GRNModel>?> grnList = ValueNotifier(null);
  @override
  void initState() {
    super.initState();
    _grnCubit = context.read<GrnCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "GRN Summary",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<GrnCubit, GrnState>(
        builder: (context, state) {
          if (state.isLoading ?? true) {
            return Expanded(child: Center(child: CircularProgressIndicator()));
          }
          return ValueListenableBuilder(
            valueListenable: grnList,
            builder: (context, value, child) {
              if (value == null) {
                return SizedBox.shrink();
              }
              return ListView.builder(
                itemCount: grnList.value!.length,
                padding: EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final grn = grnList.value![index];
                  return Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          children: [
                            buildColumnTitleValue(
                              title: "Date",
                              value: formatDateTimeAsDDMMMYYYY(grn.createdDate),
                            ),
                            buildColumnTitleValue(
                              title: "Vehicle No.",
                              value: grn.vehicleNumber,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            buildColumnTitleValue(
                              title: "Challan No.",
                              value: grn.challanNumber,
                            ),
                            buildColumnTitleValue(
                              title: "Challan Document",
                              value: grn.challanNumber,
                              customValueWidget: CustomButton.documentOutline(
                                onPressed: () {
                                  if (grn.uploadChallanUrl.isNotEmpty) {
                                    showFilePreviewDialog(
                                      context,
                                      grn.uploadChallanUrl.split(","),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        ...grn.materialRequisitionDetailGrnData.map((m) {
                          return _materialCard(m);
                        }),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _materialCard(MaterialRequisitionDetailGrnDatum grnMaterial) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.grey10,
        border: Border.all(color: AppColor.grey10),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          buildColumnTitleValue(
            title: "Material",
            value: grnMaterial.materialName,
          ),
          buildColumnTitleValue(
            title: "Sub-Material",
            value: grnMaterial.subMaterialName,
          ),
          buildColumnTitleValue(
            title: "Quantity",
            value: addCommasToInteger(
              grnMaterial.totalReceivedMaterialQuantity,
              withoutSign: true,
            ),
          ),
        ],
      ),
    );
  }
}
