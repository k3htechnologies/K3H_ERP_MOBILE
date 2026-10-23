import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget pendingApprovalWidget() {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      final table13 = state.userData?.table13 ?? [];
      final count = table13.isNotEmpty ? table13.first.myApprovalCount : 0;

      return Container(
        decoration: commonCardDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Approvals",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
                horizontalSpacing(width: 12),
                GestureDetector(
                  onTap: () {
                    goRouter.pushNamed(AppRoutes.myApprovalScreen);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.sp),
                          color: AppColor.primary,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "View",
                              style: AppTextStyle.ts12SB(color: AppColor.white),
                            ),
                            if (count > 0) ...[
                              horizontalSpacing(width: 4.sp),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColor.white,
                                child: Text(
                                  count > 99 ? "99+" : count.toString(),
                                  style: AppTextStyle.ts12M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
  );
}
