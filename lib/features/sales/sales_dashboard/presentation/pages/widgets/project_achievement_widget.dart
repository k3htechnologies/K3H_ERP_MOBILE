import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/common_sales_dashboard_widgets.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectAchievementWidget extends StatelessWidget {
  final String selectedFilterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  const ProjectAchievementWidget({
    super.key,
    required this.selectedFilterType,
    this.fromDate,
    this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        final projectAchievementList =
            state.salesDashboardList.isNotEmpty
                ? state.salesDashboardList.first.projectAchievementData
                : <ProjectAchievementReportModel>[];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Project Achievement ",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: " (${projectAchievementList.length} Records)",
                      style: AppTextStyle.ts12R(
                        color: AppColor.greyTitleAndValueColor.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              projectAchievementList.isNotEmpty
                  ? SizedBox(
                    height: 400.h,
                    child: ListView.separated(
                      itemCount: projectAchievementList.length,
                      separatorBuilder: (context, index) => verticalSpacing(),
                      itemBuilder: (context, index) {
                        final projectAchievement =
                            projectAchievementList[index];
                        return ProjectAchievementCard(
                          projectName: projectAchievement.projectName,
                          imageUrl: projectAchievement.projectPhotoURL,

                          walkIns: projectAchievement.totalWalkins.toString(),
                          revisits: projectAchievement.revisits.toString(),
                          bookings: projectAchievement.totalBooking.toString(),
                          revenue: projectAchievement.totalRevenue,

                          onCardTap: () {
                            goRouter.pushNamed(
                              AppRoutes.projectWiseSalesDashboard,
                              queryParameters: {
                                'projectId': Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    projectAchievement.projectId.toString(),
                                  ),
                                ),
                                'filterType': Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    selectedFilterType,
                                  ),
                                ),
                                'projectName': Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    projectAchievement.projectName,
                                  ),
                                ),
                                'fromDate':
                                    fromDate != null
                                        ? Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            fromDate!.toIso8601String(),
                                          ),
                                        )
                                        : '',
                                'toDate':
                                    toDate != null
                                        ? Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            toDate!.toIso8601String(),
                                          ),
                                        )
                                        : '',
                              },
                            );
                          },

                          onWalkInsTap: () {
                            _navigateToAchievementDrillDown(
                              achievementDrillDownType:
                                  AchievementDrillDownType.enquiry,
                              columnName: "TOTAL WALKINS",
                              context: context,
                              projectId: projectAchievement.projectId,
                              projectName: projectAchievement.projectName,
                            );
                          },

                          onRevisitsTap: () {
                            _navigateToAchievementDrillDown(
                              achievementDrillDownType:
                                  AchievementDrillDownType.enquiry,
                              columnName: "REVISITS",
                              context: context,
                              projectId: projectAchievement.projectId,
                              projectName: projectAchievement.projectName,
                            );
                          },

                          onBookingsTap: () {
                            _navigateToAchievementDrillDown(
                              achievementDrillDownType:
                                  AchievementDrillDownType.booking,
                              columnName: "TOTAL BOOKING",
                              context: context,
                              projectId: projectAchievement.projectId,
                              projectName: projectAchievement.projectName,
                            );
                          },
                        );
                      },
                    ),
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

  void _navigateToAchievementDrillDown({
    int? projectId,
    String? projectName,
    required String columnName,
    required BuildContext context,
    required AchievementDrillDownType achievementDrillDownType,
  }) async {
    goRouter.pushNamed(
      AppRoutes.achievementDrillDownReport,
      queryParameters: {
        if (projectId != null)
          'projectId': Uri.encodeQueryComponent(
            EncryptionManager.encryptData(projectId.toString()),
          ),

        'tabName': Uri.encodeQueryComponent(
          EncryptionManager.encryptData("Project"),
        ),
        'columnName': Uri.encodeQueryComponent(
          EncryptionManager.encryptData(columnName),
        ),
        if (projectName != null)
          'projectName': Uri.encodeQueryComponent(
            EncryptionManager.encryptData(projectName),
          ),
        'filterType': Uri.encodeQueryComponent(
          EncryptionManager.encryptData(selectedFilterType),
        ),
        'achievementDrillDownType': Uri.encodeQueryComponent(
          EncryptionManager.encryptData(achievementDrillDownType.name),
        ),
        'fromDate':
            fromDate != null
                ? Uri.encodeQueryComponent(
                  EncryptionManager.encryptData(fromDate!.toIso8601String()),
                )
                : '',
        'toDate':
            toDate != null
                ? Uri.encodeQueryComponent(
                  EncryptionManager.encryptData(toDate!.toIso8601String()),
                )
                : '',
      },
    );
  }
}

class ProjectAchievementCard extends StatelessWidget {
  const ProjectAchievementCard({
    super.key,
    required this.projectName,
    required this.imageUrl,
    required this.walkIns,
    required this.revisits,
    required this.bookings,
    required this.revenue,
    this.onCardTap,
    this.onWalkInsTap,
    this.onRevisitsTap,
    this.onBookingsTap,
  });

  final String projectName;
  final String imageUrl;

  final String walkIns;
  final String revisits;
  final String bookings;
  final double revenue;

  final VoidCallback? onCardTap;
  final VoidCallback? onWalkInsTap;
  final VoidCallback? onRevisitsTap;
  final VoidCallback? onBookingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withValues(alpha: .08),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 137.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NetworkImageWidget(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),

                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Color.fromRGBO(255, 255, 255, 0.55),
                            Color.fromRGBO(255, 255, 255, 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 52,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .18),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: .15),
                                width: .5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: InkWell(
                      onTap: onCardTap,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              projectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.ts18SB(color: AppColor.white),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              spacing: 12.h,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InfoColumn(
                        title: "Walk-ins",
                        value: walkIns,
                        onValueTap: onWalkInsTap,
                      ),
                    ),

                    Expanded(
                      child: InfoColumn(
                        title: "Revisits",
                        value: revisits,
                        onValueTap: onRevisitsTap,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: InfoColumn(
                        title: "Bookings",
                        value: bookings,
                        onValueTap: onBookingsTap,
                      ),
                    ),

                    Expanded(
                      child: InfoColumn(
                        title: "Revenue (₹)",
                        value: revenue.toIndianCurrency(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InfoColumn(
                        title: "Revenue (CR)",
                        value: formatToKLCr(revenue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
