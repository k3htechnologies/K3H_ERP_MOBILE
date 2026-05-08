import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

import '../../data/model/material_requisition.model.dart';

class CopyMaterialRequisitionScreen extends StatefulWidget {
  final MaterialRequisitionModel materialRequisitionModel;
  const CopyMaterialRequisitionScreen({
    super.key,
    required this.materialRequisitionModel,
  });

  @override
  State<CopyMaterialRequisitionScreen> createState() =>
      _CopyMaterialRequisitionScreenState();
}

class _CopyMaterialRequisitionScreenState
    extends State<CopyMaterialRequisitionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Copy Material Requisition",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.materialRequisitionModel.systemGeneratedCode,
              style: AppTextStyle.ts16SB(color: AppColor.primary),
            ),
            ListView.builder(
              itemCount:
                  widget
                      .materialRequisitionModel
                      .materialRequisitionDetailData
                      .length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: commonCardDecoration(),
                  child: Column(
                    children: [
                      buildRowTitleValue(title: "Material", value: "value"),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Save", onPressed: () {}),
        ),
      ),
    );
  }
}
