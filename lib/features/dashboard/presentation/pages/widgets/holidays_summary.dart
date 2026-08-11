import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildHolidaySummaryWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }

      final userData = state.userData;

      final table6List = userData?.table6;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Holiday",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpacing(height: 12.0),
            if (table6List != null) ...[
              ListView.builder(
                itemCount: table6List.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, int index) {
                  final holiday = table6List[index];
                  var daysRemainingText =
                      holiday.daysRemaining == 0
                          ? "Today"
                          : "In ${holiday.daysRemaining} days";
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: AppColor.lightPurple.withValues(alpha: 0.50),
                      border: Border.all(width: 1, color: AppColor.lightPurple),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(holiday.holidayName, style: AppTextStyle.ts14M()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDateToDayMonth(holiday.holidayDate),
                              style: AppTextStyle.ts12R(
                                color: AppColor.black.withValues(alpha: 0.50),
                              ),
                            ),
                            Text(
                              daysRemainingText,
                              style: AppTextStyle.ts10M().copyWith(
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
