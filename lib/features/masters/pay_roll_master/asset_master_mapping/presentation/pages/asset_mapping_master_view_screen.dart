import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class AssetMappingMasterViewScreen extends StatelessWidget {
  final AssetMappingModel assetMapping;
  const AssetMappingMasterViewScreen({super.key, required this.assetMapping});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Asset Mapping",
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
                    Text("Asset Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Asset Name",
                          value: assetMapping.assetName,
                        ),
                        buildColumnTitleValue(
                          title: "Asset Code",
                          value: assetMapping.assetCode,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Asset Type",
                          value: assetMapping.assetType,
                        ),
                        buildColumnTitleValue(
                          title: "Asset Brand",
                          value: assetMapping.assetBrand,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Asset Model",
                          value: assetMapping.assetModel,
                        ),
                        buildColumnTitleValue(
                          title: "Serial Number",
                          value: assetMapping.serialNumber,
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
                    Text("Assignee Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Employee Name",
                          value: assetMapping.employeeName,
                        ),
                        buildColumnTitleValue(
                          title: "Branch",
                          value: assetMapping.branch,
                        ),

                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Department",
                          value: assetMapping.department,
                        ),
                        buildColumnTitleValue(
                          title: "Designation",
                          value: assetMapping.designation,
                        ),

                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Assigned Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            assetMapping.assignedDate,
                          ),
                        ),
                        buildColumnTitleValue(
                          title: "Return Date",
                          value:
                              assetMapping.returnDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    assetMapping.returnDate!,
                                  )
                                  : '-',
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Condition On Issue",
                          value: assetMapping.conditionOnIssue,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Remark",
                                style: AppTextStyle.ts14M(color: AppColor.grey),
                              ),
                              verticalSpacing(height: 4),
                              Text(
                                assetMapping.remarks,
                                style: AppTextStyle.ts14M(),
                              ),
                            ],
                          ),
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
                    Text("Purchase Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Purchase Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            assetMapping.purchaseDate,
                          ),
                        ),
                        buildColumnTitleValue(
                          title: "Warranty Expiry Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            assetMapping.warrantyExpiryDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Supplier Name",
                          value: assetMapping.supplierName,
                        ),
                        buildColumnTitleValue(
                          title: "Asset Cost",
                          value: "₹ ${assetMapping.assetCost}",
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
                    Text("Return Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Return Date",
                          value:assetMapping.returnDate!=null? formatDateTimeAsDDMMMYYYY(
                            assetMapping.returnDate!,
                          ):"-",
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Condition At Return",
                          value: assetMapping.conditionOnReturn,
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
                          value: assetMapping.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            assetMapping.createdDate,
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
                              assetMapping.modifiedBy.isEmpty
                                  ? "-"
                                  : assetMapping.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              assetMapping.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    assetMapping.modifiedDate!,
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
