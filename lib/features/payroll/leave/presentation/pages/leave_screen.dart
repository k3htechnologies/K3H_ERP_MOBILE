import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late LeaveCubit _leaveCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TAB
  TabController? _tabController;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);

  static const List<String> _statusTabs = [
    "All",
    "Pending",
    "Approved",
    "Rejected",
  ];

  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _leaveCubit = context.read<LeaveCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.leave]!;
    _initializeTextEditingController();
    _onScroll();
    _leaveCubit.getLeaveList(context, 1);
    _tabController = TabController(
      length: _statusTabs.length,
      vsync: this,
      initialIndex: _leaveCubit.state.currentTabIndex.clamp(
        0,
        _statusTabs.length - 1,
      ),
    );
    _tabController!.addListener(_onStatusTabChanged);
  }

  void _onStatusTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging && mounted) {
      _searchC.clear();
      _startDateNotifier.value = null;
      _endDateNotifier.value = null;
      _leaveCubit.onTabChanged(_tabController!.index, context);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onStatusTabChanged);
    _tabController?.dispose();
    _searchC.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
    super.dispose();
  }

  // PREFILL FILTER FROM STATE
  void _prefillFilterFromState() {
    final s = _leaveCubit.state;
    _searchC.text = s.searchText;
    _startDateNotifier.value = s.filterStartDate;
    _endDateNotifier.value = s.filterEndDate;
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_leaveCubit.state.isLoading! &&
          _leaveCubit.state.leaveList.length <
              _leaveCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _leaveCubit.getLeaveList(context, _leaveCubit.state.currentPage + 1);
        });
      }
    });
  }

  // <---- DELETE LEAVE ---->
  Future<void> _showPopupToDeleteLeave(
    BuildContext context,
    LeaveModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a leave?',
      'Deleting this leave will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _leaveCubit.deleteLeave(
        context: context,
        leaveId: obj.leaveId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  // LEAVE FILTER
  Future<void> _showBottomSheetToFilterLeave(BuildContext context) async {
    _prefillFilterFromState();
    final state = _leaveCubit.state;

    final String initialLeaveType = state.searchText;
    final DateTime? initialStartDate = state.filterStartDate;
    final DateTime? initialEndDate = state.filterEndDate;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool manualClose = false;
    bool applied = false;
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        final bool onlyOneDateSet =
            (_startDateNotifier.value != null &&
                _endDateNotifier.value == null) ||
            (_endDateNotifier.value != null &&
                _startDateNotifier.value == null);
        manualClose =
            _searchC.text.trim() != initialLeaveType ||
            _startDateNotifier.value != initialStartDate ||
            _endDateNotifier.value != initialEndDate;

        applyEnabled.value = manualClose && !onlyOneDateSet;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Leave",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _startDateNotifier,
                  _endDateNotifier,
                ]),
                builder: (context, child) {
                  return CustomFromToDatePicker(
                    fromDateTitle: "From Date",
                    toDateTitle: "To Date",
                    removeBottomMargin: false,
                    initialFromDate: _startDateNotifier.value,
                    initialToDate: _endDateNotifier.value,
                    onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                      _startDateNotifier.value = fromDate;
                      _endDateNotifier.value = toDate;

                      updateApplyState(innerState);
                    },
                  );
                },
              ),
              CustomTextField(
                textController: _searchC,
                title: "Leave Type",
                hint: "Enter Leave Type",
                onChangeFunction: (v) {
                  updateApplyState(innerState);
                },
              ),
            ],
          );
        },
      ),
      onClear: () {
        _searchC.clear();
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _leaveCubit.clearFilterOnLeave(context);
      },
      onApply: () {
        applied = true;

        final startDate = _startDateNotifier.value;
        final endDate = _endDateNotifier.value;
        _leaveCubit.applyFilterOnLeave(
          context,
          leaveType: _searchC.text.trim(),
          startDate: startDate,
          endDate: endDate,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    if (!applied && manualClose) {
      _searchC.clear();
      _startDateNotifier.value = null;
      _endDateNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveCubit, LeaveState>(
      listener: (context, state) {
        _filterCount.value = _leaveCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Leave",
          authorization: _routeAuthorizationModel,
          textController: _searchC,
          searchHintText: "Search by Leave Type",
          filterCountNotifier: _filterCount,
          onSearchSubmit: (value) {
            _leaveCubit.searchOutdoor(context, value);
          },
          onExportCallback: (value) {
            _leaveCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterLeave(context);
          },
          secondaryBuilder:
              (_) => CustomButton(
                text: "Apply",
                onPressed: () async {
                  await goRouter.pushNamed(AppRoutes.applyLeave);
                  if (context.mounted) {
                    _leaveCubit.getLeaveList(context, 1);
                  }
                },
                backgroundColor: AppColor.primary,
                leading: Icon(Icons.add, size: 16, color: AppColor.white),
              ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTabBar(),
            BlocBuilder<LeaveCubit, LeaveState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) && state.leaveList.isEmpty) {
                  return Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Expanded(
                  child:
                      state.leaveList.isEmpty
                          ? Center(
                            child: noDataWidget(message: "No Leave Found"),
                          )
                          : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: state.leaveList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.leaveList.length) {
                                return state.leaveList.length <
                                        state.totalNumberOfRecord
                                    ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : const SizedBox.shrink();
                              }
                              var leave = state.leaveList[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(12),
                                decoration: commonCardDecoration(),
                                child: Column(
                                  spacing: 5,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              goRouter.pushNamed(
                                                AppRoutes.viewLeave,
                                                queryParameters: {
                                                  "leave": Uri.encodeQueryComponent(
                                                    EncryptionManager.encryptData(
                                                      jsonEncode(
                                                        leave.toJson(),
                                                      ),
                                                    ),
                                                  ),
                                                },
                                              );
                                            },
                                            child: Text(
                                              leave.leaveType,
                                              style: AppTextStyle.ts16M(
                                                color: AppColor.primary,
                                              ).copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColor.primary,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            approvalStatusWidget(
                                              leave.leaveStatus,
                                            ),
                                            horizontalSpacing(),

                                            Row(
                                              spacing: 10,
                                              children: [
                                                CustomIconButton.edit(
                                                  onPressed: () async {
                                                    await goRouter.pushNamed(
                                                      AppRoutes.applyLeave,
                                                      queryParameters: {
                                                        "leave":
                                                            Uri.encodeQueryComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  leave,
                                                                ),
                                                              ),
                                                            ),
                                                        'index':
                                                            index.toString(),
                                                      },
                                                    );
                                                  },
                                                ),
                                                CustomIconButton.delete(
                                                  onPressed: () {
                                                    _showPopupToDeleteLeave(
                                                      context,
                                                      leave,
                                                      index,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    buildRowTitleValue(
                                      title: "Start Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        leave.startDate,
                                      ),
                                    ),
                                    buildRowTitleValue(
                                      title: "End Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        leave.endDate,
                                      ),
                                    ),
                                    buildRowTitleValue(
                                      title: "No. Of Days",
                                      value: leave.noOfDays.toString(),
                                    ),
                                    buildRowTitleValue(
                                      title: "Reason",
                                      value: leave.reason,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabBar() {
    return ChipStyleTabBar(
      controller: _tabController!,
      tabs: _statusTabs.map((t) => t).toList(),
    );
  }
}

// HELPER CLASS TO STORE STATUS CONFIG
class StatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const StatusConfig({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });
}
