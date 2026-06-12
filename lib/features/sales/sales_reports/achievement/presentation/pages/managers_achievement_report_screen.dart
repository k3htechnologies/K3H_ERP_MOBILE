import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../../style/app_color.dart';
import '../cubit/achievement.state.dart';
import '../cubit/achievement_cubit.dart';

class ManagerAchievementReportScreen extends StatefulWidget {
  final String type;
  final String filterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ProjectAchievementReportModel projectAchievementReportModel;
  const ManagerAchievementReportScreen({
    super.key,
    required this.type,
    required this.filterType,
    required this.fromDate,
    required this.toDate,
    required this.projectAchievementReportModel,
  });

  @override
  State<ManagerAchievementReportScreen> createState() =>
      _ManagerAchievementReportScreenState();
}

class _ManagerAchievementReportScreenState
    extends State<ManagerAchievementReportScreen> {
  late AchievementCubit _achievementCubit;
  // PAGINATION
  late ScrollController _closingScrollController;
  Timer? _closingDebounce;
  late ScrollController _sourcingScrollController;
  Timer? _sourcingDebounce;
  late TextEditingController _searchTextC;
  late AuthorizationModel _routeAuthorizationModel;

  @override
  void initState() {
    _achievementCubit = context.read<AchievementCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.achievementReport]!;
    _searchTextC = TextEditingController();
    _onScroll();
    _initializeData();
    super.initState();
  }

  void _initializeData() {
    if (widget.type.toLowerCase() == "closing") {
      _achievementCubit.getManagerClosingAchievementReport(
        context: context,
        pageNumber: 1,
        projectId: widget.projectAchievementReportModel.projectId,
        filterType: widget.filterType,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
      );
    } else if (widget.type.toLowerCase() == "sourcing") {
      _achievementCubit.getManagerSourcingAchievementReport(
        context: context,
        pageNumber: 1,
        projectId: widget.projectAchievementReportModel.projectId,
        filterType: widget.filterType,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
      );
    }
  }

  void _onScroll() {
    _closingScrollController = ScrollController();
    _closingScrollController.addListener(() {
      if (_closingScrollController.position.pixels >=
              _closingScrollController.position.maxScrollExtent - 100 &&
          !_achievementCubit.state.isLoading! &&
          _achievementCubit.state.managerClosingAchievementReportList.length <
              _achievementCubit
                  .state
                  .managerClosingAchievementTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_closingDebounce?.isActive ?? false) _closingDebounce?.cancel();
        _closingDebounce = Timer(const Duration(milliseconds: 300), () {
          _achievementCubit.getManagerClosingAchievementReport(
            context: context,
            pageNumber:
                _achievementCubit
                    .state
                    .managerClosingAchievementReportPageNumber +
                1,
            projectId: widget.projectAchievementReportModel.projectId,
            fromDate: widget.fromDate,
            toDate: widget.toDate,
            filterType: widget.filterType,
          );
        });
      }
    });
    _sourcingScrollController = ScrollController();
    _sourcingScrollController.addListener(() {
      if (_sourcingScrollController.position.pixels >=
              _sourcingScrollController.position.maxScrollExtent - 100 &&
          !_achievementCubit.state.isLoading! &&
          _achievementCubit.state.managerSourcingAchievementReportList.length <
              _achievementCubit
                  .state
                  .managerSourcingAchievementTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_sourcingDebounce?.isActive ?? false) _sourcingDebounce?.cancel();
        _sourcingDebounce = Timer(const Duration(milliseconds: 300), () {
          _achievementCubit.getManagerSourcingAchievementReport(
            context: context,

            pageNumber:
                _achievementCubit
                    .state
                    .managerSourcingAchievementReportPageNumber +
                1,
            projectId: widget.projectAchievementReportModel.projectId,
            filterType: widget.filterType,
            fromDate: widget.fromDate,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterManagerAchievement(
    BuildContext context,
  ) async {
    final state = _achievementCubit.state;

    String? selectedDirection =
        state.managerCurrentSortColumn == "Employee Name"
            ? state.managerCurrentSortDirection.isNotEmpty
                ? state.managerCurrentSortDirection
                : null
            : null;

    final String? initialDirection = selectedDirection;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        applyEnabled.value = selectedDirection != initialDirection;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Achievement",

      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });

            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Employee Name", style: AppTextStyle.ts14M()),

                verticalSpacing(),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),

                    horizontalSpacing(),

                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        selectedDirection = null;

        _achievementCubit.applyManagerAchievementFilterAndSort(
          context: context,
          projectId: widget.projectAchievementReportModel.projectId,
          sortColumn: '',
          sortDirection: '',

          activeSecondaryTabIndex:
              widget.type.toLowerCase() == "closing"
                  ? 0
                  : widget.type.toLowerCase() == "sourcing"
                  ? 1
                  : 0,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          filterType: widget.filterType,
        );
      },

      onApply: () {
        applied = true;

        _achievementCubit.applyManagerAchievementFilterAndSort(
          context: context,
          sortColumn: "Employee Name",
          sortDirection: selectedDirection,
          activeSecondaryTabIndex:
              widget.type.toLowerCase() == "closing"
                  ? 0
                  : widget.type.toLowerCase() == "sourcing"
                  ? 1
                  : 0,
          filterType: widget.filterType,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          projectId: widget.projectAchievementReportModel.projectId,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied) {
      selectedDirection = initialDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportTabIndex =
        widget.type.toLowerCase() == "closing"
            ? 0
            : widget.type.toLowerCase() == "sourcing"
            ? 1
            : 0;
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle:
            widget.type == 'closing' ? 'Closing Managers' : 'Sourcing Managers',
        authorization: _routeAuthorizationModel,
        showMenuIcon: false,
        textController: _searchTextC,
        searchHintText: "Search By Employee Name",
        isFilterOn: true,
        onFilterTap: () => _showBottomSheetToFilterManagerAchievement(context),
        onSearchSubmit: (String value) {
          _achievementCubit.managerSearch(
            context: context,
            searchText: value,
            filterType: widget.filterType,
            reportTabIndex: reportTabIndex,
            projectId: widget.projectAchievementReportModel.projectId,
          );
        },
        onExportCallback: (v) {
          _achievementCubit.exportManagerExcelPdf(
            context: context,
            exportType: v,
            filterType: widget.filterType,
            reportTabIndex: reportTabIndex,
            projectId: widget.projectAchievementReportModel.projectId,
          );
        },
      ),
      body:
          widget.type.toLowerCase() == "closing"
              ? _buildClosingAchievementTab()
              : widget.type.toLowerCase() == "sourcing"
              ? _buildSourcingAchievementTab()
              : const SizedBox.shrink(),
    );
  }

  Widget _buildClosingAchievementTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showSiteSelectedWidget(
            projectName: widget.projectAchievementReportModel.projectName,
          ),
          Expanded(
            child: BlocBuilder<AchievementCubit, AchievementState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.managerClosingAchievementReportList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.managerClosingAchievementReportList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No closing achievement data available",
                    ),
                  );
                }
                return ListView.builder(
                  controller: _closingScrollController,
                  shrinkWrap: true,
                  itemCount:
                      state.managerClosingAchievementReportList.length + 1,
                  itemBuilder: (context, index) {
                    if (index ==
                        state.managerClosingAchievementReportList.length) {
                      return state.managerClosingAchievementReportList.length <
                              state.managerClosingAchievementTotalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    final achievement =
                        state.managerClosingAchievementReportList[index];
                    return Container(
                      decoration: commonCardDecoration(),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: achievement.employeeName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\n${achievement.designationName}',
                                    style: AppTextStyle.ts12R(
                                      color:
                                          AppColor
                                              .textSecondary, // adjust color as needed
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// WALKINS
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: buildRowTitleValue(
                                title: "Total Walkins",
                                value: achievement.totalWalkins.addCommas(),
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                              childrenPadding: EdgeInsets.zero,
                              children: [
                                buildRowTitleValue(
                                  title: "By CP",
                                  value: achievement.walkinsByCp.addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "Direct",
                                  value: achievement.walkinsDirect.addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "Fresh Visits",
                                  value:
                                      achievement.totalFreshVisits.addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "Revisits",
                                  value: achievement.revisits.addCommas(),
                                ),
                              ],
                            ),
                            Divider(height: 1, color: AppColor.grey50),

                            /// BOOKINGS
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: buildRowTitleValue(
                                title: "Total Booking",
                                value: achievement.totalBooking.addCommas(),
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                              childrenPadding: EdgeInsets.zero,
                              children: [
                                buildRowTitleValue(
                                  title: "By CP",
                                  value: achievement.bookingByCp.addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "Direct",
                                  value: achievement.bookingDirect.addCommas(),
                                ),
                              ],
                            ),

                            Divider(height: 1, color: AppColor.grey50),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: buildRowTitleValue(
                                title: "Total Revenue",
                                singleLine: false,
                                value:
                                    (achievement.totalRevenue)
                                        .toIndianCurrency(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcingAchievementTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showSiteSelectedWidget(
            projectName: widget.projectAchievementReportModel.projectName,
          ),
          Expanded(
            child: BlocBuilder<AchievementCubit, AchievementState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.managerSourcingAchievementReportList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.managerSourcingAchievementReportList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No sourcing achievement data available",
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  controller: _sourcingScrollController,
                  itemCount:
                      state.managerSourcingAchievementReportList.length + 1,
                  itemBuilder: (context, index) {
                    if (index ==
                        state.managerSourcingAchievementReportList.length) {
                      return state.managerSourcingAchievementReportList.length <
                              state
                                  .managerSourcingAchievementTotalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    final achievement =
                        state.managerSourcingAchievementReportList[index];
                    return Container(
                      decoration: commonCardDecoration(),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: achievement.employeeName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\n${achievement.designationName}',
                                    style: AppTextStyle.ts12R(
                                      color:
                                          AppColor
                                              .textSecondary, // adjust color as needed
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// WALKINS
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                              title: buildRowTitleValue(
                                title: "Walkins",
                                value: achievement.walkinsByCp.addCommas(),
                              ),
                              children: [
                                buildRowTitleValue(
                                  title: "By CP",
                                  value: achievement.walkinsByCp.addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "Fresh Visits",
                                  value: achievement.freshVisits.addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "Revisits",
                                  value: achievement.revisits.addCommas(),
                                ),
                              ],
                            ),

                            Divider(height: 1, color: AppColor.grey50),
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                              title: buildRowTitleValue(
                                title: "Total Meetings",
                                value: achievement.totalMeetings.addCommas(),
                              ),
                              children: [
                                buildRowTitleValue(
                                  title: "OBM (Fresh Visits)",
                                  value:
                                      achievement.totalObmFreshVisits
                                          .addCommas(),
                                ),
                                buildRowTitleValue(
                                  title: "OBM (Revisits)",
                                  value:
                                      achievement.totalObmRevisits.addCommas(),
                                ),
                              ],
                            ),
                            Divider(height: 1, color: AppColor.grey50),
                            ExpansionTile(
                              enabled: false,
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              showTrailingIcon: false,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                              title: buildRowTitleValue(
                                title: "IBM",
                                value: achievement.totalIbm.addCommas(),
                              ),
                            ),
                            Divider(height: 1, color: AppColor.grey50),
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              enabled: false,
                              showTrailingIcon: false,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              trailing: const Icon(Icons.keyboard_arrow_down),
                              title: buildRowTitleValue(
                                title: "Bookings",
                                value: achievement.bookings.addCommas(),
                              ),
                            ),
                            Divider(height: 1, color: AppColor.grey50),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: buildRowTitleValue(
                                title: "Total Revenue",
                                singleLine: false,
                                value:
                                    achievement.totalRevenue.toIndianCurrency(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
