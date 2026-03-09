import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

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
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Material Details", style: AppTextStyle.ts16SB()),
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
              ),
              actionCardWidget(
                createdBy: material.createdBy,
                createdDate: material.createdDate,
                modifiedBy: material.modifiedBy,
                modifiedDate: material.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
