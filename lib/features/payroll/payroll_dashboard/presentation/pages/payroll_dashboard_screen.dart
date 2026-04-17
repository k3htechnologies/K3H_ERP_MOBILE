import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/model/payroll_dashboard_model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/presentation/cubit/payroll_dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayrollDashboardScreen extends StatefulWidget {
  const PayrollDashboardScreen({super.key});

  @override
  State<PayrollDashboardScreen> createState() => _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState extends State<PayrollDashboardScreen> {
  // CUBIT
  late PayrollDashboardCubit _payrollDashboardCubit;

  @override
  void initState() {
    super.initState();
    _payrollDashboardCubit = context.read<PayrollDashboardCubit>();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start;
    _payrollDashboardCubit.getPayrollDashboardList(context, 1, 10, start, end);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = start;
        _payrollDashboardCubit.getPayrollDashboardList(
          context,
          1,
          10,
          start,
          end,
        );
      },
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Payroll Dashboard",
          isMenuButton: true,
          authorization: AuthorizationModel(),
          showNotification: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: BlocBuilder<PayrollDashboardCubit, PayrollDashboardState>(
            builder: (context, state) {
              return Column(
                children: [
                  _overview(state),
                  verticalSpacing(),
                  _quickAction(),
                  verticalSpacing(),
                  _attendanceOverview(state),
                  verticalSpacing(),
                  _buildLeaveManagementWidget(state),
                  verticalSpacing(),
                  _buildOutdoorManagementWidget(state),
                  verticalSpacing(),
                  _buildCompOffManagementWidget(state),
                  verticalSpacing(),
                  _buildResignationWidget(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _overview(PayrollDashboardState state) {
    final table0 = state.payrollDashboardModel?.table0;
    final table1 = state.payrollDashboardModel?.table1;
    final table3 = state.payrollDashboardModel?.table3;
    final table5 = state.payrollDashboardModel?.table5;

    if ((table0 == null || table0.isEmpty) &&
        (table1 == null || table1.isEmpty) &&
        (table3 == null || table3.isEmpty)) {
      return const SizedBox();
    }

    final data = table0?.first;

    final int lateInCount =  table5?.first.absentCount??0;



    final avatarLeaveNames =
    table1?.map((e) => e.fullName).where((e) => e.isNotEmpty).toList();
    final avatarOutdoorNames =
    table3?.map((e) => e.createdBy).where((e) => e.isNotEmpty).toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _overviewCard(
                title: "On Leave Today",
                value: data?.onLeave.toString() ?? "00",
                icon: SvgPicture.asset(
                  AppAssets.payrollOnLeaveIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.error,
                backgroundColor: AppColor.lightRed.withValues(alpha: .5),
                avatarNames: avatarLeaveNames,
                onTap: () {
                  goRouter.pushNamed(AppRoutes.payrollReport);
                },
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: _overviewCard(
                title: "Outdoor Today",
                value: data?.outdoor.toString() ?? "00",
                icon: SvgPicture.asset(
                  AppAssets.locationIcon,
                  height: 16,
                  width: 16,
                  colorFilter: ColorFilter.mode(
                    AppColor.yellow,
                    BlendMode.srcIn,
                  ),
                ),
                iconColor: AppColor.yellow,
                backgroundColor: AppColor.lightYellow.withValues(alpha: .5),
                avatarNames: avatarOutdoorNames,
                onTap: () {
                  goRouter.pushNamed(AppRoutes.payrollReport);
                },
              ),
            ),
          ],
        ),
        verticalSpacing(),
        Row(
          children: [
            Expanded(
              child: _overviewCard(
                title: "Pending Approval",
                value: data?.pendingApproval.toString() ?? "00",
                icon: SvgPicture.asset(
                  AppAssets.regularizeIcon,
                  height: 18,
                  width: 18,
                ),
                iconColor: AppColor.darkGreen,
                backgroundColor: AppColor.lightGreen.withValues(alpha: .5),
                actionText: "View Pending List",
                onTap: () {
                  goRouter.pushNamed(AppRoutes.payrollReport);
                },
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: _overviewCard(
                title: "Attendance Alert",
                value: lateInCount.toString(),
                icon: SvgPicture.asset(
                  AppAssets.raiseTaskIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.purple,
                backgroundColor: AppColor.purple20.withValues(alpha: .08),
                actionText: "Late Logins",
                onTap: () {
                  goRouter.pushNamed(AppRoutes.payrollReport);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // OVERVIEW CARD
  Widget _overviewCard({
    required String title,
    required String value,
    required Widget icon,
    required Color iconColor,
    required Color backgroundColor,
    List<String>? avatarNames,
    String? actionText,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value.padLeft(2, '0'), style: AppTextStyle.ts20SB()),
              horizontalSpacing(),
              Container(
                height: 24,
                width: 24,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: icon,
              ),
            ],
          ),
          verticalSpacing(),
          if (avatarNames != null && avatarNames.isNotEmpty) ...[
            GestureDetector(
              onTap: onTap,
              child: SizedBox(
                height: 32,
                child: Stack(
                  children: List.generate(
                    avatarNames.length > 3 ? 3 : avatarNames.length,
                        (index) {
                      final name = avatarNames[index];

                      return Positioned(
                        left: index * 18.0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColor.primary.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            _getInitials(name),
                            style: AppTextStyle.ts12M(color: AppColor.primary),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ] else if (actionText != null) ...[
            GestureDetector(
              onTap: onTap,
              child: Text(
                actionText,
                style: AppTextStyle.ts10R(color: AppColor.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // QUICK ACTIONS
  Widget _quickAction() {
    final actions = [
      QuickActionItem(
        icon: SvgPicture.asset(AppAssets.applyLeaveIcon),
        text: "Apply Leave",
        backgroundColor: AppColor.lightBlue,
        onTap: () {
          goRouter.pushNamed(AppRoutes.applyLeave);
        },
      ),
      QuickActionItem(
        icon: SvgPicture.asset(AppAssets.regularizeIcon),
        text: "Request Comp-off",
        backgroundColor: AppColor.lightGreen,
        onTap: () {
          goRouter.pushNamed(AppRoutes.addCompOff);
        },
      ),
      QuickActionItem(
        icon: SvgPicture.asset(AppAssets.addOutdoorIcon),
        text: "Add Outdoor",
        backgroundColor: AppColor.primary.withValues(alpha: 0.22),
        onTap: () {
          goRouter.pushNamed(AppRoutes.addOutdoor);
        },
      ),
    ];
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Actions", style: AppTextStyle.ts14M()),
          verticalSpacing(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: actions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final item = actions[index];
                    return _quickActionCard(
                      icon: item.icon,
                      text: item.text,
                      backgroundColor: item.backgroundColor,
                      onTap: item.onTap,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // QUICK ACTION CARD
  Widget _quickActionCard({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomIconButton(
          onPressed: onTap,
          icon: icon,
          backgroundColor: backgroundColor ?? AppColor.lightBlue,
        ),
        verticalSpacing(),
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            style: AppTextStyle.ts12M(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ATTENDANCE OVERVIEW
  Widget _attendanceOverview(PayrollDashboardState state) {
    final table5 = state.payrollDashboardModel?.table5;

    if (table5 == null || table5.isEmpty) {
      return const SizedBox();
    }

    final data = table5.first;
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Attendance Overview",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(height: 25),
          CommonRadialChart(
            total: data.totalEmployees,
            items: [
              RadialChartItem(
                title: "Present",
                value: data.presentCount,
                color: AppColor.primary,
              ),
              RadialChartItem(
                title: "Absent",
                value: data.absentCount,
                color: AppColor.blue,
              ),
              RadialChartItem(
                title: "On Leave",
                value: data.onLeaveCount,
                color: AppColor.grey50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // LEAVE MANAGEMENT WIDGET
  Widget _buildLeaveManagementWidget(PayrollDashboardState state) {
    Color statusColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Leave Management",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          (state.payrollDashboardModel?.table1 == null ||
              state.payrollDashboardModel!.table1.isEmpty)
              ? Center(
            child: Text(
              "No Data Found",
              style: AppTextStyle.ts12M(
                color: AppColor.black.withValues(alpha: .5),
              ),
            ),
          )
              : SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: state.payrollDashboardModel!.table1.length,
              itemBuilder: (_, index) {
                final employee = state.payrollDashboardModel!.table1[index];
                final absentEmployeeData = employee;

                switch (absentEmployeeData.status.toLowerCase()) {
                  case "approved":
                    statusColor = AppColor.green;
                    break;

                  case "rejected":
                    statusColor = AppColor.red;
                    break;

                  default:
                    statusColor = AppColor.black.withValues(alpha: 0.5);
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColor.lightGreyBackground,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColor.primary.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              _getInitials(absentEmployeeData.fullName),
                              style: AppTextStyle.ts12M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: Text(
                              absentEmployeeData.fullName,
                              style: AppTextStyle.ts14M(),
                            ),
                          ),
                          CustomButton(
                            text: "Approve",
                            onPressed: () {},
                            isDisable:
                            absentEmployeeData.canApprove == 0
                                ? true
                                : false,
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Status",
                            value: absentEmployeeData.status,
                            valueTextStyle: AppTextStyle.ts14M(
                              color: statusColor,
                            ),
                          ),
                          buildColumnTitleValue(
                            title: "Leave Type",
                            value: absentEmployeeData.leaveType,
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "No. Of Days",
                            value:
                            "${absentEmployeeData.noOfDays.toString()} Days",
                          ),
                          buildColumnTitleValue(
                            title: "Duration",
                            value:
                            "${formatDateTimeAsDDMMMYYYY(absentEmployeeData.startDate)}- ${formatDateTimeAsDDMMMYYYY(absentEmployeeData.endDate)}",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // OUTDOOR MANAGEMENT
  Widget _buildOutdoorManagementWidget(PayrollDashboardState state) {
    final outdoorList = state.payrollDashboardModel?.table3 ?? [];
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Outdoor Management",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
            ],
          ),
          verticalSpacing(),
          (outdoorList.isNotEmpty)
              ? SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: outdoorList.length,
              itemBuilder: (_, index) {
                final outdoor = outdoorList[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColor.grey2, width: .5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outdoor.companyName,
                              style: AppTextStyle.ts16SB(
                                color: AppColor.primary,
                              ),
                            ),
                            verticalSpacing(),
                            Text(
                              outdoor.createdBy,
                              style: AppTextStyle.ts14M(
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpacing(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate),
                            style: AppTextStyle.ts14M(),
                          ),
                          verticalSpacing(),
                          Text(
                            formatTime(outdoor.outDoorTime),
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
              : Center(
            child: Text(
              "No Data Found",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COMP OFF MANAGEMENT WIDGET
  Widget _buildCompOffManagementWidget(PayrollDashboardState state) {
    final compoffList = state.payrollDashboardModel?.table2 ?? [];
    return Container(
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Comp-Off Management",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
            ],
          ),
          verticalSpacing(),
          compoffList.isNotEmpty
              ? SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: compoffList.length,
              itemBuilder: (_, index) {
                final compoff = compoffList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColor.grey2.withValues(alpha: .12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColor.primary.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              _getInitials(compoff.createdBy),
                              style: AppTextStyle.ts12M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  compoff.createdBy,
                                  style: AppTextStyle.ts14M(),
                                ),
                              ],
                            ),
                          ),
                          CustomButton(text: "Approve", onPressed: () {}),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Status",
                            value: compoff.status,
                            valueTextStyle: AppTextStyle.ts14M(
                              color:
                              compoff.status.toLowerCase() == "approved"
                                  ? AppColor.green
                                  : AppColor.error,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Working Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              compoff.workingDate,
                            ),
                          ),
                          buildColumnTitleValue(
                            title: "Requested Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              compoff.compoffDate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
              : Center(
            child: Text(
              "No Data Found",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // RESIGNATION WIDGET
  Widget _buildResignationWidget(PayrollDashboardState state) {
    final resignationList = state.payrollDashboardModel?.table4 ?? [];
    return Container(
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Resignation",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
            ],
          ),
          verticalSpacing(),
          (resignationList.isNotEmpty)
              ? SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: resignationList.length,
              itemBuilder: (_, index) {
                final resignation = resignationList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColor.grey2.withValues(alpha: .12),
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColor.primary.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              _getInitials(resignation.fullName),
                              style: AppTextStyle.ts12M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                          horizontalSpacing(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resignation.fullName,
                                  style: AppTextStyle.ts14M(),
                                ),
                              ],
                            ),
                          ),
                          CustomButton(text: "Approve", onPressed: () {}),
                        ],
                      ),
                      Row(
                        children: [
                          buildColumnTitleValue(
                            title: "Resignation Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              resignation.resignationDate,
                            ),
                          ),
                          buildColumnTitleValue(
                            title: "Relieving Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              resignation.expectedRelievingDate,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          buildColumnTitleValue(
                            title: "Offer In Hand",
                            value:
                            resignation.isAnyOfferInHand.toString() ==
                                "false"
                                ? "No"
                                : "Yes",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
              : Center(
            child: Text(
              "No Data Found",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}