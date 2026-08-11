import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildLeaveBalanceSummaryWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final table4List = state.userData?.table4;

      final table5List = state.userData?.table5;

      final totalLeaves =
          table4List?.fold<int>(0, (sum, item) => sum + (item.totalLeaves)) ??
          0;

      final usedLeaves =
          table4List?.fold<double>(0, (sum, item) => sum + (item.usedLeaves)) ??
          0;

      final remainingLeaves =
          table4List?.fold<double>(
            0,
            (sum, item) => sum + (item.remainingLeaves),
          ) ??
          0;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              "Leave Balance",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.50),
              ),
            ),
            _leaveRow(title: "Total Leaves", value: "$totalLeaves"),
            _leaveRow(title: "Used Leaves", value: "$usedLeaves"),
            _leaveRow(title: "Pending Leaves", value: "$remainingLeaves"),

            Text(
              "Upcoming Approved",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),

            if (table5List != null && table5List.isNotEmpty) ...{
              ListView.builder(
                itemCount: table5List.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final upcomingLeaves = table5List[index];
                  final item = upcomingLeaves;
                  final startDate = DateTime.parse(item.startDate.toString());
                  final endDate = DateTime.parse(item.endDate.toString());

                  final formattedStart = DateFormat('dd MMM').format(startDate);
                  final formattedEnd = DateFormat(
                    'dd MMM, yyyy',
                  ).format(endDate);
                  return _buildUpcomingAttendanceWidget(
                    title: upcomingLeaves.leaveTypeName,
                    value: "",
                    subtitle:
                        "$formattedStart - $formattedEnd (${upcomingLeaves.noOfDays} days)",
                    bgColor: Color(0xFFEFFAF3),
                    borderColor: Color(0xFFB7E4C7),
                  );
                },
              ),
            } else ...{
              verticalSpacing(height: 2),
              Center(
                child: Text(
                  "No Data Found",
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
              verticalSpacing(height: 2),
            },
          ],
        ),
      );
    },
  );
}

Widget _leaveRow({required String title, required String value}) {
  return Row(
    children: [
      Expanded(flex: 6, child: Text(title, style: AppTextStyle.ts14M())),
      SizedBox(
        width: 24,
        child: Center(child: Text(":", style: AppTextStyle.ts14M())),
      ),
      Expanded(
        flex: 2,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(value, style: AppTextStyle.ts16SB()),
        ),
      ),
    ],
  );
}

Widget _buildUpcomingAttendanceWidget({
  String? title,
  String? value,
  String? subtitle,
  Color? bgColor,
  Color? borderColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    margin: EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor!, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title!, style: AppTextStyle.ts14M(color: AppColor.black)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value!, style: AppTextStyle.ts16SB(color: Color(0xFF2E7D32))),
            if (subtitle != null) ...[
              Text(subtitle, style: AppTextStyle.ts10R(color: AppColor.black)),
            ],
          ],
        ),
      ],
    ),
  );
}
