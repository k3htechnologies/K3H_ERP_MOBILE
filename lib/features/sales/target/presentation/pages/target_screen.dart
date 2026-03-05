import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_closing.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/cubit/target_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late TargetCubit _targetCubit;

  // PROJECT
  late ProjectModel selectedProject;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // SCROLL CONTROLLERS
  late ScrollController _sourcingTargetScrollController;
  late ScrollController _closingTargetScrollController;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // TAB CONTROLLER
  late TabController _tabController;

  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  // DEBOUNCE TIMER
  Timer? _sourcingTargetDebounce;
  Timer? _closingTargetDebounce;

  int _lastHandledTabIndex = 0;
  bool _isHandlingTabChange = false;
  bool ignoreSearch = false;

  @override
  void initState() {
    super.initState();
    _targetCubit = context.read<TargetCubit>();
    var project = getProject();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.salesTarget]!;
    _initializeTextEditingController();
    // INITIALIZE SCROLL CONTROLLERS
    _sourcingTargetScrollController = ScrollController();
    _closingTargetScrollController = ScrollController();

    // ADD SCROLL LISTENER
    _sourcingTargetScrollController.addListener(_onSourcingTargetScroll);
    _closingTargetScrollController.addListener(_onClosingTargetScroll);
    _targetCubit.getSalesTargetSourcingList(
      context: context,
      projectId: project.projectId,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sourcingTargetScrollController.dispose();
    _closingTargetScrollController.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // Same as Call Tracker: clear search, update state, call API once. Guard against double fire.
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_isHandlingTabChange) return;
    final index = _tabController.index;
    if (index == _lastHandledTabIndex) return;
    ignoreSearch = true;
    _isHandlingTabChange = true;
    _lastHandledTabIndex = index;

    _searchC.text = "";
    _startDateNotifier.value = null;
    _endDateNotifier.value = null;

    _targetCubit.onTabChanged(index, context);
    if (index == 0) {
      _targetCubit.getSalesTargetSourcingList(
        context: context,
        pageNumber: 1,
        projectId: getProject().projectId,
        queryParams: {},
      );
    } else {
      _targetCubit.getSalesTargetClosingList(
        context: context,
        pageNumber: 1,
        projectId: getProject().projectId,
        queryParams: {},
      );
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      ignoreSearch = false;
    });
    _isHandlingTabChange = false;
  }

  // PAGINATION - SOURCING TARGET (only when on this tab, same as Call Tracker)
  void _onSourcingTargetScroll() {
    if (_tabController.index != 0) return;

    if (_sourcingTargetScrollController.position.pixels >=
            _sourcingTargetScrollController.position.maxScrollExtent - 100 &&
        !_targetCubit.state.isLoading! &&
        _targetCubit.state.salesTargetSourcing.length <
            _targetCubit.state.sourcingTotalNumberOfRecordSalesTarget) {
      if (_sourcingTargetDebounce?.isActive ?? false) {
        _sourcingTargetDebounce?.cancel();
      }

      _sourcingTargetDebounce = Timer(const Duration(milliseconds: 300), () {
        _targetCubit.getSalesTargetSourcingList(
          context: context,
          pageNumber: _targetCubit.state.currentPage + 1,
          projectId: getProject().projectId,
        );
      });
    }
  }

  // PAGINATION - CLOSING TARGET
  void _onClosingTargetScroll() {
    if (_tabController.index != 1) return;

    if (_closingTargetScrollController.position.pixels >=
            _closingTargetScrollController.position.maxScrollExtent - 100 &&
        !_targetCubit.state.isLoading! &&
        _targetCubit.state.salesTargetClosing.length <
            _targetCubit.state.closingTotalNumberOfRecordSalesTarget) {
      if (_closingTargetDebounce?.isActive ?? false) {
        _closingTargetDebounce?.cancel();
      }

      _closingTargetDebounce = Timer(const Duration(milliseconds: 300), () {
        _targetCubit.getSalesTargetClosingList(
          context: context,
          pageNumber: _targetCubit.state.currentPage + 1,
          projectId: getProject().projectId,
        );
      });
    }
  }

  void _prefillFilterFromState() {
    final s = _targetCubit.state;
    _startDateNotifier.value = s.filterStartDate;
    _endDateNotifier.value = s.filterEndDate;
  }

  // SALES TARGET FILTER
  Future<void> _showBottomSheetToFilterSalesTarget(BuildContext context) async {
    _prefillFilterFromState();
    final state = _targetCubit.state;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(
      state.filterStartDate != null || state.filterEndDate != null,
    );
    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Sales Target",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _startDateNotifier,
                      builder: (context, startDate, child) {
                        return CustomDatePicker(
                          title: "Start Date",
                          initialDate: startDate,
                          setValue: (value) {
                            _startDateNotifier.value = value;
                            applyEnabled.value = true;
                          },
                          validator: (value) => null,
                        );
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _endDateNotifier,
                      builder: (context, endDate, child) {
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: _startDateNotifier,
                          builder: (context, startDate, child) {
                            return CustomDatePicker(
                              title: "End Date",
                              isRequired: false,
                              initialDate: endDate,
                              setValue: (value) {
                                _endDateNotifier.value = value;
                                applyEnabled.value = true;
                              },
                              validator: (value) {
                                if (value == null) return null;
                                if (startDate != null) {
                                  final startDateOnly = DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day,
                                  );
                                  final endDateOnly = DateTime(
                                    value.year,
                                    value.month,
                                    value.day,
                                  );
                                  if (endDateOnly.isBefore(startDateOnly)) {
                                    return 'End Date cannot be before Start Date';
                                  }
                                }
                                return null;
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      onClear: () {
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _targetCubit.clearFilterOnSalesTarget(
          context,
          getProject().projectId,
          _tabController.index,
        );
      },
      onApply: () {
        final startDate = _startDateNotifier.value;
        final endDate = _endDateNotifier.value;
        if (startDate != null && endDate != null) {
          final startOnly = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
          if (endOnly.isBefore(startOnly)) {
            showErrorMessage(
              context,
              "Invalid dates",
              "End Date cannot be before Start Date",
            );
            return;
          }
        }
        _targetCubit.applyFilterOnSalesTarget(
          context: context,
          startDate: startDate,
          endDate: endDate,
          tabIndex: _tabController.index,
          projectId: getProject().projectId,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Sales Target",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Employee Name",
        onSearchSubmit: (value) {
          _targetCubit.searchSalesTarget(
            context,
            getProject().projectId,
            _tabController.index,
            value,
          );
        },
        onProjectChangeCallback: (value) {
          _targetCubit.getSalesTargetSourcingList(
            context: context,
            projectId: getProject().projectId,
          );
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterSalesTarget(context);
        },
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: AppColor.grey,
                  indicator: BoxDecoration(
                    color: AppColor.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyle.ts14M(),
                  unselectedLabelStyle: AppTextStyle.ts14M(),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Sourcing Target'),
                    Tab(text: 'Closing Target'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                // SOURCING TARGET TAB
                BlocBuilder<TargetCubit, TargetState>(
                  builder: (context, state) {
                    if ((state.isLoading ?? true) &&
                        state.salesTargetSourcing.isEmpty) {
                      return Center(child: loader());
                    }

                    if (state.salesTargetSourcing.isEmpty) {
                      return Center(
                        child: noDataWidget(message: "No Data Found"),
                      );
                    }

                    return ListView.builder(
                      controller: _sourcingTargetScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.salesTargetSourcing.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.salesTargetSourcing.length) {
                          return state.salesTargetSourcing.length <
                                  state.sourcingTotalNumberOfRecordSalesTarget
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var termsAndCondition =
                            state.salesTargetSourcing[index];
                        return _buildSalesTargetSourcingCard(
                          saleTargetSourcingModel: termsAndCondition,
                          index: index,
                        );
                      },
                    );
                  },
                ),
                // BOOKING TAB
                BlocBuilder<TargetCubit, TargetState>(
                  builder: (context, state) {
                    if ((state.isLoading ?? true) &&
                        state.salesTargetClosing.isEmpty) {
                      return Center(child: loader());
                    }
                    if (state.salesTargetClosing.isEmpty) {
                      return Center(
                        child: noDataWidget(message: "No Data found"),
                      );
                    }
                    return ListView.builder(
                      controller: _closingTargetScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.salesTargetClosing.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.salesTargetClosing.length) {
                          return state.salesTargetClosing.length <
                                  state.closingTotalNumberOfRecordSalesTarget
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var termsAndCondition = state.salesTargetClosing[index];
                        return _buildSalesTargetClosingCard(
                          saleTargetClosingModel: termsAndCondition,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTargetSourcingCard({
    required int index,
    SalesTargetSourcingModel? saleTargetSourcingModel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  saleTargetSourcingModel?.employeeName ?? '',
                  style: AppTextStyle.ts14M(color: AppColor.primary),
                ),
              ),
            ],
          ),
          _leaveRow(
            title: "Bookings",
            value: saleTargetSourcingModel?.bookings.toString() ?? "",
          ),
          _leaveRow(
            title: "Total Meetings",
            value: saleTargetSourcingModel?.totalMeetings.toString() ?? "",
          ),
          _leaveRow(
            title: "Total OBM",
            value: saleTargetSourcingModel?.totalObm.toString() ?? "",
          ),
          _leaveRow(
            title: "Total OBM Frsh Visits",
            value:
                saleTargetSourcingModel?.totalObmFreshVisits.toString() ?? "",
          ),
          _leaveRow(
            title: "Total IBM",
            value: saleTargetSourcingModel?.totalIbm.toString() ?? "",
          ),
          _leaveRow(
            title: "Unique CP",
            value: saleTargetSourcingModel?.uniqueCPs.toString() ?? "",
          ),
          _leaveRow(
            title: "Active CP",
            value: saleTargetSourcingModel?.activeCp.toString() ?? "",
          ),
          _leaveRow(
            title: "New CP",
            value: saleTargetSourcingModel?.newCp.toString() ?? "",
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTargetClosingCard({
    required int index,
    SaleTargetClosingModel? saleTargetClosingModel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  saleTargetClosingModel?.employeeName ?? "",
                  style: AppTextStyle.ts14M(color: AppColor.primary),
                ),
              ),
            ],
          ),
          _leaveRow(
            title: "Walkins CP",
            value: saleTargetClosingModel?.walkinsByCp.toString() ?? "",
          ),
          _leaveRow(
            title: "Walkins Direct",
            value: saleTargetClosingModel?.walkinsDirect.toString() ?? "",
          ),
          _leaveRow(
            title: "Fresh Visits",
            value: saleTargetClosingModel?.freshVisits.toString() ?? "",
          ),
          _leaveRow(
            title: "Revisits",
            value: saleTargetClosingModel?.revisits.toString() ?? "",
          ),
          _leaveRow(
            title: "Bookings CP",
            value: saleTargetClosingModel?.bookingByCp.toString() ?? "",
          ),
          _leaveRow(
            title: "Bookings Direct",
            value: saleTargetClosingModel?.bookingDirect.toString() ?? "",
          ),
        ],
      ),
    );
  }

  Widget _leaveRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: AppTextStyle.ts14R(
                color: AppColor.black.withValues(alpha: 0.50),
              ),
            ),
          ),

          SizedBox(
            width: 24,
            child: Center(
              child: Text(
                ":",
                style: AppTextStyle.ts14R(
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value, style: AppTextStyle.ts14M()),
            ),
          ),
        ],
      ),
    );
  }
}
