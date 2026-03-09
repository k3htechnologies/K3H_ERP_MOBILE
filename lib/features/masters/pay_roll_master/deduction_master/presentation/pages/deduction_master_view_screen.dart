import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class DeductionMasterViewScreen extends StatelessWidget {
  final DeductionMasterModel deductionMasterModel;

  const DeductionMasterViewScreen({
    super.key,
    required this.deductionMasterModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Deduction Master",
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
                    Text("Basic Details", style: AppTextStyle.ts16SB()),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Name",
                          value: deductionMasterModel.name,
                        ),
                        buildColumnTitleValue(
                          title: "Type",
                          value: deductionMasterModel.type,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Gender",
                          value: deductionMasterModel.gender,
                        ),
                        buildColumnTitleValue(
                          title: "Branch Name",
                          value: deductionMasterModel.branchName,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "State Name",
                          value: deductionMasterModel.stateName,
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
                    Text("Deduction Details", style: AppTextStyle.ts16SB()),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Applicable",
                          value: deductionMasterModel.applicable,
                        ),
                        buildColumnTitleValue(
                          title: "Value",
                          value: deductionMasterModel.value.toStringAsFixed(0),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Min Salary (₹)",
                          value: deductionMasterModel.minSalary.toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Max Salary (₹)",
                          value: deductionMasterModel.maxSalary.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionCardWidget(
                createdBy: deductionMasterModel.createdBy,
                createdDate: deductionMasterModel.createdDate,
                modifiedBy: deductionMasterModel.modifiedBy,
                modifiedDate: deductionMasterModel.modifiedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
