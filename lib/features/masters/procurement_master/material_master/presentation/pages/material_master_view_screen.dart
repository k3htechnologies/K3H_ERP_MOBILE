import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';

class MaterialMasterViewScreen extends StatelessWidget {
  final MaterialMasterModel material;
  const MaterialMasterViewScreen({super.key, required this.material});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Material Master",
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
                        title: "Material Code",
                        value: material.materialCode,
                      ),
                      buildColumnTitleValue(
                        title: "Material Name",
                        value: material.materialName,
                      ),
                    ],
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
                        value: material.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDate(material.createdDate),
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
                            (material.modifiedBy.isNotEmpty)
                                ? material.modifiedBy
                                : "-",
                      ),
                      buildColumnTitleValue(
                        title: "Modified Date",
                        value: formatDate(material.modifiedDate),
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
