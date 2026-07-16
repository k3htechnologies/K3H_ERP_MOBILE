import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/presentation/cubit/aop_achievement_report_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/presentation/cubit/aop_achievement_report_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_tab_values.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AopAchievementReportScreen extends StatefulWidget {
  const AopAchievementReportScreen({super.key});

  @override
  State<AopAchievementReportScreen> createState() =>
      _AopAchievementReportScreenState();
}

class _AopAchievementReportScreenState extends State<AopAchievementReportScreen>
    with TickerProviderStateMixin {
  late AuthorizationModel _routeAuthorizationModel;
  late AopAchievementReportCubit _aopAchievementReportCubit;
  TabController? _tabController;
  late TextEditingController _searchC;
  final ValueNotifier<String> _filterTypeNotifier = ValueNotifier<String>(
    'MONTHLY',
  );
  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  late ScrollController _aopAchievementScrollController;
  Timer? _aopAchievementDebounce;
  @override
  void initState() {
    _aopAchievementReportCubit = context.read<AopAchievementReportCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.aopAchievement]!;
    _tabController = TabController(length: 4, vsync: this);
    _tabController?.animateTo(2);
    _searchC = TextEditingController();
    _tabController?.addListener(_primaryTabListener);
    _onScroll();
    _aopAchievementReportCubit.getAopAchievementReport(
      context: context,
      pageNumber: 1,
      filterType: _filterTypeNotifier.value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchC.dispose();
    _filterTypeNotifier.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    _aopAchievementScrollController.dispose();
    _aopAchievementDebounce?.cancel();
    super.dispose();
  }

  void _primaryTabListener({bool isIndexChangeCheck = true}) {
    final isIndexChanging = _tabController?.indexIsChanging ?? false;

    if (isIndexChanging) {
      _updatePrimaryFilter();
    }
    // TO SKIP API CALL : WHEN TAB IS DATEWISE AND DATES ARE NOT SELECTED
    if (_tabController?.index == 3 &&
        _fromDateNotifier.value == null &&
        _toDateNotifier.value == null) {
      _aopAchievementReportCubit.resetState();
      return;
    }

    // SKIP API CALL FOR NO TAB CHANGE
    if (isIndexChangeCheck && isIndexChanging) return;

    _searchC.clear();
    _aopAchievementReportCubit.resetState();

    _aopAchievementReportCubit.getAopAchievementReport(
      context: context,
      pageNumber: 1,
      filterType: _filterTypeNotifier.value,
      fromDate: _fromDateNotifier.value,
      toDate: _toDateNotifier.value,
    );
  }

  void _updatePrimaryFilter() {
    _filterTypeNotifier.value = switch (_tabController?.index) {
      0 => 'TODAY',
      1 => 'WEEKLY',
      2 => 'MONTHLY',
      3 => 'DATEWISE',
      _ => 'TODAY',
    };

    _fromDateNotifier.value = null;
    _toDateNotifier.value = null;
    _searchC.clear();
  }

  void _onScroll() {
    _aopAchievementScrollController = ScrollController();
    _aopAchievementScrollController.addListener(() {
      if (_aopAchievementScrollController.position.pixels >=
              _aopAchievementScrollController.position.maxScrollExtent - 100 &&
          !_aopAchievementReportCubit.state.isLoading! &&
          _aopAchievementReportCubit.state.aopAchievementReportList.length <
              _aopAchievementReportCubit
                  .state
                  .aopAchievementReportTotalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_aopAchievementDebounce?.isActive ?? false) {
          _aopAchievementDebounce?.cancel();
        }
        _aopAchievementDebounce = Timer(const Duration(milliseconds: 300), () {
          _aopAchievementReportCubit.getAopAchievementReport(
            context: context,
            pageNumber:
                _aopAchievementReportCubit
                    .state
                    .currentAopAchievementReportPageNumber +
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
    final state = _aopAchievementReportCubit.state;

    String? selectedDirection =
        state.currentSortColumn == "Name" ? state.currentSortDirection : null;
    _searchC.text = state.searchText;

    final String initialSearchText = _searchC.text;
    final String? initialDirection = selectedDirection;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    bool applied = false;
    bool manualClose = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text != initialSearchText ||
            selectedDirection != initialDirection;
        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - AOP Achievement Report",

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
                  "Sort By Channel Partner Name",
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
                verticalSpacing(height: 20),
                CustomTextField(
                  textController: _searchC,
                  hint: "Enter Channel Partner Name",
                  title: "Channel Partner Name",
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        selectedDirection = null;
        _searchC.clear();
        _aopAchievementReportCubit.applyAchievementFilterAndSort(
          context: context,
          searchText: '',
          sortColumn: '',
          sortDirection: '',
          filterType: _filterTypeNotifier.value,
          fromDate: _fromDateNotifier.value,
          toDate: _toDateNotifier.value,
        );
      },

      onApply: () {
        applied = true;

        _aopAchievementReportCubit.applyAchievementFilterAndSort(
          context: context,
          sortColumn: selectedDirection != null ? "Name" : null,
          searchText: _searchC.text.trim(),
          sortDirection: selectedDirection,
          filterType: _filterTypeNotifier.value,
          fromDate: _fromDateNotifier.value,
          toDate: _toDateNotifier.value,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      selectedDirection = initialDirection;
      _searchC.text = initialSearchText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "AOP Achievement Report",
        authorization: _routeAuthorizationModel,
        isMenuButton: true,
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _tabController!,
            tabs: aopAchievementTimelineTabs,
          ),
          AnimatedBuilder(
            animation: Listenable.merge([
              _tabController,
              _fromDateNotifier,
              _toDateNotifier,
            ]),
            builder: (context, child) {
              if (_tabController?.index != 3) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(
                  top: 8.0,
                  right: 16.0,
                  left: 16.0,
                  bottom: 8,
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
                      _aopAchievementReportCubit.resetState();
                    } else {
                      _primaryTabListener(isIndexChangeCheck: false);
                    }
                  },
                ),
              );
            },
          ),
          Expanded(child: _buildAopAchievementView()),
        ],
      ),
    );
  }

  Widget _buildAopAchievementView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          _buildSearchBar(),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<
              AopAchievementReportCubit,
              AopAchievementReportState
            >(
              builder: (context, state) {
                if ((state.isLoading ?? false) &&
                    state.aopAchievementReportList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.aopAchievementReportList.isEmpty) {
                  return Center(
                    child: noDataWidget(
                      message: "No Aop Achievement Data Found",
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _searchC.clear();
                    _aopAchievementReportCubit.getAopAchievementReport(
                      context: context,
                      pageNumber: 1,
                      filterType: _filterTypeNotifier.value,
                    );
                  },
                  child: ListView.builder(
                    controller: _aopAchievementScrollController,
                    shrinkWrap: true,
                    itemCount: state.aopAchievementReportList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.aopAchievementReportList.length) {
                        return state.aopAchievementReportList.length <
                                state.aopAchievementReportTotalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final achievement = state.aopAchievementReportList[index];
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      achievement.name,
                                      style: AppTextStyle.ts16M(
                                        color: AppColor.black,
                                      ),
                                    ),
                                  ),
                                  channelPartnerCategoryStatusWidget(
                                    achievement.type,
                                  ),
                                ],
                              ),

                              /// WALKINS
                              ExpansionTile(
                                title: buildRowTitleCount(
                                  title: "Total Walkins",
                                  value: achievement.totalWalkins.toString(),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_down),
                                backgroundColor: AppColor.lightBlueBg2
                                    .withValues(alpha: 0.5),
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                childrenPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                children: [
                                  buildRowTitleCount(
                                    title: "By CP",
                                    value: achievement.walkinsByCp.toString(),
                                    onValueTap:
                                        () => _navigateToAchievementDrillDown(
                                          employeeId:
                                              achievement.channelPartnerId,
                                          employeeName: achievement.name,
                                          columnName: 'WALKINS BY CP',
                                          achievementDrillDownType:
                                              AchievementDrillDownType.enquiry,
                                        ),
                                  ),
                                  buildRowTitleCount(
                                    title: "Fresh Visits",
                                    value:
                                        achievement.totalFreshVisits.toString(),
                                    onValueTap:
                                        () => _navigateToAchievementDrillDown(
                                          employeeName: achievement.name,
                                          employeeId:
                                              achievement.channelPartnerId,
                                          columnName: 'FRESH VISITS',
                                          achievementDrillDownType:
                                              AchievementDrillDownType.enquiry,
                                        ),
                                  ),
                                  buildRowTitleCount(
                                    title: "Revisits",
                                    value: achievement.revisits.toString(),
                                    onValueTap:
                                        () => _navigateToAchievementDrillDown(
                                          employeeName: achievement.name,
                                          employeeId:
                                              achievement.channelPartnerId,
                                          columnName: 'REVISITS',
                                          achievementDrillDownType:
                                              AchievementDrillDownType.enquiry,
                                        ),
                                  ),
                                ],
                              ),

                              Divider(height: 1, color: AppColor.grey50),

                              ExpansionTile(
                                title: buildRowTitleCount(
                                  title: "IBM + OBM",
                                  value: achievement.totalIbmObm.toString(),
                                  onValueTap:
                                      () => _navigateToAchievementDrillDown(
                                        employeeName: achievement.name,
                                        employeeId:
                                            achievement.channelPartnerId,
                                        columnName: "IBM + OBM",
                                        achievementDrillDownType:
                                            AchievementDrillDownType
                                                .channelPartner,
                                      ),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_down),
                                backgroundColor: AppColor.lightGreenBg
                                    .withValues(alpha: 0.2),
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                childrenPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                children: [
                                  buildRowTitleCount(
                                    title: "IBM",
                                    value: achievement.totalIbm.toString(),
                                    onValueTap:
                                        () => _navigateToAchievementDrillDown(
                                          employeeName: achievement.name,
                                          employeeId:
                                              achievement.channelPartnerId,
                                          columnName: 'IBM',
                                          achievementDrillDownType:
                                              AchievementDrillDownType
                                                  .channelPartner,
                                        ),
                                  ),
                                  buildRowTitleCount(
                                    title: "OBM",
                                    value: achievement.totalObm.toString(),
                                    onValueTap:
                                        () => _navigateToAchievementDrillDown(
                                          employeeName: achievement.name,
                                          employeeId:
                                              achievement.channelPartnerId,
                                          columnName: 'OBM',
                                          achievementDrillDownType:
                                              AchievementDrillDownType
                                                  .channelPartner,
                                        ),
                                  ),
                                ],
                              ),

                              Divider(height: 1, color: AppColor.grey50),

                              /// BOOKINGS
                              ExpansionTile(
                                enabled: false,
                                showTrailingIcon: false,
                                title: buildRowTitleCount(
                                  title: "Booking By CP",
                                  value: achievement.bookingByCp.toString(),
                                  onValueTap:
                                      () => _navigateToAchievementDrillDown(
                                        employeeName: achievement.name,
                                        employeeId:
                                            achievement.channelPartnerId,
                                        columnName: 'BOOKING BY CP',
                                        achievementDrillDownType:
                                            AchievementDrillDownType.booking,
                                      ),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_down),
                                backgroundColor: AppColor.lightRed2,
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                                childrenPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                ),
                              ),

                              Divider(height: 1, color: AppColor.grey50),

                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: buildRowTitleCount(
                                  title: "Total Revenue (₹)",
                                  singleLine: false,
                                  value: achievement.totalRevenue.toString(),
                                  onValueTap:
                                      () => _navigateToAchievementDrillDown(
                                        employeeName: achievement.name,
                                        employeeId:
                                            achievement.channelPartnerId,
                                        columnName: 'TOTAL REVENUE',
                                        achievementDrillDownType:
                                            AchievementDrillDownType.booking,
                                      ),
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

  void _navigateToAchievementDrillDown({
    int? employeeId,
    String? employeeName,
    required String columnName,
    required AchievementDrillDownType achievementDrillDownType,
  }) async {
    final tabName = 'Project';

    await _aopAchievementReportCubit.updateAchievementDrillDownType(
      drillDownType: achievementDrillDownType,
    );
    goRouter.pushNamed(
      AppRoutes.aopAchievementDrillDownReport,
      queryParameters: {
        if (employeeId != null)
          'employeeId': Uri.encodeQueryComponent(
            EncryptionManager.encryptData(employeeId.toString()),
          ),
        if (employeeName != null)
          'employeeName': Uri.encodeQueryComponent(
            EncryptionManager.encryptData(employeeName),
          ),
        'tabName': Uri.encodeQueryComponent(
          EncryptionManager.encryptData(tabName),
        ),
        'columnName': Uri.encodeQueryComponent(
          EncryptionManager.encryptData(columnName),
        ),

        'filterType': Uri.encodeQueryComponent(
          EncryptionManager.encryptData(_filterTypeNotifier.value),
        ),
        'fromDate':
            _fromDateNotifier.value != null
                ? Uri.encodeQueryComponent(
                  EncryptionManager.encryptData(
                    _fromDateNotifier.value!.toIso8601String(),
                  ),
                )
                : '',
        'toDate':
            _toDateNotifier.value != null
                ? Uri.encodeQueryComponent(
                  EncryptionManager.encryptData(
                    _toDateNotifier.value!.toIso8601String(),
                  ),
                )
                : '',
      },
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<AopAchievementReportCubit, AopAchievementReportState>(
      builder: (context, state) {
        _filterCount.value = _aopAchievementReportCubit.updateFilterCount(
          state,
        );
        return AnimatedBuilder(
          animation: Listenable.merge([_tabController]),
          builder: (context, child) {
            final disableExport =
                (state.aopAchievementReportList.isEmpty ? true : false) ||
                !_routeAuthorizationModel.isExport;
            return Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SearchWidget(
                    textController: _searchC,
                    hintText: "Search By Channel Partner Name",
                    isFilterOn: true,
                    filterCountNotifier: _filterCount,
                    onFilterTap:
                        () => _showBottomSheetToFilterAchievement(context),
                    onSubmit: (String value) {
                      _aopAchievementReportCubit.search(
                        context: context,
                        searchText: value,
                        filterType: _filterTypeNotifier.value,
                        fromDate: _fromDateNotifier.value,
                        toDate: _toDateNotifier.value,
                      );
                    },
                  ),
                ),
                CustomExportButton(
                  onExport: (v) {
                    if (disableExport) {
                      showErrorMessage(context, "Error", "No Data Found");
                      return;
                    }
                    _aopAchievementReportCubit
                        .exportAopAchievementReportExcelPdf(
                          context,
                          v,
                          filterType: _filterTypeNotifier.value,
                          fromDate: _fromDateNotifier.value,
                          toDate: _toDateNotifier.value,
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
