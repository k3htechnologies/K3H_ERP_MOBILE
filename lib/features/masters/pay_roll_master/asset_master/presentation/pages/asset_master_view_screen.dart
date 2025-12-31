import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AssetMasterViewScreen extends StatelessWidget {
  final AssetMasterModel assetMaster;
  const AssetMasterViewScreen({super.key, required this.assetMaster});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(screenTitle: "Asset Master", authorization: AuthorizationModel()),
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
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
                      _buildColumnTitleValue(title: "Asset Name", value: assetMaster.assetName),
                      _buildColumnTitleValue(title: "Asset Code", value: assetMaster.assetCode),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColumnTitleValue(title: "Asset Type", value: assetMaster.assetType),
                      _buildColumnTitleValue(title: "Asset Brand", value: assetMaster.assetBrand),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColumnTitleValue(title: "Asset Model", value: assetMaster.assetModel),
                      _buildColumnTitleValue(title: "Serial Number", value: assetMaster.serialNumber),
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
                      _buildColumnTitleValue(title: "Purchase Date", value: formatDateTimeAsDDMMMYYYY(assetMaster.purchaseDate)),
                      _buildColumnTitleValue(title: "Warranty Expiry Date", value:assetMaster.warrantyExpiryDate!=null? formatDateTimeAsDDMMMYYYY(assetMaster.warrantyExpiryDate!):"-"),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColumnTitleValue(title: "Supplier Name", value: assetMaster.supplierName),
                      _buildColumnTitleValue(title: "Asset Cost", value: "₹ ${assetMaster.assetCost}"),
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
                      _buildColumnTitleValue(title: "Created By", value: assetMaster.createdBy),
                      _buildColumnTitleValue(title: "Created Date", value: formatDateTimeAsDDMMMYYYY(assetMaster.createdDate)),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColumnTitleValue(title: "Modified By", value: assetMaster.modifiedBy.isEmpty?"-":assetMaster.modifiedBy),
                      _buildColumnTitleValue(title: "Modified Date", value:assetMaster.modifiedDate!=null? formatDateTimeAsDDMMMYYYY(assetMaster.modifiedDate!):"-"),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget _buildColumnTitleValue({required String title, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }

}
