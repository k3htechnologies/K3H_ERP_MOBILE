import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget buildWorkingHourSummaryWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final userData = state.userData;
      final table2 = userData?.table2;
      final lateIn =
          userData?.table12
              .where((m) => m.attendanceStatus == "Late In")
              .length;
      final earlyLogOutEmployee =
          userData?.table12
              .where((m) => m.attendanceStatus == "Early Logout")
              .length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Working Hour Summary",
              style: AppTextStyle.ts14M(
                color: AppColor.black.withValues(alpha: 0.50),
              ),
            ),

            verticalSpacing(height: 12.0),

            if (table2?.isNotEmpty == true) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  summaryOverallWidget(
                    title: "This Week",
                    subTitle: formatDecimalHours(table2!.first.thisWeekHours),
                  ),
                  summaryOverallWidget(
                    title: "Overtime",
                    subTitle: formatDecimalHours(table2.first.overtimeHours),
                    color: AppColor.yellow,
                  ),
                  summaryOverallWidget(
                    title: "Avg Daily",
                    subTitle: formatDecimalHours(table2.first.avgDailyHours),
                  ),
                ],
              ),
              verticalSpacing(height: 12.0),
              _buildDayWiseProgress(),
              Divider(height: 1, color: AppColor.grey2),
              verticalSpacing(height: 10.0),
              Row(
                spacing: 10,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Icon(
                        LucideIcons.triangleAlert,
                        size: 18,
                        color: AppColor.red,
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Late Login: ",
                          style: AppTextStyle.ts12M(color: AppColor.grey),
                          children: [
                            TextSpan(
                              text: "$lateIn days",
                              style: AppTextStyle.ts12M(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(
                        LucideIcons.clockAlert,
                        size: 18,
                        color: AppColor.rustOrange,
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Early Logout: ",
                          style: AppTextStyle.ts12M(color: AppColor.grey),
                          children: [
                            TextSpan(
                              text: "$earlyLogOutEmployee days",
                              style: AppTextStyle.ts12M(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Text(
                  "No Data Found",
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.6),
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

Widget summaryOverallWidget({String? title, String? subTitle, Color? color}) {
  return Column(
    spacing: 4,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title!, style: AppTextStyle.ts14M()),
      Text(subTitle!, style: AppTextStyle.ts16SB(color: color)),
    ],
  );
}

Widget _buildDayWiseProgress() {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final userData = state.userData;

      if (userData == null || userData.table3.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          decoration: commonCardDecoration(),
          child: const Center(child: Text("No Daily Attendance Data")),
        );
      }

      final table3List = userData.table3;
      final table1 = userData.table1.isNotEmpty ? userData.table1.first : null;
      Duration targetDuration = const Duration(hours: 9);

      if (table1 != null &&
          table1.shiftBeginTime.isNotEmpty &&
          table1.shiftEndTime.isNotEmpty &&
          table1.shiftBeginTime != "{}" &&
          table1.shiftEndTime != "{}") {
        try {
          final startParts = table1.shiftBeginTime.split(':');
          final endParts = table1.shiftEndTime.split(':');

          final startHour = int.tryParse(startParts[0]) ?? 0;
          final startMin =
              startParts.length > 1 ? int.tryParse(startParts[1]) ?? 0 : 0;

          final endHour = int.tryParse(endParts[0]) ?? 0;
          final endMin =
              endParts.length > 1 ? int.tryParse(endParts[1]) ?? 0 : 0;

          final now = DateTime.now();

          final startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            startHour,
            startMin,
          );

          final endDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            endHour,
            endMin,
          );

          final diff = endDateTime.difference(startDateTime);

          if (!diff.isNegative && diff.inSeconds > 0) {
            targetDuration = diff;
          }
        } catch (_) {}
      }

      return Column(
        children:
            table3List.map((dayData) {
              final workedDuration = parseWorkingHoursToDuration(
                dayData.workingHours,
              );

              return DayWorkProgress(
                day: dayData.dayName,
                worked: workedDuration,
                target: targetDuration,
                isToday: isCurrentDay(dayData.dayName),
              );
            }).toList(),
      );
    },
  );
}

class DayWorkProgress extends StatelessWidget {
  final String day;
  final Duration worked;
  final Duration target;
  final bool isToday;

  const DayWorkProgress({
    super.key,
    required this.day,
    required this.worked,
    required this.target,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        target.inSeconds == 0
            ? 0.0
            : (worked.inSeconds / target.inSeconds).clamp(0.0, 1.0);

    String format(Duration d) {
      final hours = d.inHours;
      final minutes = d.inMinutes % 60;
      final seconds = d.inSeconds % 60;

      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: isToday ? AppTextStyle.ts14SB() : AppTextStyle.ts14R(),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 22,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.lightGreyBackground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Container(
                  height: 22,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFF1E40AF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          "${format(worked)} / ${format(target)} hrs",
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}
