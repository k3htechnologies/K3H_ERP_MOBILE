// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/attendance_summary_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/enquiries_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/follow_up_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/highest_performer_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/overview_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/project_achievement_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/recent_booking_widget.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/pages/widgets/sales_filter_widget.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen>
    with SingleTickerProviderStateMixin {
  late SalesDashboardCubit _salesDashboardCubit;
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  final ValueNotifier<List<Map<String, dynamic>>> _selectedProjectNotifier =
      ValueNotifier([]);
  final ValueNotifier<String> _selectedFilterType = ValueNotifier("Monthly");
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier(null);

  late UserModel? _user;

  @override
  void initState() {
    super.initState();
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    getCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _salesDashboardCubit.getSalesDashboardList(
        context: context,
        projectId: 0,
        filterType: _selectedFilterType.value,
      );
    });
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    _user = UserModel.fromJson(userJson);
  }

  //  FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"ProjectName": value, "EmployeeId": _user!.employeeId}
              : {"EmployeeId": _user!.employeeId},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<ProjectModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.projectId,
                  "DisplayName": pr.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  void dispose() {
    _selectedFilterType.dispose();
    super.dispose();
  }

  //  FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"ProjectName": value, "EmployeeId": _user!.employeeId}
              : {"EmployeeId": _user!.employeeId},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<ProjectModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.projectId,
                  "DisplayName": pr.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _salesDashboardCubit.getSalesDashboardList(
          context: context,
          projectId:
              (_selectedProjectNotifier.value.isNotEmpty)
                  ? _selectedProjectNotifier.value.first['zAttributesId']
                  : 0,
          filterType: _selectedFilterType.value,
        );
      },
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Sales Dashboard",
          isMenuButton: true,
          authorization: AuthorizationModel(),

          showNotification: true,
        ),
        body: BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
          builder: (context, state) {
            if (state.isLoading ?? true) {
              return Center(child: loader());
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _selectedProjectNotifier,
                      builder: (context, value, child) {
                        return CustomMultipleSelectPopup(
                          title: 'Project',
                          isMultiSelect: false,
                          hintText: "All Project",
                          initialValue: value,
                          onSelected: (value) {
                            _selectedProjectNotifier.value = value;
                            _salesDashboardCubit.getSalesDashboardList(
                              context: context,
                              projectId:
                                  (_selectedProjectNotifier.value.isNotEmpty)
                                      ? _selectedProjectNotifier
                                          .value
                                          .first['zAttributesId']
                                      : 0,
                              filterType: _selectedFilterType.value,
                            );
                          },
                          dataFetchCallBack: _fetchProjects,
                        );
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _selectedFilterType,
                      builder: (context, selectedTab, child) {
                        return SalesFilterWidget(
                          selectedTab: selectedTab,
                          initialFromDate: _fromDateNotifier.value,
                          initialToDate: _toDateNotifier.value,
                          onTap: (tab) async {
                            _selectedFilterType.value = tab;
                            await _salesDashboardCubit
                                .clearSalesDashboardData();
                            if (tab.toLowerCase() != 'datewise') {
                              await _salesDashboardCubit.getSalesDashboardList(
                                context: context,
                                projectId:
                                    (_selectedProjectNotifier.value.isNotEmpty)
                                        ? _selectedProjectNotifier
                                            .value
                                            .first['zAttributesId']
                                        : 0,
                                filterType: _selectedFilterType.value,
                              );
                            } else {
                              _fromDateNotifier.value = null;
                              _toDateNotifier.value = null;
                            }
                          },
                          onDateChanged: (from, to) {
                            _fromDateNotifier.value = from;
                            _toDateNotifier.value = to;

                            if (to != null) {
                              _salesDashboardCubit.getSalesDashboardList(
                                context: context,
                                projectId:
                                    (_selectedProjectNotifier.value.isNotEmpty)
                                        ? _selectedProjectNotifier
                                            .value
                                            .first['zAttributesId']
                                        : 0,
                                filterType: _selectedFilterType.value,
                                fromDate: from,
                                toDate: to,
                              );
                            }
                          },
                        );
                      },
                    ),
                    verticalSpacing(height: 12.h),
                    OverviewWidget(),
                    verticalSpacing(height: 12.h),
                    AttendanceSummaryWidget(),
                    verticalSpacing(height: 12.h),
                    RecentBookingWidget(context: context),
                    verticalSpacing(height: 12.h),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _fromDateNotifier,
                        _toDateNotifier,
                      ]),
                      builder: (context, _) {
                        return ProjectAchievementWidget(
                          selectedFilterType: _selectedFilterType.value,
                          fromDate: _fromDateNotifier.value,
                          toDate: _toDateNotifier.value,
                        );
                      },
                    ),
                    verticalSpacing(height: 12.h),
                    HighestPerformerWidget(),
                    verticalSpacing(height: 12.h),
                    EnquiriesWidget(),
                    verticalSpacing(height: 12.h),
                    AwaitingFollowUpsWidget(),
                    verticalSpacing(height: 12.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DashboardFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const DashboardFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Today", "Weekly", "Monthly", "Datewise", "Overall"];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xffEDEDF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffC3C6D5), width: 0.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10.0,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(tabs.length, (index) {
            final selected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                padding: const EdgeInsets.symmetric(
                  vertical: 3.0,
                  horizontal: 9,
                ),
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? AppColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style:
                        selected
                            ? AppTextStyle.ts14SB(color: AppColor.white)
                            : AppTextStyle.ts12R(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
