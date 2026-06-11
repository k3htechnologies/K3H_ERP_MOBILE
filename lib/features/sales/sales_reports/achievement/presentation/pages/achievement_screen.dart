import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../../../../core/encryption_manager.dart';
import '../cubit/achievement.state.dart';
import '../cubit/achievement_cubit.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  late AchievementCubit _achievementCubit;
  late AuthorizationModel _routeAuthorizationModel;
  TabController? _primaryTabController;
  TabController? _secondaryTabController;
  late TextEditingController _searchTextC;
  final ValueNotifier<String> _searchTextNotifier = ValueNotifier<String>(
    'Search By Project Name',
  );
  final ValueNotifier<String> _filterTypeNotifier = ValueNotifier<String>(
    'MONTHLY',
  );
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  // PAGINATION
  late ScrollController _projectScrollController;
  Timer? _projectDebounce;
  late ScrollController _closingScrollController;
  Timer? _closingDebounce;
  late ScrollController _sourcingScrollController;
  Timer? _sourcingDebounce;

  @override
  void initState() {
    _achievementCubit = context.read<AchievementCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.achievementReport]!;
    _primaryTabController = TabController(length: 5, vsync: this);
    _primaryTabController?.animateTo(2);
    _secondaryTabController = TabController(length: 3, vsync: this);
    _achievementCubit.resetState();
    _achievementCubit.getProjectAchievementReport(
      context: context,
      pageNumber: 1,
      filterType: _filterTypeNotifier.value,
      fromDate: _fromDateNotifier.value,
      toDate: _toDateNotifier.value,
    );
    _primaryTabController!.addListener(_primaryTabListener);
    _secondaryTabController!.addListener(_secondaryTabListener);
    _searchTextC = TextEditingController();
    _onScroll();
    super.initState();
  }

  @override
  void dispose() {
    _primaryTabController?.dispose();
    _secondaryTabController?.dispose();
    _searchTextC.dispose();
    _filterTypeNotifier.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    _projectScrollController.dispose();
    _closingScrollController.dispose();
    _sourcingScrollController.dispose();
    super.dispose();
  }

  void _primaryTabListener() {
    if (_primaryTabController?.indexIsChanging ?? false) return;

    switch (_primaryTabController?.index) {
      case 0:
        _filterTypeNotifier.value = 'TODAY';
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;
        _secondaryTabListener(isIndexChangeCheck: false);
        break;

      case 1:
        _filterTypeNotifier.value = 'WEEKLY';
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;
        _secondaryTabListener(isIndexChangeCheck: false);
        break;

      case 2:
        _filterTypeNotifier.value = 'MONTHLY';
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;
        _secondaryTabListener(isIndexChangeCheck: false);
        break;

      case 3:
        _filterTypeNotifier.value = 'DATEWISE';
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;
        _achievementCubit.resetState();
        break;
      case 4:
        _filterTypeNotifier.value = 'OVERALL';
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;
        _secondaryTabListener(isIndexChangeCheck: false);

        break;
      default:
        _filterTypeNotifier.value = 'TODAY';
        _fromDateNotifier.value = null;
        _toDateNotifier.value = null;
        _secondaryTabListener(isIndexChangeCheck: false);
    }
  }

  void _secondaryTabListener({bool isIndexChangeCheck = true}) {
    // TO AVOID API CALL ON PRIMARY TAB CHANGE WHEN DATEWISE IS SELECTED WITHOUT SELECTING DATES
    if (_primaryTabController?.index == 3 &&
        _fromDateNotifier.value == null &&
        _toDateNotifier.value == null) {
      return;
    }
    // TO AVOID API CALL ON SECONDARY TAB CHANGE WHEN PRIMARY TAB CHANGES
    if (isIndexChangeCheck) {
      if (_secondaryTabController?.indexIsChanging ?? false) return;
    }
    _searchTextC.clear();
    _achievementCubit.resetState();

    switch (_secondaryTabController?.index) {
      case 0:
        _searchTextNotifier.value = 'Search By Project Name';
        _achievementCubit.getProjectAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: _filterTypeNotifier.value,
          fromDate: _fromDateNotifier.value,
          toDate: _toDateNotifier.value,
        );
        break;
      case 1:
        _searchTextNotifier.value = 'Search By Employee Name';
        _achievementCubit.getClosingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: _filterTypeNotifier.value,
          fromDate: _fromDateNotifier.value,
          toDate: _toDateNotifier.value,
        );
        break;
      case 2:
        _searchTextNotifier.value = 'Search By Employee Name';
        _achievementCubit.getSourcingAchievementReport(
          context: context,
          pageNumber: 1,
          filterType: _filterTypeNotifier.value,
          fromDate: _fromDateNotifier.value,
          toDate: _toDateNotifier.value,
        );
        break;
      default:
        _searchTextNotifier.value = 'Search By Project Name';
        _searchTextC.clear();
    }
  }

  void _onScroll() {
    _projectScrollController = ScrollController();
    _projectScrollController.addListener(() {
      if (_projectScrollController.position.pixels >=
              _projectScrollController.position.maxScrollExtent - 100 &&
          !_achievementCubit.state.isLoading! &&
          _achievementCubit.state.projectAchievementReportList.length <
              _achievementCubit.state.projectAchievementTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_projectDebounce?.isActive ?? false) _projectDebounce?.cancel();
        _projectDebounce = Timer(const Duration(milliseconds: 300), () {
          _achievementCubit.getProjectAchievementReport(
            context: context,
            pageNumber:
                _achievementCubit
                    .state
                    .currentProjectAchievementReportPageNumber +
                1,
            filterType: _filterTypeNotifier.value,
            fromDate: _fromDateNotifier.value,
            toDate: _toDateNotifier.value,
          );
        });
      }
    });
    _closingScrollController = ScrollController();
    _closingScrollController.addListener(() {
      if (_closingScrollController.position.pixels >=
              _closingScrollController.position.maxScrollExtent - 100 &&
          !_achievementCubit.state.isLoading! &&
          _achievementCubit.state.closingAchievementReportList.length <
              _achievementCubit.state.closingAchievementTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_closingDebounce?.isActive ?? false) _closingDebounce?.cancel();
        _closingDebounce = Timer(const Duration(milliseconds: 300), () {
          _achievementCubit.getClosingAchievementReport(
            context: context,
            pageNumber:
                _achievementCubit
                    .state
                    .currentClosingAchievementReportPageNumber +
                1,
            filterType: _filterTypeNotifier.value,
            fromDate: _fromDateNotifier.value,
            toDate: _toDateNotifier.value,
          );
        });
      }
    });
    _sourcingScrollController = ScrollController();
    _sourcingScrollController.addListener(() {
      if (_sourcingScrollController.position.pixels >=
              _sourcingScrollController.position.maxScrollExtent - 100 &&
          !_achievementCubit.state.isLoading! &&
          _achievementCubit.state.sourcingAchievementReportList.length <
              _achievementCubit.state.sourcingAchievementTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_sourcingDebounce?.isActive ?? false) _sourcingDebounce?.cancel();
        _sourcingDebounce = Timer(const Duration(milliseconds: 300), () {
          _achievementCubit.getSourcingAchievementReport(
            context: context,
            pageNumber:
                _achievementCubit
                    .state
                    .currentSourcingAchievementReportPageNumber +
                1,
            filterType: _filterTypeNotifier.value,
            fromDate: _fromDateNotifier.value,
            toDate: _toDateNotifier.value,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterAchievement(BuildContext context) async {
    final state = _achievementCubit.state;

    String? selectedDirection =
        _secondaryTabController?.index == 0
            ? state.currentSortColumn == "Project Name"
                ? state.currentSortDirection
                : null
            : state.currentSortColumn == "Employee Name"
            ? state.currentSortDirection
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
                Text(
                  _secondaryTabController?.index == 0
                      ? "Sort By Project Name"
                      : "Sort By Employee Name",
                  style: AppTextStyle.ts14M(),
                ),

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

        _achievementCubit.applyAchievementFilterAndSort(
          context: context,

          sortColumn: '',
          sortDirection: '',
          activeSecondaryTabIndex: _secondaryTabController?.index ?? 0,
        );
      },

      onApply: () {
        applied = true;

        _achievementCubit.applyAchievementFilterAndSort(
          context: context,
          sortColumn:
              selectedDirection != null
                  ? (_secondaryTabController?.index == 0
                      ? "Project Name"
                      : "Employee Name")
                  : null,
          sortDirection: selectedDirection,
          activeSecondaryTabIndex: _secondaryTabController?.index ?? 0,
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
        screenTitle: "Achievement",
        authorization: _routeAuthorizationModel,
        isMenuButton: true,
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _primaryTabController!,
            tabs: achievementTimelineTabs,
          ),
          // SHOW FROM-TO DATE PICKER IF PRIMARY TAB IS DATEWISE
          AnimatedBuilder(
            animation: Listenable.merge([
              _primaryTabController,
              _fromDateNotifier,
              _toDateNotifier,
            ]),
            builder: (context, child) {
              if (_primaryTabController?.index != 3) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(
                  top: 8.0,
                  right: 16.0,
                  left: 16.0,
                ),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: CustomFromToDatePicker(
                  initialFromDate: _fromDateNotifier.value,
                  initialToDate: _toDateNotifier.value,
                  isRequired: false,
                  onToDateChanged: (fromDate, toDate) {
                    _fromDateNotifier.value = fromDate;
                    _toDateNotifier.value = toDate;
                    if (fromDate == null || toDate == null) {
                      _achievementCubit.resetState();
                    } else {
                      _secondaryTabListener(isIndexChangeCheck: false);
                    }
                  },
                ),
              );
            },
          ),
          ChipStyleTabBar(
            controller: _secondaryTabController!,
            tabs: achievementTabs,
            isSecondaryStyle: true,
          ),
          Expanded(
            child: TabBarView(
              controller: _secondaryTabController!,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProjectAchievementTab(),
                _buildClosingAchievementTab(),
                _buildSourcingAchievementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectAchievementTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<AchievementCubit, AchievementState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.projectAchievementReportList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.projectAchievementReportList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No project achievement data available",
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _searchTextC.clear();
                    _achievementCubit.getProjectAchievementReport(
                      context: context,
                      pageNumber: 1,
                      filterType: _filterTypeNotifier.value,
                    );
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _projectScrollController,
                    itemCount: state.projectAchievementReportList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.projectAchievementReportList.length) {
                        return state.projectAchievementReportList.length <
                                state.projectAchievementTotalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final achievement =
                          state.projectAchievementReportList[index];
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      achievement.projectName,
                                      style: AppTextStyle.ts16M(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    spacing: 5,
                                    children: [
                                      CustomButton(
                                        text: "CM",
                                        onPressed: () async {
                                          await _achievementCubit
                                              .resetManagerAchievementReportState();
                                          goRouter.pushNamed(
                                            AppRoutes.managerAchievementReport,
                                            queryParameters: {
                                              'type': 'closing',
                                              'filterType':
                                                  _filterTypeNotifier.value,
                                              'fromDate':
                                                  _fromDateNotifier.value !=
                                                          null
                                                      ? Uri.encodeComponent(
                                                        EncryptionManager.encryptData(
                                                          _fromDateNotifier
                                                              .value!
                                                              .toIso8601String(),
                                                        ),
                                                      )
                                                      : '',
                                              'toDate':
                                                  _toDateNotifier.value != null
                                                      ? Uri.encodeComponent(
                                                        EncryptionManager.encryptData(
                                                          _toDateNotifier.value!
                                                              .toIso8601String(),
                                                        ),
                                                      )
                                                      : '',
                                              'projectAchievement':
                                                  Uri.encodeComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        achievement.toJson(),
                                                      ),
                                                    ),
                                                  ),
                                            },
                                          );
                                        },
                                      ),
                                      CustomButton(
                                        text: "SM",
                                        backgroundColor: AppColor.lightBlue,
                                        textColor: AppColor.primary,
                                        onPressed: () async {
                                          await _achievementCubit
                                              .resetManagerAchievementReportState();
                                          goRouter.pushNamed(
                                            AppRoutes.managerAchievementReport,
                                            queryParameters: {
                                              'type': 'sourcing',
                                              'filterType':
                                                  _filterTypeNotifier.value,
                                              'fromDate':
                                                  _fromDateNotifier.value !=
                                                          null
                                                      ? Uri.encodeComponent(
                                                        EncryptionManager.encryptData(
                                                          _fromDateNotifier
                                                              .value!
                                                              .toIso8601String(),
                                                        ),
                                                      )
                                                      : '',
                                              'toDate':
                                                  _toDateNotifier.value != null
                                                      ? Uri.encodeComponent(
                                                        EncryptionManager.encryptData(
                                                          _toDateNotifier.value!
                                                              .toIso8601String(),
                                                        ),
                                                      )
                                                      : '',
                                              'projectAchievement':
                                                  Uri.encodeComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        achievement.toJson(),
                                                      ),
                                                    ),
                                                  ),
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
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
                                    value:
                                        achievement.walkinsDirect.addCommas(),
                                  ),
                                  buildRowTitleValue(
                                    title: "Fresh Visits",
                                    value:
                                        achievement.totalFreshVisits
                                            .addCommas(),
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
                                    value:
                                        achievement.bookingDirect.addCommas(),
                                  ),
                                ],
                              ),

                              Divider(height: 1, color: AppColor.grey50),

                              /// IBM + OBM
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: buildRowTitleValue(
                                  title: "IBM + OBM",
                                  singleLine: false,
                                  value:
                                      (achievement.totalIbm +
                                              achievement.totalObm)
                                          .addCommas(),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_down),
                                childrenPadding: EdgeInsets.zero,
                                children: [
                                  buildRowTitleValue(
                                    title: "IBM",
                                    value: achievement.totalIbm.addCommas(),
                                  ),
                                  buildRowTitleValue(
                                    title: "OBM",
                                    value: achievement.totalObm.addCommas(),
                                  ),
                                ],
                              ),

                              Divider(height: 1, color: AppColor.grey50),

                              /// TOTAL REVENUE
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingAchievementTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          _buildSearchBar(),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<AchievementCubit, AchievementState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.closingAchievementReportList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.closingAchievementReportList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No closing achievement data available",
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _searchTextC.clear();
                    _achievementCubit.getClosingAchievementReport(
                      context: context,
                      pageNumber: 1,
                      filterType: _filterTypeNotifier.value,
                    );
                  },
                  child: ListView.builder(
                    controller: _closingScrollController,
                    shrinkWrap: true,
                    itemCount: state.closingAchievementReportList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.closingAchievementReportList.length) {
                        return state.closingAchievementReportList.length <
                                state.closingAchievementTotalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final achievement =
                          state.closingAchievementReportList[index];
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
                                    value:
                                        achievement.walkinsDirect.addCommas(),
                                  ),
                                  buildRowTitleValue(
                                    title: "Fresh Visits",
                                    value:
                                        achievement.totalFreshVisits
                                            .addCommas(),
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
                                    value:
                                        achievement.bookingDirect.addCommas(),
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
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          _buildSearchBar(),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<AchievementCubit, AchievementState>(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.sourcingAchievementReportList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.sourcingAchievementReportList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No sourcing achievement data available",
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _searchTextC.clear();
                    _achievementCubit.getSourcingAchievementReport(
                      context: context,
                      pageNumber: 1,
                      filterType: _filterTypeNotifier.value,
                    );
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _sourcingScrollController,
                    itemCount: state.sourcingAchievementReportList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.sourcingAchievementReportList.length) {
                        return state.sourcingAchievementReportList.length <
                                state.sourcingAchievementTotalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final achievement =
                          state.sourcingAchievementReportList[index];
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

                              /// MEETINGS
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
                                        achievement.totalObmRevisits
                                            .addCommas(),
                                  ),
                                ],
                              ),

                              Divider(height: 1, color: AppColor.grey50),

                              /// IBM
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

                              /// BOOKINGS
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

                              /// TOTAL REVENUE
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: buildRowTitleValue(
                                  title: "Total Revenue",
                                  singleLine: false,
                                  value:
                                      achievement.totalRevenue
                                          .toIndianCurrency(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<AchievementCubit, AchievementState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _searchTextNotifier,
            _primaryTabController,
            _secondaryTabController,
          ]),
          builder: (context, child) {
            final showExport =
                (_secondaryTabController?.index == 0 &&
                        state.projectAchievementReportList.isEmpty)
                    ? false
                    : (_secondaryTabController?.index == 1 &&
                        state.closingAchievementReportList.isEmpty)
                    ? false
                    : (_secondaryTabController?.index == 2 &&
                        state.sourcingAchievementReportList.isEmpty)
                    ? false
                    : true;
            return Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SearchWidget(
                    textController: _searchTextC,
                    hintText: _searchTextNotifier.value,
                    isFilterOn: true,
                    onFilterTap:
                        () => _showBottomSheetToFilterAchievement(context),
                    onSubmit: (String value) {
                      _achievementCubit.search(
                        context: context,
                        searchText: value,
                        activeSecondaryTabIndex:
                            _secondaryTabController?.index ?? 0,
                        filterType: _filterTypeNotifier.value,
                        fromDate: _fromDateNotifier.value,
                        toDate: _toDateNotifier.value,
                      );
                    },
                  ),
                ),
                if (showExport)
                  CustomExportButton(
                    onExport: (v) {
                      _achievementCubit.exportExcelPdf(
                        context,
                        v,
                        filterType: _filterTypeNotifier.value,
                        secondTabIndex: _secondaryTabController?.index,
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
