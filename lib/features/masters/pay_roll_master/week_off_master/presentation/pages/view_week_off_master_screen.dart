import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewWeekOffMasterScreen extends StatelessWidget {
  final WeekOffMasterModel weekOffMaster;

  const ViewWeekOffMasterScreen({super.key, required this.weekOffMaster});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Week Off Master",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Week Off Policy Name",
                          value: weekOffMaster.weekOffPolicyName,
                        ),
                        _buildColumnTitleValue(
                          title: "Week Off Policy Code",
                          value: weekOffMaster.weekOffPolicyCode,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Week Days",
                          value: weekOffMaster.weekDays.toString(),
                        ),
                        _buildColumnTitleValue(
                          title: "Weekly Off",
                          value: weekOffMaster.weeklyOff,
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
                    Text("Week Off Details", style: AppTextStyle.ts16SB()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Weekly Off2",
                          value: weekOffMaster.weeklyOff2,
                        ),
                        _buildColumnTitleValue(
                          title: "Weekly Off2 Type",
                          value: weekOffMaster.weeklyOff2Type,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Week Days Starts On",
                          value: weekOffMaster.weekDaysStartsOn,
                        ),
                        _buildColumnTitleValue(
                          title: "Not Applicable For Months",
                          value: weekOffMaster.notApplicableForMonths,
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
                          value: weekOffMaster.createdBy,
                        ),
                        _buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            weekOffMaster.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnTitleValue(
                          title: "Modified By",
                          value: weekOffMaster.modifiedBy,
                        ),
                        _buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            weekOffMaster.modifiedDate,
                          ),
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
