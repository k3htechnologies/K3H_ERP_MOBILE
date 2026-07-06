import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  const AttendanceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final table7 =
            state.salesDashboardList.isNotEmpty
                ? state.salesDashboardList.first.table4
                : [];

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
              (table7.isNotEmpty)
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
                                  await goRouter.pushNamed(
                                    AppRoutes.employeeAttendanceScreen,
                                    queryParameters: {
                                      "type": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "PRESENT",
                                        ),
                                      ),
                                      "employeeList": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            (state
                                                    .salesDashboardList
                                                    .first
                                                    .table7)
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
                                  await goRouter.pushNamed(
                                    AppRoutes.employeeAttendanceScreen,
                                    queryParameters: {
                                      "type": Uri.encodeComponent(
                                        EncryptionManager.encryptData("ABSENT"),
                                      ),
                                      "employeeList": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            (state
                                                    .salesDashboardList
                                                    .first
                                                    .table7)
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
                                  await goRouter.pushNamed(
                                    AppRoutes.employeeAttendanceScreen,
                                    queryParameters: {
                                      "type": Uri.encodeComponent(
                                        EncryptionManager.encryptData("LEAVE"),
                                      ),
                                      "employeeList": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            (state
                                                    .salesDashboardList
                                                    .first
                                                    .table7)
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: noDataWidget(
                        iconSize: 100,
                        message: "No Data Found",
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
