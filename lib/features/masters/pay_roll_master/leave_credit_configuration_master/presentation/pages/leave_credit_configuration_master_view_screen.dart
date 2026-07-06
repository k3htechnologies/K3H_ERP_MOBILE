import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveCreditConfigurationMasterViewScreen extends StatefulWidget {
  final LeaveCreditConfigurationMasterModel leaveCreditConfigurationMaster;
  const LeaveCreditConfigurationMasterViewScreen({
    super.key,
    required this.leaveCreditConfigurationMaster,
  });

  @override
  State<LeaveCreditConfigurationMasterViewScreen> createState() =>
      _LeaveCreditConfigurationMasterViewScreenState();
}

class _LeaveCreditConfigurationMasterViewScreenState
    extends State<LeaveCreditConfigurationMasterViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Leave Credit Configuration",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Overview", "Leave Balance Types"],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildOverviewTab(), _buildLeaveBalanceTypesTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW TAB
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          // LEAVE CREDIT CONFIGURATION DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leave Credit Configuration Details",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Leave Period Mode",
                      value:
                          widget.leaveCreditConfigurationMaster.leavePeriodMode,
                    ),
                    buildColumnTitleValue(
                      title: "Department",
                      value:
                          widget.leaveCreditConfigurationMaster.departmentName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Financial Year Start Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget
                            .leaveCreditConfigurationMaster
                            .financialYearStartDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Financial Year End Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget
                            .leaveCreditConfigurationMaster
                            .financialYearEndDate,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Designation",
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                          ),
                          verticalSpacing(height: 4),
                          Text(
                            widget
                                    .leaveCreditConfigurationMaster
                                    .designationName
                                    .isEmpty
                                ? "-"
                                : widget
                                    .leaveCreditConfigurationMaster
                                    .designationName,
                            style: AppTextStyle.ts14M(color: AppColor.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ACTION DETAILS
          actionCardWidget(
            createdBy: widget.leaveCreditConfigurationMaster.createdBy,
            createdDate: widget.leaveCreditConfigurationMaster.createdDate,
            modifiedBy: widget.leaveCreditConfigurationMaster.modifiedBy,
            modifiedDate: widget.leaveCreditConfigurationMaster.modifiedDate,
          ),
        ],
      ),
    );
  }

  // LEAVE BALANCE TYPES TAB
  Widget _buildLeaveBalanceTypesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          if (widget.leaveCreditConfigurationMaster.leaveBalanceType.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  "No leave balance types found",
                  style: AppTextStyle.ts14R(color: AppColor.grey),
                ),
              ),
            )
          else
            ...widget.leaveCreditConfigurationMaster.leaveBalanceType.map((
              balanceType,
            ) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Leave Type",
                          value: balanceType.leaveTypeName,
                        ),
                        buildColumnTitleValue(
                          title: "Leave Credit",
                          value: "${balanceType.leaveCredit} days",
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
