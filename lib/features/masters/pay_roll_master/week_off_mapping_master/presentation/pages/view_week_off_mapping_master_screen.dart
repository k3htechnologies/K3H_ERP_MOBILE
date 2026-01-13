import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewWeekOffMappingMasterScreen extends StatelessWidget {
  final WeekOffMappingModel weekOffMappingMasterModel;
  const ViewWeekOffMappingMasterScreen({
    super.key,
    required this.weekOffMappingMasterModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Week Off Mapping",
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
                      "Week Off Mapping Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Week Off Policy Name",
                          value: weekOffMappingMasterModel.weekOffPolicyName,
                        ),
                        _buildColumnTitleValue(
                          title: "Week Off Policy Code",
                          value: weekOffMappingMasterModel.weekOffPolicyCode,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Department Name",
                          value:
                              weekOffMappingMasterModel
                                      .departmentName
                                      .isNotEmpty
                                  ? weekOffMappingMasterModel.departmentName
                                  : '-',
                        ),
                        _buildColumnTitleValue(
                          title: "Employee Name",
                          value:
                              weekOffMappingMasterModel.employeeName.isNotEmpty
                                  ? weekOffMappingMasterModel.employeeName
                                  : '-',
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Week Days",
                          value: weekOffMappingMasterModel.weekDays.toString(),
                        ),
                        _buildColumnTitleValue(
                          title: "Week Days Starts On",
                          value: weekOffMappingMasterModel.weekDaysStartsOn,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Weekly Off",
                          value: weekOffMappingMasterModel.weeklyOff,
                        ),
                        _buildColumnTitleValue(
                          title: "Weekly Off2",
                          value: weekOffMappingMasterModel.weeklyOff2,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Weekly Off2 Type",
                          value: weekOffMappingMasterModel.weeklyOff2Type,
                        ),
                        _buildColumnTitleValue(
                          title: "Not Applicable For Months",
                          value:
                              weekOffMappingMasterModel.notApplicableForMonths,
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
                        _buildColumnTitleValue(
                          title: "Created By",
                          value: weekOffMappingMasterModel.createdBy,
                        ),
                        _buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            weekOffMappingMasterModel.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Modified By",
                          value: weekOffMappingMasterModel.modifiedBy,
                        ),
                        _buildColumnTitleValue(
                          title: "Modified Date",
                          value:
                              weekOffMappingMasterModel.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    weekOffMappingMasterModel.modifiedDate!,
                                  )
                                  : '',
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

  Widget _buildColumnTitleValue({
    required String title,
    required String value,
  }) {
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
