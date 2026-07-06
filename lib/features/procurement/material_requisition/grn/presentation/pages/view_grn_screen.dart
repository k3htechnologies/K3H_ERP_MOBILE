import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ViewGrnScreen extends StatefulWidget {
  final GRNModel grnModel;
  const ViewGrnScreen({super.key, required this.grnModel});

  @override
  State<ViewGrnScreen> createState() => _ViewGrnScreenState();
}

class _ViewGrnScreenState extends State<ViewGrnScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final grn = widget.grnModel;
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Goods Receipt Note",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
              builder: (context, state) {
                return Text(
                  state.materialRequisitionOverview?.systemGeneratedCode ?? "",
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                );
              },
            ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(12),
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
            ),
          ],
        ),
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
            value: grnMaterial.totalReceivedMaterialQuantity.addCommas(),
          ),
        ],
      ),
    );
  }
}
