import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_management_dashboard.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_timeline.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/cubit/visitor_management_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/pages/widgets/gate_pass_filter.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/pages/widgets/overview_widget.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VisitorManagementDashboardScreen extends StatefulWidget {
  const VisitorManagementDashboardScreen({super.key});

  @override
  State<VisitorManagementDashboardScreen> createState() =>
      _VisitorManagementDashboardScreenState();
}

class _VisitorManagementDashboardScreenState
    extends State<VisitorManagementDashboardScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late VisitorManagementDashboardCubit _visitorManagementDashboardCubit;
  final ValueNotifier<String> _selectedFilterType = ValueNotifier("Today");
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier(null);

  @override
  void initState() {
    _visitorManagementDashboardCubit =
        context.read<VisitorManagementDashboardCubit>();
    _visitorManagementDashboardCubit.getGatePassDashboard(
      context: context,
      filterType: _selectedFilterType.value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _selectedFilterType.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Visitor Management Dashboard",
        authorization: AuthorizationModel(),
        isMenuButton: true,
        showNotification: true,
      ),
      body: BlocBuilder<
        VisitorManagementDashboardCubit,
        VisitorManagementDashboardState
      >(
        builder: (context, state) {
          if (state.isLoading ?? true) {
            return Center(child: loader());
          }

          final dashboard =
              state.gatePassDashboardList.isNotEmpty
                  ? state.gatePassDashboardList.first
                  : null;

          final dashboardCount =
              dashboard?.table0.isNotEmpty == true
                  ? dashboard!.table0.first
                  : null;

          final todayVisitors = dashboard?.table1 ?? [];

          final todayVisitorsTimeline = dashboard?.table2 ?? [];
          final timelineGroups = context
              .read<VisitorManagementDashboardCubit>()
              .buildTimelineGroups(todayVisitorsTimeline);
          final purposeWiseVisitors = dashboard?.table3 ?? [];
          final alertsVisitors = dashboard?.table4 ?? [];
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: _selectedFilterType,
                      builder: (context, selectedTab, child) {
                        return GatePassFilterWidget(
                          selectedTab: selectedTab,
                          initialFromDate: _fromDateNotifier.value,
                          initialToDate: _toDateNotifier.value,
                          onTap: (tab) async {
                            _selectedFilterType.value = tab;
                            await _visitorManagementDashboardCubit
                                .clearGatePassDashboarddData();
                            if (context.mounted) {
                              if (tab.toLowerCase() != 'datewise') {
                                await _visitorManagementDashboardCubit
                                    .getGatePassDashboard(
                                      context: context,
                                      filterType: _selectedFilterType.value,
                                    );
                              } else {
                                _fromDateNotifier.value = null;
                                _toDateNotifier.value = null;
                              }
                            }
                          },
                          onDateChanged: (from, to) {
                            _fromDateNotifier.value = from;
                            _toDateNotifier.value = to;

                            if (to != null) {
                              _visitorManagementDashboardCubit
                                  .getGatePassDashboard(
                                    context: context,
                                    filterType: _selectedFilterType.value,
                                    fromDate: from,
                                    toDate: to,
                                  );
                            }
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    if (dashboardCount == null) ...{
                      Center(
                        child: noDataWidget(
                          message:
                              _selectedFilterType.value.toLowerCase() ==
                                      'datewise'
                                  ? "Select a date range to view visitors"
                                  : "No records Found",
                          iconSize: 160.sp,
                        ),
                      ),
                    } else ...{
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(text: "+ Add Visitor", onPressed: () {}),
                        ],
                      ),
                      verticalSpacing(),
                      GatePassOverviewWidget(
                        filterType: _selectedFilterType.value,
                      ),
                      verticalSpacing(height: 20.sp),
                      _buildVisitors(
                        context,
                        dashboardCount,
                        todayVisitors,
                        timelineGroups,
                      ),
                      verticalSpacing(height: 20.sp),
                      _buildVisitorTimeline(timelineGroups),
                      verticalSpacing(height: 20.sp),
                      _buildPurposeWiseVisitors(purposeWiseVisitors),
                      verticalSpacing(height: 20.sp),
                      _buildAlerts(alertsVisitors),
                    },
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitors(
    BuildContext context,
    Table0? dashboardCount,
    List<Table1> todayVisitors,
    List<TimelineGroup> timelineGroups,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Today's Visitors",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                TextSpan(
                  text: " (${todayVisitors.length})",
                  style: AppTextStyle.ts12M(color: AppColor.grey),
                ),
              ],
            ),
          ),
          verticalSpacing(height: 16.sp),
          if (todayVisitors.isEmpty) ...{
            Center(
              child: noDataWidget(
                message: "No records Found",
                iconSize: 160.sp,
              ),
            ),
          } else ...{
            SizedBox(
              height: 300.sp,
              child: ListView.builder(
                itemCount: todayVisitors.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final visitor = todayVisitors[index];
                  final statusColor = getVisitorPurposeColor(visitor.status);

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.sp),
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(width: 1.sp, color: AppColor.grey10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.sp,
                              backgroundColor: AppColor.primary,
                              child: ClipOval(
                                child: NetworkImageWidget(
                                  key: ValueKey(visitor.photoUrl),
                                  imageUrl: visitor.photoUrl,
                                  fit: BoxFit.fill,
                                  width: 50.w,
                                  height: 50.h,
                                ),
                              ),
                            ),
                            horizontalSpacing(width: 12.sp),
                            Expanded(
                              child: Text(
                                visitor.visitorName,
                                style: AppTextStyle.ts14M(),
                              ),
                            ),
                            horizontalSpacing(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.sp,
                                    horizontal: 8.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.sp),
                                    color: statusColor.backgroundColor,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 6.sp,
                                        width: 6.sp,
                                        decoration: BoxDecoration(
                                          color: statusColor.textColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Text(
                                        visitor.status,
                                        style: AppTextStyle.ts12SB(
                                          color: statusColor.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildColumnTitleValue(
                              title: "Contact",
                              value: visitor.contact,
                              removeExpanded: true,
                            ),
                            buildColumnTitleValue(
                              title: "Appointment With",
                              value: visitor.appointmentWith,
                              removeExpanded: true,
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildColumnTitleValue(
                              title: "Check-In Time",
                              value: formatTime(visitor.checkInTime),
                              removeExpanded: true,
                            ),
                            buildColumnTitleValue(
                              title: "Purpose",
                              value: "",
                              customValueWidget: visitorManagementStatusWidget(
                                visitor.purpose,
                                textStyle: AppTextStyle.ts12M(),
                              ),
                              removeExpanded: true,
                            ),
                          ],
                        ),
                        Divider(thickness: 1.0, color: AppColor.grey50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildColumnTitleValue(
                              title: "Check-Out Time",
                              value: formatTime(visitor.checkOutTime),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomIconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      LucideIcons.logOut,
                                      size: 16,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      LucideIcons.bell,
                                      size: 16,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ],
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
          },
        ],
      ),
    );
  }

  Widget _buildVisitorTimeline(List<TimelineGroup> timelineGroups) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Visitor Timeline",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(height: 16.sp),
          if (timelineGroups.isEmpty) ...{
            Center(child: noDataWidget(iconSize: 160.sp)),
          } else ...{
            SizedBox(
              height: 250.sp,
              child: ListView.builder(
                itemCount: timelineGroups.length,
                padding: EdgeInsets.zero,
                itemBuilder:
                    (context, index) => _TimelineRow(
                      group: timelineGroups[index],
                      isLast: index == timelineGroups.length - 1,
                    ),
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildPurposeWiseVisitors(List<Table3> purposeList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Purpose-wise Visitors",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(height: 16.sp),
          ...List.generate(purposeList.length, (index) {
            final item = purposeList[index];
            final color = getPurposeWiseVisitorsColor(item.purpose);
            final fraction = (item.percentage / 100).clamp(0.0, 1.0);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == purposeList.length - 1 ? 4.sp : 16.sp,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10.sp,
                        height: 10.sp,
                        decoration: BoxDecoration(
                          color: color.textColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      horizontalSpacing(width: 10.sp),
                      Expanded(
                        child: Text(
                          item.purpose,
                          style: AppTextStyle.ts14M(color: AppColor.black),
                        ),
                      ),
                      Text(
                        item.visitorCount.toString(),
                        style: AppTextStyle.ts14SB(color: AppColor.black),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 8.sp),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.sp),
                    child: Stack(
                      children: [
                        Container(height: 8.sp, color: AppColor.grey10),
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            height: 8.sp,
                            color: color.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlerts(List<Table4> alertList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Alerts", style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 16.sp),
          if (alertList.isEmpty) ...{
            Center(child: noDataWidget(iconSize: 120.sp)),
          } else ...{
            SizedBox(
              height: 250.sp,
              child: ListView.builder(
                itemCount: alertList.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Container();
                },
              ),
            ),
          },
        ],
      ),
    );
  }
}

class VisitorPurposeColor {
  final Color backgroundColor;
  final Color textColor;

  const VisitorPurposeColor({
    required this.backgroundColor,
    required this.textColor,
  });
}

VisitorPurposeColor getVisitorPurposeColor(String? purpose) {
  switch (purpose?.trim().toLowerCase()) {
    case "checked out":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.checkedOutBgColor,
        textColor: AppColor.checkedOut,
      );

    case "currently in":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffD7F8E9),
        textColor: Color(0xff10B981),
      );

    case "not checked out":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffFFE4E6),
        textColor: Color(0xffE11D48),
      );

    case "overstaying":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffF3E8FF),
        textColor: Color(0xff7E22CE),
      );
    case "expected":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffFFEDD5),
        textColor: Color(0xffEA580C),
      );
    case "pending approval":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightYellow,
        textColor: AppColor.rustOrange,
      );
    case "approved":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffDCFCE7),
        textColor: Color(0xff16A34A),
      );
    case "rejected":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightRed,
        textColor: Color(0xffDC2626),
      );
    case "others":
    case "other":
      return const VisitorPurposeColor(
        backgroundColor: Color(0x26FF0037),
        textColor: Color(0xFFFF0037),
      );

    default:
      return const VisitorPurposeColor(
        backgroundColor: Color(0x261D1D1D),
        textColor: Color(0xFF333333),
      );
  }
}

