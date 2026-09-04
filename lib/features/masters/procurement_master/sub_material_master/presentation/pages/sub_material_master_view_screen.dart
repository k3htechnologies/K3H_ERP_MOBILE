import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';

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
            children: [
              SectionCard(
                title: "Basic Details",
                children: [
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
                      buildColumnTitleValue(
                        title: "Lead Time (Days)",
                        value: subMaterial.leadTimeInDays.toString(),
                      ),
                    ],
                  ),
                  buildColumnTitleValue(
                    title: "Is Tolerant",
                    value: subMaterial.isTolerant ? "Yes" : "No",
                    removeExpanded: true,
                  ),
                ],
              ),
              SectionCard(
                title: "Action Details",
                titleTextColor: AppColor.black,
                headerBackgroundColor: AppColor.grey20,
                childSpacing: 0,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      buildColumnTitleValue(
                        title: "Created By",
                        value: subMaterial.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDate(subMaterial.createdDate),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      buildColumnTitleValue(
                        title: "Modified By",
                        value:
                            (subMaterial.modifiedBy.isNotEmpty)
                                ? subMaterial.modifiedBy
                                : "-",
                      ),
                      buildColumnTitleValue(
                        title: "Modified Date",
                        value: formatDate(subMaterial.modifiedDate),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
