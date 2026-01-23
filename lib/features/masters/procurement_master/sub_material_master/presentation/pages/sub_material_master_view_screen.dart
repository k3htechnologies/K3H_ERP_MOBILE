import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class SubMaterialMasterViewScreen extends StatelessWidget {
  final SubMaterialMasterModel subMaterial;

  const SubMaterialMasterViewScreen({super.key, required this.subMaterial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Sub Material Master",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sub Material Master Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Material Name",
                          value: subMaterial.materialName,
                        ),
                        buildColumnTitleValue(
                          title: "Sub Material Name",
                          value: subMaterial.subMaterialName,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "UOM",
                          value: subMaterial.uom,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Action Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: subMaterial.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            subMaterial.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value:
                              subMaterial.modifiedBy.isEmpty
                                  ? "-"
                                  : subMaterial.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              subMaterial.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    subMaterial.modifiedDate!,
                                  )
                                  : "-",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
