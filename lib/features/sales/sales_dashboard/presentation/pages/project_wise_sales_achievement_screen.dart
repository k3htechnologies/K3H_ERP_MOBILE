import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProjectWiseSalesAchievementScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final String filterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  const ProjectWiseSalesAchievementScreen({
    super.key,
    required this.projectId,
    required this.filterType,
    required this.fromDate,
    required this.toDate,
    required this.projectName,
  });

  @override
  State<ProjectWiseSalesAchievementScreen> createState() =>
      _ProjectWiseSalesAchievementScreenState();
}

class _ProjectWiseSalesAchievementScreenState
    extends State<ProjectWiseSalesAchievementScreen>
    with TickerProviderStateMixin {
  late SalesDashboardCubit _salesDashboardCubit;

  // TAB CONTROLLERS
  late TabController _tabController;

  List<String> projectWiseSalesAchievementTabs = const [
    'Overview',
    'Closing Target',
    'Sourcing Target',
    'Channel Partner ',
  ];

  @override
  void initState() {
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    _tabController = TabController(length: 4, vsync: this);

    _salesDashboardCubit.getProjectWiseSalesDashboard(
      context: context,
      projectId: widget.projectId,
      filterType: widget.filterType,
      fromDate: widget.fromDate,
      toDate: widget.toDate,
    );
    super.initState();
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
        screenTitle: "Project Achievement",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showSiteSelectedWidget(projectName: widget.projectName),
            verticalSpacing(),
            RichText(
              text: TextSpan(
                style: AppTextStyle.ts14R(),
                children: [
                  TextSpan(
                    text: "Filter: ",
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),

                  TextSpan(
                    text: widget.filterType,
                    style: AppTextStyle.ts14M(),
                  ),
                ],
              ),
            ),
            verticalSpacing(),
            ChipStyleTabBar(
              margin: EdgeInsets.zero,
              controller: _tabController,
              tabs: projectWiseSalesAchievementTabs,
            ),
            verticalSpacing(),
            BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
              builder: (context, state) {
                if (state.isLoading ?? false) {
                  return Expanded(child: Center(child: loader()));
                }
                return Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      overView(),
                      closingAchievementTab(),
                      sourcingAchievementTab(),
                      channelPartnerTab(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget overView() {
  return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
    builder: (context, state) {
      final totalRevenue =
          state
              .projectWiseSalesDashboardList
              .first
              .projectAchievementData
              .first
              .totalRevenue;
      final totalWalkins =
          state
              .projectWiseSalesDashboardList
              .first
              .projectAchievementData
              .first
              .totalWalkins;
      final totalWalkinsByCp =
          state
              .projectWiseSalesDashboardList
              .first
              .projectAchievementData
              .first
              .walkinsByCp;
      final totalWalkinsByDirect =
          state
              .projectWiseSalesDashboardList
              .first
              .projectAchievementData
              .first
              .walkinsDirect;
      final totalRevisits =
          state
              .projectWiseSalesDashboardList
              .first
              .projectAchievementData
              .first
              .revisits;
      final totalBooking =
          state
              .projectWiseSalesDashboardList
              .first
              .projectAchievementData
              .first
              .totalBooking;
      return Column(
        spacing: 12.h,
        children: [
          overviewTile(
            title: "Walkins",
            value: totalWalkins.addCommas(),
            icon: LucideIcons.users,
          ),
          overviewTile(
            title: "Walkins By CP",
            value: totalWalkinsByCp.addCommas(),
            icon: LucideIcons.userPlus,
          ),
          overviewTile(
            title: "Walkins By Direct",
            value: totalWalkinsByDirect.addCommas(),
            icon: LucideIcons.userCheck,
          ),
          overviewTile(
            title: "Revisits",
            value: totalRevisits.addCommas(),
            icon: LucideIcons.refreshCcw,
          ),
          overviewTile(
            title: "Booking",
            value: totalBooking.addCommas(),
            icon: LucideIcons.badgeCheck,
          ),
          overviewTile(
            title: "Revenue (₹)",
            value: totalRevenue.addCommas(),
            icon: LucideIcons.indianRupee,
          ),
        ],
      );
    },
  );
}

Widget overviewTile({
  required String title,
  required String value,
  required IconData icon,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: commonCardDecoration(),
    child: Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColor.lightBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColor.primary, size: 22),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyle.ts14M()),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget closingAchievementTab() {
  return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
    builder: (context, state) {
      if (state.projectWiseSalesDashboardList.first.table0.isEmpty) {
        return Center(child: noDataWidget(message: "No data available"));
      }
      return ListView.builder(
        shrinkWrap: true,
        itemCount: state.projectWiseSalesDashboardList.first.table0.length,
        itemBuilder: (context, index) {
          final achievement =
              state.projectWiseSalesDashboardList.first.table0[index];
          final totalWalkins =
              achievement.walkinsByCP +
              achievement.walkinsDirect +
              achievement.freshVisits +
              achievement.revisits;
          final actualTotalWalkins =
              achievement.actualWalkinsByCP +
              achievement.actualFreshVisits +
              achievement.actualRevisits;
          final totalBooking =
              achievement.bookingByCP + achievement.bookingDirect;
          final actualTotalBooking =
              achievement.actualBookingByCP + achievement.actualBookingDirect;
          return Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(12.0),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: achievement.employeeName,
                          style: AppTextStyle.ts16M(color: AppColor.black),
                        ),
                        TextSpan(
                          text: '\n${achievement.designationName}',
                          style: AppTextStyle.ts12R(
                            color:
                                AppColor
                                    .textSecondary, // adjust color as needed
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// WALKINS
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "Total Walkins",
                      value: totalWalkins.addCommas(),
                      customValueWidget: outofTarget(
                        actual: actualTotalWalkins.addCommas(),
                        target: totalWalkins.addCommas(),
                      ),
                    ),
                    children: [
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "By CP",
                        value: achievement.walkinsByCP.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualWalkinsByCP.addCommas(),
                          target: achievement.walkinsByCP.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Fresh Visits",
                        value: achievement.freshVisits.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualFreshVisits.addCommas(),
                          target: achievement.freshVisits.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Revisits",
                        value: achievement.revisits.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualRevisits.addCommas(),
                          target: achievement.revisits.addCommas(),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: AppColor.grey50),

                  /// BOOKINGS
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "Total Booking",
                      value: totalBooking.addCommas(),
                      customValueWidget: outofTarget(
                        actual: actualTotalBooking.addCommas(),
                        target: totalBooking.addCommas(),
                      ),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    childrenPadding: EdgeInsets.zero,
                    children: [
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "By CP",
                        value: achievement.bookingByCP.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualBookingByCP.addCommas(),
                          target: achievement.bookingByCP.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Direct",
                        value: achievement.bookingDirect.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualBookingDirect.addCommas(),
                          target: achievement.bookingDirect.addCommas(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget sourcingAchievementTab() {
  return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
    builder: (context, state) {
      if (state.projectWiseSalesDashboardList.first.table1.isEmpty) {
        return Center(child: noDataWidget(message: "No data available"));
      }
      return ListView.builder(
        shrinkWrap: true,
        itemCount: state.projectWiseSalesDashboardList.first.table1.length,
        itemBuilder: (context, index) {
          final achievement =
              state.projectWiseSalesDashboardList.first.table1[index];
          final totalWalkins =
              achievement.walkinsByCP +
              achievement.freshVisits +
              achievement.revisits;
          final actualTotalWalkins =
              achievement.actualWalkinsByCP +
              achievement.actualFreshVisits +
              achievement.actualRevisits;
          final totalCPs =
              achievement.uniqueCPs + achievement.activeCP + achievement.newCP;
          final actualTotalCPs =
              achievement.actualUniqueCPs +
              achievement.actualActiveCP +
              achievement.actualNewCP;
          return Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: achievement.employeeName,
                          style: AppTextStyle.ts16M(color: AppColor.black),
                        ),
                        TextSpan(
                          text: '\n${achievement.designationName}',
                          style: AppTextStyle.ts12R(
                            color:
                                AppColor
                                    .textSecondary, // adjust color as needed
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// WALKINS
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "Total Walkins",
                      value: totalWalkins.addCommas(),
                      customValueWidget: outofTarget(
                        actual: actualTotalWalkins.addCommas(),
                        target: totalWalkins.addCommas(),
                      ),
                    ),
                    children: [
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "By CP",
                        value: achievement.walkinsByCP.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualWalkinsByCP.addCommas(),
                          target: achievement.walkinsByCP.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Fresh Visits",
                        value: achievement.freshVisits.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualFreshVisits.addCommas(),
                          target: achievement.freshVisits.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Revisits",
                        value: achievement.revisits.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualRevisits.addCommas(),
                          target: achievement.revisits.addCommas(),
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 1, color: AppColor.grey50),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "Total Meetings",
                      value: achievement.totalMeetings.addCommas(),
                      customValueWidget: outofTarget(
                        actual: achievement.actualTotalMeetings.addCommas(),
                        target: achievement.totalMeetings.addCommas(),
                      ),
                    ),
                    children: [
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "OBM (Fresh Visits)",
                        value: achievement.totalOBMFreshVisits.addCommas(),
                        customValueWidget: outofTarget(
                          actual:
                              achievement.actualTotalOBMFreshVisits.addCommas(),
                          target: achievement.totalOBMFreshVisits.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "OBM (Revisits)",
                        value: achievement.totalOBMRevisits.addCommas(),
                        customValueWidget: outofTarget(
                          actual:
                              achievement.actualTotalOBMRevisits.addCommas(),
                          target: achievement.totalOBMRevisits.addCommas(),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: AppColor.grey50),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "Total CPs",
                      value: totalCPs.addCommas(),
                      customValueWidget: outofTarget(
                        actual: actualTotalCPs.addCommas(),
                        target: totalCPs.addCommas(),
                      ),
                    ),
                    children: [
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Unique CPs",
                        value: achievement.uniqueCPs.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualUniqueCPs.addCommas(),
                          target: achievement.uniqueCPs.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "Active CPs",
                        value: achievement.activeCP.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualActiveCP.addCommas(),
                          target: achievement.activeCP.addCommas(),
                        ),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 140.w,
                        title: "New CPs",
                        value: achievement.newCP.addCommas(),
                        customValueWidget: outofTarget(
                          actual: achievement.actualNewCP.addCommas(),
                          target: achievement.newCP.addCommas(),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: AppColor.grey50),
                  ExpansionTile(
                    enabled: false,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    showTrailingIcon: false,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "IBM",
                      value: achievement.totalIBM.addCommas(),
                      customValueWidget: outofTarget(
                        actual: achievement.actualTotalIBM.addCommas(),
                        target: achievement.totalIBM.addCommas(),
                      ),
                    ),
                  ),

                  Divider(height: 1, color: AppColor.grey50),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    enabled: false,
                    showTrailingIcon: false,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    title: buildRowTitleValue(
                      fixesWidth: 140.w,
                      title: "Bookings",
                      value: achievement.bookings.addCommas(),
                      customValueWidget: outofTarget(
                        actual: achievement.actualBookings.addCommas(),
                        target: achievement.bookings.addCommas(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget outofTarget({required String actual, required String target}) {
  return RichText(
    text: TextSpan(
      style: AppTextStyle.ts14R(color: AppColor.grey),
      children: [
        TextSpan(
          text: actual,
          style: AppTextStyle.ts14M(color: AppColor.red.withValues(alpha: 0.8)),
        ),
        TextSpan(text: " / ", style: AppTextStyle.ts14M()),
        TextSpan(text: target, style: AppTextStyle.ts14M()),
      ],
    ),
  );
}

Widget channelPartnerTab() {
  return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
    builder: (context, state) {
      if (state.projectWiseSalesDashboardList.first.table3.isEmpty) {
        return Center(child: noDataWidget(message: "No data available"));
      }
      return ListView.builder(
        itemCount: state.projectWiseSalesDashboardList.first.table3.length,
        itemBuilder: (context, index) {
          var channelPartner =
              state.projectWiseSalesDashboardList.first.table3[index];
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channelPartner.channelPartnerName,
                  style: AppTextStyle.ts16M(),
                ),
                buildRowTitleValue(
                  title: "CP Code  ",
                  value: channelPartner.systemGeneratedCode,
                ),

                buildRowTitleValue(
                  title: "Walkins By CP",
                  value: channelPartner.walkinsByCP.addCommas(),
                  singleLine: false,
                ),

                buildRowTitleValue(
                  title: "Revisits",
                  value: channelPartner.revisits.addCommas(),
                  singleLine: false,
                ),
                buildRowTitleValue(
                  title: "Total Booking",
                  value: channelPartner.totalBooking.addCommas(),
                  singleLine: false,
                ),
                buildRowTitleValue(
                  title: "Total Revenue",
                  value: channelPartner.totalRevenue.toIndianCurrency(),
                  singleLine: false,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
