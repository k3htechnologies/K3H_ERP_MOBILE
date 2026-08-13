import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/otp_logs/presentation/cubit/otp_logs_cubit.dart';
import 'package:k3h_erp_app/features/more/otp_logs/presentation/pages/widget/otp_logs.datasource.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OtpLogsScreen extends StatefulWidget {
  const OtpLogsScreen({super.key});

  @override
  State<OtpLogsScreen> createState() => _OtpLogsScreenState();
}

class _OtpLogsScreenState extends State<OtpLogsScreen>
    with SingleTickerProviderStateMixin {
  late OtpLogsCubit _otpLogsCubit;
  late AuthorizationModel _routeAuthorizationModel;
  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC, _filterMobileNumberC, _filterModuleNameC;
  final ValueNotifier<DateTime?> _filterFromDateNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _filterToDateNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  // TAB CONTROLLER
  late TabController _tabController;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  late ProjectModel _selectedProject;

  List<String> modules = ["BOOKING", "ENQUIRY"];
  String selectedModule = "BOOKING";
  @override
  void initState() {
    super.initState();
    _initialiseControllers();
    _otpLogsCubit = context.read<OtpLogsCubit>();
    _selectedProject = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.otpLogs]!;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    _otpLogsCubit.getCallLogsList(context, 1, _selectedProject.projectId);
    _onScroll();
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterCount.dispose();
    _filterMobileNumberC.dispose();
    _filterModuleNameC.dispose();
    _filterFromDateNotifier.dispose();
    _filterToDateNotifier.dispose();
    super.dispose();
  }

  void _initialiseControllers() {
    _searchC = TextEditingController();
    _filterMobileNumberC = TextEditingController();
    _filterModuleNameC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_otpLogsCubit.state.isLoading! &&
          _otpLogsCubit.state.ticketList.length <
              _otpLogsCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _otpLogsCubit.getCallLogsList(
            context,
            _otpLogsCubit.state.currentPage + 1,
            _selectedProject.projectId,
          );
        });
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      selectedModule = modules[_tabController.index];
    });
  }

  Future<void> _showBottomSheetToTicket(BuildContext context) async {
    final state = _otpLogsCubit.state;
    _searchC.text = state.searchText;
    _filterMobileNumberC.text = state.filterMobileNumber;
    _filterModuleNameC.text = state.filterModuleName;

    _filterFromDateNotifier.value = state.filterFromDate;
    _filterToDateNotifier.value = state.filterToDate;

    final String initialMobileNumber = _filterMobileNumberC.text;
    final String initialModuleName = _filterModuleNameC.text;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool manualClose = false;
    bool applied = false;
    final filterFormKey = GlobalKey<FormState>();
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterMobileNumberC.text.trim() != initialMobileNumber ||
                (_filterModuleNameC.text.trim() != initialModuleName) ||
                (_filterFromDateNotifier.value != state.filterFromDate) ||
                (_filterToDateNotifier.value != state.filterToDate));

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - OTP Logs",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  textController: _filterMobileNumberC,
                  hint: "Enter Mobile Number",
                  title: "Mobile Number",
                  inputFormatterList: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  textController: _filterModuleNameC,
                  hint: "Enter Module Name",
                  title: "Module Name",
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _filterFromDateNotifier,
                        builder: (context, fromDate, child) {
                          return CustomDatePicker(
                            title: "From Date",
                            initialDate: fromDate,
                            setValue: (value) {
                              _filterFromDateNotifier.value = value;
                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _filterToDateNotifier,
                        builder: (context, toDate, child) {
                          return CustomDatePicker(
                            title: "To Date",
                            initialDate: toDate,
                            setValue: (value) {
                              _filterToDateNotifier.value = value;
                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
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
        _filterMobileNumberC.clear();
        _filterModuleNameC.clear();
        _filterFromDateNotifier.value = null;
        _filterToDateNotifier.value = null;

        _otpLogsCubit.applyFilterAndSort(
          context: context,
          projectId: _selectedProject.projectId,
          isClear: true,
        );
      },
      onApply: () {
        applied = true;
        final startDate = _filterFromDateNotifier.value;

        final endDate = _filterToDateNotifier.value;

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

        if (filterFormKey.currentState?.validate() ?? false) {
          _otpLogsCubit.applyFilterAndSort(
            context: context,
            mobileNumber: _filterMobileNumberC.text.trim(),
            projectId: _selectedProject.projectId,
            moduleName: _filterModuleNameC.text.trim(),
            fromDate: startDate,
            toDate: endDate,
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterMobileNumberC.clear();
      _filterModuleNameC.clear();
      _filterFromDateNotifier.value = null;
      _filterToDateNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpLogsCubit, OtpLogsState>(
      listener: (context, state) {
        _filterCount.value = _otpLogsCubit.updateFilterCount(state);
      },
      child: BlocBuilder<OtpLogsCubit, OtpLogsState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.ticketList.isEmpty) {
            return Center(child: loader());
          }
          final filteredList =
              state.ticketList
                  .where(
                    (e) =>
                        e.module.toUpperCase() == selectedModule.toUpperCase(),
                  )
                  .toList();
          return Scaffold(
            appBar: CustomAppBar(
              screenTitle: "OTP Logs",
              authorization: _routeAuthorizationModel,
              textController: _searchC,
              showNotification: true,
              filterCountNotifier: _filterCount,
              onSearchSubmit: (value) {
                _otpLogsCubit.searchOtpLogs(
                  context,
                  value,
                  _selectedProject.projectId,
                );
              },
              onProjectChangeCallback: (value) {
                _selectedProject = value;
                _otpLogsCubit.getCallLogsList(
                  context,
                  1,
                  _selectedProject.projectId,
                );
              },
              searchHintText: "Search by Mobile Number",
              onExportCallback: (value) {
                if (_otpLogsCubit.state.totalNumberOfRecord == 0) {
                  showErrorMessage(context, "Error", "No Data Found");
                  return;
                }
                _otpLogsCubit.exportExcelPdf(context, value);
              },
              isFilterOn: true,
              onFilterTap: () {
                _showBottomSheetToTicket(context);
              },
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChipStyleTabBar(controller: _tabController, tabs: modules),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      children: [
                        state.ticketList.isNotEmpty
                            ? Expanded(
                              child: SfDataGridTheme(
                                data: SfDataGridThemeData(
                                  headerColor: AppColor.lightBlue2.withValues(
                                    alpha: 0.3,
                                  ),
                                  gridLineColor: AppColor.grey50,
                                  gridLineStrokeWidth: 0.5,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final dataSource = OtpLogsDataSource(
                                      context: context,
                                      rows: filteredList,
                                    );
                                    return SfDataGrid(
                                      source: dataSource,
                                      verticalScrollController:
                                          scrollController,
                                      rowHeight: 48.h,
                                      headerRowHeight: 48.h,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      gridLinesVisibility:
                                          GridLinesVisibility.horizontal,
                                      headerGridLinesVisibility:
                                          GridLinesVisibility.horizontal,
                                      columns: [
                                        GridColumn(
                                          columnName: 'label',
                                          label: Center(
                                            child: Text(
                                              'Mobile Number',
                                              style: AppTextStyle.ts12SB(),
                                            ),
                                          ),
                                        ),

                                        GridColumn(
                                          columnName: 'otp',
                                          label: Center(
                                            child: Text(
                                              'OTP',
                                              style: AppTextStyle.ts12SB(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            )
                            : Expanded(child: Center(child: noDataWidget())),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
