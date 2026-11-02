import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/presentation/cubit/visitor_management_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GatePassOverviewWidget extends StatelessWidget {
  final String filterType;
  const GatePassOverviewWidget({super.key, required this.filterType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      VisitorManagementDashboardCubit,
      VisitorManagementDashboardState
    >(
      builder: (context, state) {
        final dashboard =
            state.gatePassDashboardList.isNotEmpty
                ? state.gatePassDashboardList.first
                : null;

        final dashboardCount =
            dashboard?.table0.isNotEmpty == true
                ? dashboard!.table0.first
                : null;

        return SingleChildScrollView(
          child: Column(
            children: [
              verticalSpacing(),
              _buildStatsCardWidget(
                context,
                title: "Total Visitors".toUpperCase(),
                subTitle: filterType,
                value: formatToKLCr(dashboardCount!.totalVisitors),
                valueColor: AppColor.black,
                icon: LucideIcons.users,
                iconColor: AppColor.grey,
                iconBgColor: AppColor.grey.withValues(alpha: 0.2),
              ),
              verticalSpacing(height: 16.sp),
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCardWidget(
                      context,
                      title: "Currently In".toUpperCase(),
                      subTitle: "Currently On-premises ",
                      value: dashboardCount.currentlyInside.addCommas(),
                      valueColor: AppColor.green,
                      icon: LucideIcons.check,
                      iconColor: AppColor.green,
                      iconBgColor: AppColor.lightGreen,
                    ),
                  ),
                  horizontalSpacing(width: 16.sp),
                  Expanded(
                    child: _buildStatsCardWidget(
                      context,
                      title: "Expected Today".toUpperCase(),
                      subTitle: "Currently On-premises ",
                      value: dashboardCount.expectedToday.addCommas(),
                      valueColor: AppColor.yellow,
                      icon: LucideIcons.calendarDays,
                      iconColor: AppColor.yellow,
                      iconBgColor: AppColor.lightYellow,
                    ),
                  ),
                ],
              ),
              verticalSpacing(height: 16.sp),
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCardWidget(
                      context,
                      title: "Pending Approvals".toUpperCase(),
                      subTitle: "Awaiting approval $filterType",
                      value: dashboardCount.pendingApprovals.addCommas(),
                      valueColor: AppColor.black,
                      icon: LucideIcons.clock,

                      iconColor: AppColor.primary,
                      iconBgColor: AppColor.lightBlueBg2,
                    ),
                  ),
                  horizontalSpacing(width: 16.sp),
                  Expanded(
                    child: _buildStatsCardWidget(
                      context,
                      title: "Overstaying".toUpperCase(),
                      subTitle: "Require gate-out / alert",
                      value: dashboardCount.overstaying.addCommas(),
                      valueColor: AppColor.black,
                      icon: LucideIcons.trendingUp,

                      iconColor: const Color(0xff0F766E),
                      iconBgColor: const Color(0xffD8F3EE),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCardWidget(
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
