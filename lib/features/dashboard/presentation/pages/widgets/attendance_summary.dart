import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildAttendanceSummaryWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final userData = state.userData;
      final table1 = userData?.table1.first;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Attendance Summary",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpacing(height: 12.0),
            if (table1 != null) ...[
              Column(
                children: [
                  AttendanceStatCard(
                    title: "Present Days",
                    value: table1.presentDays,
                    subtitle: "This Month",
                    bgColor: Color(0xFFEFFAF3),
                    borderColor: Color(0xFFB7E4C7),
                    valueColor: Color(0xFF2E7D32),
                  ),
                  verticalSpacing(height: 12.0),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: AttendanceStatCard(
                            title: "Avg Login Time",
                            value: formatApiTimeToAmPm(table1.avgLoginTime),
                            bgColor: Color(0xFFFFF6ED),
                            borderColor: Color(0xFFFFD8B5),
                            valueColor: Color(0xFFE65100),
                          ),
                        ),
                        horizontalSpacing(width: 12.0),
                        Expanded(
                          child: AttendanceStatCard(
                            title: "Shift Pattern",
                            value:
                                "${dateFormatterHourOnly(table1.shiftBeginTime)} - ${dateFormatterHourOnly(table1.shiftEndTime)}",
                            bgColor: Color(0xFFF4F0FF),
                            borderColor: Color(0xFFD9CCFF),
                            valueColor: Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Text(
                  "No Data Found",
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class AttendanceStatCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final String? subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color valueColor;

  const AttendanceStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.valueColor,
  });

  String _formatValue(dynamic val) {
    if (val == null) return "-";
    if (val is Map && val.isEmpty) return "-";
    if (val is double) {
      if (val == val.toInt()) {
        return val.toInt().toString();
      }
      return val.toStringAsFixed(2);
    }
    if (val is int) return val.toString();
    if (val is DateTime) {
      return "${val.hour.toString().padLeft(2, '0')}:${val.minute.toString().padLeft(2, '0')}";
    }
    if (val is String) {
      if (val.isEmpty || val == "{}") return "-";
      return val;
    }
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final formattedValue = _formatValue(value);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            title,
            style: AppTextStyle.ts14SB(
              color: AppColor.black.withValues(alpha: 0.45),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  formattedValue,
                  style: AppTextStyle.ts16SB(color: valueColor),
                  maxLines: 2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    subtitle!,
                    style: AppTextStyle.ts10R(color: valueColor),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
