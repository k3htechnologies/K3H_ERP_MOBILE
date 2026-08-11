import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildEventsAndMoreWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final userData = state.userData;

      final table8List = userData?.table8;
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
                    "Events & More",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpacing(height: 6),
            Divider(
              thickness: 0.3,
              color: AppColor.black.withValues(alpha: 0.50),
            ),
            verticalSpacing(height: 6),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Upcoming Birthday",
                    style: AppTextStyle.ts14SB(color: AppColor.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (table8List != null && table8List.isNotEmpty) ...[
              ListView.builder(
                itemCount: table8List.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var upcomingBirthday = table8List[index];
                  return ListTile(
                    isThreeLine: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColor.primary,
                      child: Text(
                        getInitials(upcomingBirthday.fullName),
                        style: AppTextStyle.ts16B(color: AppColor.white),
                      ),
                    ),
                    title: Text(
                      upcomingBirthday.fullName,
                      style: AppTextStyle.ts14M(),
                    ),
                    subtitle: Text(
                      upcomingBirthday.departmentName,
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                    trailing: Text(
                      formatDateToDayMonthOnly(upcomingBirthday.dateOfBirth),
                      style: AppTextStyle.ts14R(),
                    ),
                  );
                },
              ),
            ] else ...[
              Center(
                child: Text(
                  "No Upcoming Birthdays",
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],

            verticalSpacing(height: 6),

            Divider(
              thickness: 0.3,
              color: AppColor.black.withValues(alpha: 0.50),
            ),

            verticalSpacing(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Upcoming Events",
                    style: AppTextStyle.ts14SB(color: AppColor.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                "Coming Soon",
                style: AppTextStyle.ts12M(
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
