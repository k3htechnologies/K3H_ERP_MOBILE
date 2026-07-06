import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final projectAchievementData =
            state.salesDashboardList.isNotEmpty
                ? state.salesDashboardList.first.projectAchievementData
                : [];
        final enquiryFollowUpData =
            state.salesDashboardList.isNotEmpty
                ? state.salesDashboardList.first.table1
                : [];
        final totalRevenue = projectAchievementData.fold(
          0.0,
          (sum, item) => sum + (item.totalRevenue),
        );

        final totalWalkins = projectAchievementData.fold(
          0.0,
          (sum, item) => sum + (item.totalWalkins),
        );

        final overdueCount = enquiryFollowUpData.fold<int>(
          0,
          (sum, item) =>
              (item.enquiryFollowUpDays.toLowerCase().contains('overdue'))
                  ? sum + 1
                  : sum,
        );

        final totalBooking = projectAchievementData.fold(
          0.0,
          (sum, item) => sum + (item.totalBooking),
        );

        final conversionPercentage =
            totalWalkins > 0
                ? "${((totalBooking / totalWalkins) * 100).toStringAsFixed(2)}%"
                : "0";
        return Column(
          spacing: 12.h,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildStatsCardWidget(
                      context,
                      title: "Total Revenue",
                      value: formatToKLCr(totalRevenue),
                      icon: LucideIcons.wallet,
                      iconColor: const Color(0xff2F6BFF),
                      iconBgColor: const Color(0xffE8F0FF),
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: _buildStatsCardWidget(
                      context,
                      title: "New Lead",
                      value: totalWalkins.addCommas(),
                      icon: LucideIcons.userPlus,

                      iconColor: const Color(0xff7C3AED),
                      iconBgColor: const Color(0xffEFE7FF),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildStatsCardWidget(
                    context,
                    title: "Overdue",
                    value: overdueCount.addCommas(),
                    icon: LucideIcons.clock,

                    iconColor: Colors.white,
                    iconBgColor: const Color(0xffC81E1E),
                  ),
                ),
                horizontalSpacing(),
                Expanded(
                  child: _buildStatsCardWidget(
                    context,
                    title: "Conversion",
                    value: conversionPercentage,
                    icon: LucideIcons.trendingUp,

                    iconColor: const Color(0xff0F766E),
                    iconBgColor: const Color(0xffD8F3EE),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCardWidget(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.05),
            blurRadius: 2,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.0),
            blurRadius: 0,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.0),
            blurRadius: 0,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30.w,
            width: 30.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 16.w),
          ),
          horizontalSpacing(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
                SizedBox(height: 6.h),
                Text(value, style: AppTextStyle.ts20SB(color: AppColor.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
