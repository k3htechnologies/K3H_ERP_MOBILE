import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../../style/app_color.dart';
import '../cubit/achievement.state.dart';
import '../cubit/achievement_cubit.dart';

class ManagerAchievementReport extends StatefulWidget {
  final String type;
  final String filterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ProjectAchievementReportModel projectAchievementReportModel;
  const ManagerAchievementReport({
    super.key,
    required this.type,
    required this.filterType,
    required this.fromDate,
    required this.toDate,
    required this.projectAchievementReportModel,
  });

  @override
  State<ManagerAchievementReport> createState() =>
      _ManagerAchievementReportState();
}

class _ManagerAchievementReportState extends State<ManagerAchievementReport> {
  late AchievementCubit _achievementCubit;
  // PAGINATION
  late ScrollController _closingScrollController;
  Timer? _closingDebounce;
  late ScrollController _sourcingScrollController;
  Timer? _sourcingDebounce;
  late TextEditingController _searchTextC;

  @override
  void initState() {
    _achievementCubit = context.read<AchievementCubit>();
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
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            widget.type == 'closing' ? 'Closing Managers' : 'Sourcing Managers',
        authorization: AuthorizationModel(),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Project : ",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      TextSpan(
                        text: widget.projectAchievementReportModel.projectName,
                        style: AppTextStyle.ts14SB(color: AppColor.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildSearchBar(),
          verticalSpacing(height: 5),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.employeeName,
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                          buildRowTitleValue(
                            title: "Designation ",
                            value: achievement.designationName,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Walkins By CP",
                            value: addCommasToInteger(
                              achievement.walkinsByCp.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Walkins Direct",
                            value: addCommasToInteger(
                              achievement.walkinsDirect.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Walkins",
                            value: addCommasToInteger(
                              achievement.totalWalkins.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Revisits",
                            value: addCommasToInteger(
                              achievement.revisits.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Fresh Visits",
                            value: addCommasToInteger(
                              achievement.totalFreshVisits.toDouble(),
                              withoutSign: true,
                            ),
                          ),

                          buildRowTitleValue(
                            title: "Booking By CP",
                            value: addCommasToInteger(
                              achievement.bookingByCp.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Booking Direct",
                            value: addCommasToInteger(
                              achievement.bookingDirect.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Booking",
                            value: addCommasToInteger(
                              achievement.totalBooking.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Revenue",
                            singleLine: false,
                            value: addCommasToInteger(achievement.totalRevenue),
                          ),
                        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Project : ",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      TextSpan(
                        text: widget.projectAchievementReportModel.projectName,
                        style: AppTextStyle.ts14SB(color: AppColor.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildSearchBar(),
          verticalSpacing(height: 5),
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
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.employeeName,
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                          buildRowTitleValue(
                            title: "Designation ",
                            value: achievement.designationName,
                            singleLine: false,
                          ),
                          buildRowTitleValue(
                            title: "Walkins By CP",
                            value: addCommasToInteger(
                              achievement.walkinsByCp.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Walkins Fresh Visits",
                            value: addCommasToInteger(
                              achievement.freshVisits.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Revisits",
                            value: addCommasToInteger(
                              achievement.revisits.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Booking",
                            value: addCommasToInteger(
                              achievement.bookings.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Revenue",
                            singleLine: false,
                            value: addCommasToInteger(achievement.totalRevenue),
                          ),
                          buildRowTitleValue(
                            title: "IBM",
                            singleLine: false,
                            value: addCommasToInteger(
                              achievement.totalIbm.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "OBM (Fresh Visits)",
                            singleLine: false,
                            value: addCommasToInteger(
                              achievement.totalObmFreshVisits.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "OBM (Revisits)",
                            singleLine: false,
                            value: addCommasToInteger(
                              achievement.totalObmRevisits.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "Total Meetings",
                            singleLine: false,
                            value: addCommasToInteger(
                              achievement.totalMeetings.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                          buildRowTitleValue(
                            title: "IBM",
                            singleLine: false,
                            value: addCommasToInteger(
                              achievement.totalIbm.toDouble(),
                              withoutSign: true,
                            ),
                          ),
                        ],
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

  Widget _buildSearchBar() {
    return SearchWidget(
      textController: _searchTextC,
      hintText: "Search By Employee Name",
      isFilterOn: true,
      onFilterTap: () => _showBottomSheetToFilterManagerAchievement(context),
      onSubmit: (String value) {
        _achievementCubit.managerSearch(
          context: context,
          searchText: value,
          activeSecondaryTabIndex:
              widget.type.toLowerCase() == "closing"
                  ? 0
                  : widget.type.toLowerCase() == "sourcing"
                  ? 1
                  : 0,
          projectId: widget.projectAchievementReportModel.projectId,
        );
      },
    );
  }
}
