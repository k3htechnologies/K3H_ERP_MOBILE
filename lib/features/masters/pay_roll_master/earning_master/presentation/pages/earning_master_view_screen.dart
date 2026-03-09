import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class EarningMasterViewScreen extends StatelessWidget {
  final EarningMasterModel earningMasterModel;

  const EarningMasterViewScreen({super.key, required this.earningMasterModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Earning Master",
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
                    Text("Earning Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Earning Name",
                          value: earningMasterModel.name,
                        ),
                        buildColumnTitleValue(
                          title: "Type",
                          value: earningMasterModel.type,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Applicable",
                          value: earningMasterModel.applicable,
                        ),
                        buildColumnTitleValue(
                          title: "Value",
                          value: earningMasterModel.value.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Min Salary (₹)",
                          value: earningMasterModel.minSalary.toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Max Salary (₹)",
                          value: earningMasterModel.maxSalary.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Branch Name",
                          value: earningMasterModel.branchName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionCardWidget(
                createdBy: earningMasterModel.createdBy,
                createdDate: earningMasterModel.createdDate,
                modifiedBy: earningMasterModel.modifiedBy,
                modifiedDate: earningMasterModel.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
