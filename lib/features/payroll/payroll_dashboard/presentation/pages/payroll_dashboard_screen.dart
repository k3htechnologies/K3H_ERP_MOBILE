import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
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

  // TEXT CONTROLLER
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _payrollDashboardCubit = context.read<PayrollDashboardCubit>();
    _payrollDashboardCubit.getPayrollDashboardList(context);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _payrollDashboardCubit.getPayrollDashboardList(context);
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

    if (table0 == null || table0.isEmpty) {
      return const SizedBox();
    }

    final data = table0.first;

    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _overviewCard(
                title: "On Leave Today",
                value: data.onLeave.toString(),
                icon: SvgPicture.asset(
                  AppAssets.payrollOnLeaveIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.error,
                backgroundColor: AppColor.lightRed.withValues(alpha: .5),
              ),
            ),
            Expanded(
              child: _overviewCard(
                title: "Outdoor Today",
                value: data.outdoor.toString(),
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
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _overviewCard(
                title: "Pending Approval",
                value: data.pendingApproval.toString(),
                icon: SvgPicture.asset(
                  AppAssets.regularizeIcon,
                  height: 18,
                  width: 18,
                ),
                iconColor: AppColor.darkGreen,
                backgroundColor: AppColor.lightGreen.withValues(alpha: .5),
              ),
            ),
            Expanded(
              child: _overviewCard(
                title: "Attendance Alert",
                value: data.attendanceAlert.toString(),
                icon: SvgPicture.asset(
                  AppAssets.raiseTaskIcon,
                  height: 16,
                  width: 16,
                ),
                iconColor: AppColor.purple,
                backgroundColor: AppColor.purple20.withValues(alpha: .08),
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
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: commonCardDecoration(),
      padding: const EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: AppTextStyle.ts20SB()),
              CustomIconButton(
                onPressed: onTap ?? () {},
                icon: icon,
                backgroundColor: backgroundColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // QUICK ACTION
  Widget _quickAction() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Action", style: AppTextStyle.ts14M()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      onPressed: () {
                        goRouter.pushNamed(AppRoutes.applyLeave);
                      },
                      icon: SvgPicture.asset(
                        AppAssets.applyLeaveIcon,
                        height: 16,
                        width: 16,
                        colorFilter: ColorFilter.mode(
                          AppColor.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text("Apply Leave", style: AppTextStyle.ts12M()),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      onPressed: () {
                        goRouter.pushNamed(AppRoutes.compOff);
                      },
                      icon: SvgPicture.asset(
                        AppAssets.regularizeIcon,
                        height: 18,
                        width: 16,
                        colorFilter: ColorFilter.mode(
                          AppColor.green,
                          BlendMode.srcIn,
                        ),
                      ),
                      backgroundColor: AppColor.lightGreen.withValues(
                        alpha: .5,
                      ),
                    ),
                    Text("Request Comp-off", style: AppTextStyle.ts12M()),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      onPressed: () {
                        goRouter.pushNamed(AppRoutes.addOutdoor);
                      },
                      icon: Icon(Icons.add, size: 16, color: AppColor.primary),
                    ),
                    Text("Add Outdoor", style: AppTextStyle.ts12M()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
    return Container(
      decoration: commonCardDecoration(),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Leave Management",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(),
          (state.payrollDashboardModel?.table1 == null ||
                  state.payrollDashboardModel!.table1.isEmpty)
              ? SizedBox(
                height: 300,
                child: Center(
                  child: Text(
                    "No Leave Data Found",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
              : SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.payrollDashboardModel!.table1.length,
                  itemBuilder: (_, index) {
                    final employee = state.payrollDashboardModel!.table1[index];
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
                              CircleAvatar(radius: 20),
                              horizontalSpacing(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      employee.fullName,
                                      style: AppTextStyle.ts14M(),
                                    ),
                                    Text(
                                      "Software Developer",
                                      style: AppTextStyle.ts12M(
                                        color: AppColor.grey,
                                      ),
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
                                title: "Status",
                                value: "Pending",
                                valueTextStyle: AppTextStyle.ts14M(
                                  color: AppColor.error,
                                ),
                              ),
                              buildColumnTitleValue(
                                title: "Leave Type",
                                value: "Casual Leave",
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "No. Of Days",
                                value: "5 Days",
                              ),
                              buildColumnTitleValue(
                                title: "Duration",
                                value: "4 January- 8 January",
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
          Center(
            child: Text(
              "No Leave Management Found",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),

          /// FOR LATER USE WHEN DATA WILL BE THERE IN API
          /*
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (_, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16.0),
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
                              "Udya Sawant",
                              style: AppTextStyle.ts16SB(
                                color: AppColor.primary,
                              ),
                            ),
                            verticalSpacing(),
                            Text(
                              "Asian Paints",
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpacing(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("02 February 2026", style: AppTextStyle.ts14M()),
                          verticalSpacing(),
                          Text(
                            "11:00 AM",
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
          ),
       */
        ],
      ),
    );
  }

  // COMP OFF MANAGEMENT WIDGET
  Widget _buildCompOffManagementWidget(PayrollDashboardState state) {
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
          Center(
            child: Text(
              "No Comp-Off Management Found",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),

          /// FOR LATER USE WHEN DATA WILL BE THERE IN API
          /*
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (_, index) {
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
                          CircleAvatar(radius: 20),
                          horizontalSpacing(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rushi", style: AppTextStyle.ts14M()),
                                Text(
                                  "Software Developer",
                                  style: AppTextStyle.ts12M(
                                    color: AppColor.grey,
                                  ),
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
                            title: "Status",
                            value: "Pending",
                            valueTextStyle: AppTextStyle.ts14M(
                              color: AppColor.error,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                      Row(
                        children: [
                          buildColumnTitleValue(
                            title: "Working Date",
                            value: "12 January 2026",
                          ),
                          buildColumnTitleValue(
                            title: "Requested Date",
                            value: "16 January 2026",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
       */
        ],
      ),
    );
  }

  // RESIGNATION WIDGET
  Widget _buildResignationWidget(PayrollDashboardState state) {
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

          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (_, index) {
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
                          CircleAvatar(radius: 20),
                          horizontalSpacing(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rushi", style: AppTextStyle.ts14M()),
                                Text(
                                  "Software Developer",
                                  style: AppTextStyle.ts12M(
                                    color: AppColor.grey,
                                  ),
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
                            value: "12 January 2026",
                          ),
                          buildColumnTitleValue(
                            title: "Relieving Date",
                            value: "16 January 2026",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          buildColumnTitleValue(
                            title: "Offer In Hand",
                            value: "No",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Center(
            child: Text(
              "No Resignation Found",
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
