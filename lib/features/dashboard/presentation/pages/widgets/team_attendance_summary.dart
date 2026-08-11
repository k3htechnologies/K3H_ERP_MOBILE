// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget buildTeamAttendanceSummaryWidget(BuildContext context) {
  return BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      if (state.isLoading == true) {
        return Center(child: loader());
      }
      final userData = state.userData;

      final table7 = userData?.table7;

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
                    "Team Attendance Summary",
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            (table7 != null && table7.isNotEmpty)
                ? CommonRadialChart(
                  items: [
                    RadialChartItem(
                      title: "Present",
                      value: table7.first.presentCount,
                      color: AppColor.primary,
                      onValueTap:
                          table7.first.presentCount == 0
                              ? () {}
                              : () async {
                                await context
                                    .read<DashboardCubit>()
                                    .resetUnits();
                                await goRouter.pushNamed(
                                  AppRoutes.employeeAttendanceScreen,

                                  queryParameters: {
                                    "type": Uri.encodeComponent(
                                      EncryptionManager.encryptData("PRESENT"),
                                    ),
                                    "employeeList": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          (context
                                                      .read<DashboardCubit>()
                                                      .state
                                                      .userData
                                                      ?.table0 ??
                                                  [])
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "Present Employees",
                                      ),
                                    ),
                                  },
                                );
                              },
                    ),
                    RadialChartItem(
                      title: "Absent",
                      value: table7.first.absentCount,
                      color: AppColor.blue,
                      onValueTap:
                          table7.first.absentCount == 0
                              ? () {}
                              : () async {
                                await context
                                    .read<DashboardCubit>()
                                    .resetUnits();
                                await goRouter.pushNamed(
                                  AppRoutes.employeeAttendanceScreen,
                                  queryParameters: {
                                    "type": Uri.encodeComponent(
                                      EncryptionManager.encryptData("ABSENT"),
                                    ),
                                    "employeeList": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          (context
                                                      .read<DashboardCubit>()
                                                      .state
                                                      .userData
                                                      ?.table0 ??
                                                  [])
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "Absent Employees",
                                      ),
                                    ),
                                  },
                                );
                              },
                    ),
                    RadialChartItem(
                      title: "Leave",
                      value: table7.first.onLeaveCount,
                      color: AppColor.grey50,
                      onValueTap:
                          table7.first.onLeaveCount == 0
                              ? () {}
                              : () async {
                                await context
                                    .read<DashboardCubit>()
                                    .resetUnits();
                                await goRouter.pushNamed(
                                  AppRoutes.employeeAttendanceScreen,

                                  queryParameters: {
                                    "type": Uri.encodeComponent(
                                      EncryptionManager.encryptData("LEAVE"),
                                    ),
                                    "employeeList": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          (context
                                                      .read<DashboardCubit>()
                                                      .state
                                                      .userData
                                                      ?.table0 ??
                                                  [])
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "Leave Employees",
                                      ),
                                    ),
                                  },
                                );
                              },
                    ),
                  ],
                )
                : Center(
                  child: Text(
                    "No Team Attendance Summary",
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