VisitorPurposeColor getPurposeWiseVisitorsColor(String? purpose) {
  switch (purpose?.trim().toLowerCase()) {
    case "delivery":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightGreen,
        textColor: AppColor.bookingDoneColorText,
      );

    case "guest":
      return const VisitorPurposeColor(
        backgroundColor: AppColor.lightPurple,
        textColor: AppColor.purple,
      );

    case "interview":
      return const VisitorPurposeColor(
        backgroundColor: Color(0x1D1D1D26),
        textColor: Color(0xff333333),
      );

    case "meeting":
      return const VisitorPurposeColor(
        backgroundColor: Color(0xffFBFF00),
        textColor: AppColor.brown,
      );
    case "others":
    case "other":
      return const VisitorPurposeColor(
        backgroundColor: Color(0x26FF0037),
        textColor: Color(0xFFFF0037),
      );

    default:
      return const VisitorPurposeColor(
        backgroundColor: Color(0x261D1D1D),
        textColor: Color(0xFF333333),
      );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineGroup group;
  final bool isLast;
  const _TimelineRow({required this.group, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dotColor =
        getVisitorPurposeColor(group.visitors.first.status).textColor;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16.sp,
            child: Divider(
              height: 1.sp,
              thickness: 1.sp,
              color: AppColor.grey2.withValues(alpha: 0.4),
            ),
          ),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52.sp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('hh:mm').format(group.time),
                      style: AppTextStyle.ts12SB(
                        color: AppColor.black.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      DateFormat('a').format(group.time),
                      style: AppTextStyle.ts10SB(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 12.sp),
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.only(top: 2),
                        color: AppColor.grey.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
              horizontalSpacing(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            group.visitors
                                .map(
                                  (v) => Padding(
                                    padding: EdgeInsets.only(right: 8.sp),
                                    child: VisitorCard(visitor: v),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    if (!isLast) SizedBox(height: 32.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatsCardWidget(
    BuildContext context, {
    required String title,
    required String value,
    required Color valueColor,
    required String subTitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1.sp, color: AppColor.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.196),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.sp),
                height: 30.sp,
                width: 30.sp,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: Icon(icon, color: iconColor, size: 16.w),
              ),
              horizontalSpacing(),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.ts12M(color: AppColor.grey),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 12.sp),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyle.ts20SB(color: valueColor),
                ),
                TextSpan(text: " "),
                TextSpan(
                  text: subTitle,
                  style: AppTextStyle.ts12M(color: AppColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisitorCard extends StatelessWidget {
  final Table2 visitor;
  const VisitorCard({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final statusColor = getVisitorPurposeColor(visitor.status);
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(width: 1.sp, color: AppColor.grey30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${visitor.visitorName} +${visitor.noOfParticipants}",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.6),
            ),
          ),
          verticalSpacing(),
          Text(
            visitor.status,
            style: AppTextStyle.ts12SB(color: statusColor.textColor),
          ),
        ],
      ),
    );
  }
}
