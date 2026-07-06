import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class IbmObmReportScreen extends StatefulWidget {
  const IbmObmReportScreen({super.key});

  @override
  State<IbmObmReportScreen> createState() => _IbmObmReportScreenState();
}

class _IbmObmReportScreenState extends State<IbmObmReportScreen> {
  late IbmObmReportCubit _ibmObmReportCubit;
  late AuthorizationModel _routeAuthorizationModel;

  late TextEditingController _searchC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  final ValueNotifier<Map<String, dynamic>?> _selectedReportType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedProject = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedYear = ValueNotifier(
    null,
  );
  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);

  late ScrollController scrollController;
  Timer? _debounce;
  @override
  void initState() {
    _ibmObmReportCubit = context.read<IbmObmReportCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.ibmObmReport]!;
    _onScroll();
    _initializeTextEditingControllers();

    super.initState();
  }

  @override
  void dispose() {
    _searchC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _searchC = TextEditingController();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_ibmObmReportCubit.state.isLoading! &&
          _ibmObmReportCubit.state.ibmObmReportList.length <
              _ibmObmReportCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _ibmObmReportCubit.getIbmObmReport(
            context: context,
            pageNumber: _ibmObmReportCubit.state.currentPageNumber + 1,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterIbmObm(BuildContext context) async {
    final state = _ibmObmReportCubit.state;

    String selectedReportType = state.filterByReportType;
    String selectedYear = state.filterByYear;
    int? selectedProjectId = state.filterByProjectId;

    DateTime? selectedFromDate = state.filterByFromDate;
    DateTime? selectedToDate = state.filterByToDate;

    if (_selectedReportType.value == null && selectedReportType.isNotEmpty) {
      _selectedReportType.value =
          ibmObmReportType
              .where((e) => e['DisplayName'].toString() == selectedReportType)
              .first;
    }

    _selectedProject.value =
        selectedProjectId != null
            ? projectList.firstWhere(
              (e) => e['zAttributesId'] == selectedProjectId,
              orElse: () => <String, dynamic>{},
            )
            : null;
    if (_selectedYear.value == null && selectedYear.isNotEmpty) {
      _selectedYear.value =
          year.where((e) => e['DisplayName'] == selectedYear).first;
    }

    if (_startDateNotifier.value == null && selectedFromDate != null) {
      _startDateNotifier.value = selectedFromDate;
    }

    if (_endDateNotifier.value == null && selectedToDate != null) {
      _endDateNotifier.value = selectedToDate;
    }

    final String initialReportType = selectedReportType;
    final String initialYear = selectedYear;
    final int? initialProjectId = selectedProjectId;
    final DateTime? initialFromDate = selectedFromDate;
    final DateTime? initialToDate = selectedToDate;
    final String initialEmployeeName = _searchC.text;
    final Map<String, dynamic>? initialProjectMap = _selectedProject.value;
    final Map<String, dynamic>? initialReportTypeMap =
        _selectedReportType.value;

    final String? initialDirection =
        state.currentSortColumn == "EmployeeName"
            ? state.currentSortDirection
            : null;

    String? selectedDirection = initialDirection;

    bool applied = false;
    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        final bool onlyOneDateSet =
            (_startDateNotifier.value != null &&
                _endDateNotifier.value == null) ||
            (_endDateNotifier.value != null &&
                _startDateNotifier.value == null);
        manualClose =
            selectedReportType != initialReportType ||
            selectedYear != initialYear ||
            selectedProjectId != initialProjectId ||
            selectedFromDate != initialFromDate ||
            selectedToDate != initialToDate ||
            _searchC.text.trim() != initialEmployeeName ||
            selectedDirection != initialDirection;
        applyEnabled.value = manualClose && !onlyOneDateSet;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - IBM/OBM Report",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection =
                  selectedDirection == direction ? null : direction;

              updateApplyState(innerState);
            });
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
                          border: Border.all(color: AppColor.grey, width: 0.5),
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
                          border: Border.all(color: AppColor.grey, width: 0.5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),

                verticalSpacing(height: 20),

                ValueListenableBuilder(
                  valueListenable: _selectedReportType,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: "Report Type",
                      hintText: "Select Report Type",
                      initialValue: value,
                      dataList: ibmObmReportType,
                      onSelected: (value) {
                        _selectedReportType.value = value;
                        selectedReportType =
                            value['DisplayName']?.toString() ?? '';
                        _startDateNotifier.value = null;
                        _endDateNotifier.value = null;
                        selectedFromDate = null;
                        selectedToDate = null;
                        _selectedYear.value = null;
                        selectedYear = '';
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedReportType.value = null;
                        selectedReportType = '';
                        _startDateNotifier.value = null;
                        _endDateNotifier.value = null;
                        selectedFromDate = null;
                        selectedToDate = null;
                        _selectedYear.value = null;
                        selectedYear = '';
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),

                AnimatedBuilder(
                  animation: Listenable.merge([
                    _selectedReportType,
                    _startDateNotifier,
                    _endDateNotifier,
                  ]),
                  builder: (context, _) {
                    if (_selectedReportType.value == null) {
                      return const SizedBox.shrink();
                    }

                    if (_selectedReportType.value?['DisplayName'] != 'Date') {
                      return ValueListenableBuilder(
                        valueListenable: _selectedYear,
                        builder: (context, value, child) {
                          return CustomDropDownWidget(
                            title: "Year",
                            hintText: "Select Year",
                            initialValue: value,
                            dataList: year,
                            onSelected: (value) {
                              _selectedYear.value = value;
                              selectedYear =
                                  value['DisplayName']?.toString() ?? '';
                              updateApplyState(innerState);
                            },
                            onValueClear: () {
                              _selectedYear.value = null;
                              selectedYear = '';
                              updateApplyState(innerState);
                            },
                          );
                        },
                      );
                    }

                    return CustomFromToDatePicker(
                      initialFromDate: _startDateNotifier.value,
                      initialToDate: _endDateNotifier.value,
                      isRequired: false,
                      removeBottomMargin: false,
                      onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                        selectedFromDate = fromDate;
                        selectedToDate = toDate;

                        _startDateNotifier.value = fromDate;
                        _endDateNotifier.value = toDate;

                        updateApplyState(innerState);
                      },
                    );
                  },
                ),

                CustomTextField(
                  title: "Employee Name",
                  textController: _searchC,
                  hint: "Enter Employee Name",
                  onChangeFunction: (_) {
                    updateApplyState(innerState);
                  },
                ),

                ValueListenableBuilder(
                  valueListenable: _selectedProject,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: "All Project",
                      hintText: "Select Project",
                      initialValue: value,
                      dataList: projectList,
                      onSelected: (value) {
                        _selectedProject.value = value;
                        selectedProjectId = value['zAttributesId'] as int?;

                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedProject.value = null;
                        selectedProjectId = null;

                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        applied = true;

        selectedReportType = '';
        selectedProjectId = null;
        selectedFromDate = null;
        selectedToDate = null;
        selectedDirection = null;
        selectedYear = '';

        _searchC.clear();

        _selectedReportType.value = null;
        _selectedProject.value = null;
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _selectedYear.value = null;

        _ibmObmReportCubit.applyIbmObmFilterAndSort(
          column: '',
          direction: '',
          reportType: '',
          employeeName: '',
          fromDate: null,
          year: '',
          toDate: null,
          context: context,
          projectId: null,
        );
      },

      onApply: () {
        applied = true;
        _ibmObmReportCubit.applyIbmObmFilterAndSort(
          context: context,
          column:
              selectedDirection != null
                  ? "EmployeeName"
                  : state.currentSortColumn,
          direction: selectedDirection ?? state.currentSortDirection,
          reportType: selectedReportType,
          employeeName: _searchC.text.trim(),
          fromDate: selectedFromDate,
          toDate: selectedToDate,
          projectId: selectedProjectId,
          year: selectedYear,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    if (!applied && manualClose) {
      _searchC.text = initialEmployeeName;

      selectedReportType = initialReportType;
      selectedYear = initialYear;
      selectedProjectId = initialProjectId;
      selectedFromDate = initialFromDate;
      selectedToDate = initialToDate;
      selectedDirection = initialDirection;

      _selectedReportType.value = initialReportTypeMap;
      _selectedProject.value = initialProjectMap;
      _selectedYear.value =
          initialYear.isNotEmpty
              ? year.firstWhere(
                (e) => e['DisplayName'] == initialYear,
                orElse: () => {},
              )
              : null;

      _startDateNotifier.value = initialFromDate;
      _endDateNotifier.value = initialToDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IbmObmReportCubit, IbmObmReportState>(
      listener: (context, state) {
        _filterCount.value = _ibmObmReportCubit.updateFilterCount(state);
      },

      child: Scaffold(
        appBar: CustomAppBar(
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          screenTitle: "IBM OBM Report",
          textController: _searchC,
          onSearchSubmit: (value) {
            _ibmObmReportCubit.search(value: value, context: context);
          },
          searchHintText: "Search By Employee Name",
          onExportCallback: (exportType) {
            if (_ibmObmReportCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _ibmObmReportCubit.getIbmObmReportForExport(
              context,
              exportType,
              pageNumber: 1,
            );
          },
          isFilterOn: true,
          onFilterTap: () => _showBottomSheetToFilterIbmObm(context),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              BlocBuilder<IbmObmReportCubit, IbmObmReportState>(
                builder: (context, state) {
                  if ((state.isLoading ?? true) &&
                      state.ibmObmReportList.isEmpty) {
                    return Expanded(child: Center(child: loader()));
                  }
                  if (state.ibmObmReportList.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: noDataWidget(message: 'No IBM OBM Report Found'),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      separatorBuilder:
                          (context, index) => verticalSpacing(height: 12.h),
                      shrinkWrap: true,
                      itemCount: state.ibmObmReportList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.ibmObmReportList.length) {
                          return state.ibmObmReportList.length <
                                  state.totalNumberOfRecord
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var ibmObm = state.ibmObmReportList[index];

                        final int totalIbm = ibmObm.ibmObmStagesData
                            .where(
                              (element) =>
                                  element.stages.toLowerCase() == 'ibm',
                            )
                            .fold(0, (sum, e) => sum + e.stagesCount);
                        final int totalObm = ibmObm.ibmObmStagesData
                            .where(
                              (element) =>
                                  element.stages.toLowerCase() == 'obm',
                            )
                            .fold(0, (sum, e) => sum + e.stagesCount);
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.h,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _ibmObmReportCubit
                                          .initializeViewFilters();
                                      goRouter.pushNamed(
                                        AppRoutes.viewIbmObmReport,
                                        queryParameters: {
                                          'employeeId':
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  ibmObm.employeeId.toString(),
                                                ),
                                              ),
                                          'employeeName':
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  ibmObm.fullName,
                                                ),
                                              ),
                                        },
                                      );
                                    },
                                    child: Text(
                                      ibmObm.fullName,
                                      style: AppTextStyle.ts16M(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "(${ibmObm.designationName})",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  buildColumnTitleValue(
                                    title: "Total IBM",
                                    value: totalIbm.toString(),
                                    valueTextStyle:
                                        totalIbm > 0
                                            ? AppTextStyle.ts14SB(
                                              color: AppColor.green,
                                            )
                                            : AppTextStyle.ts14M(),
                                  ),
                                  buildColumnTitleValue(
                                    title: "Total OBM",
                                    value: totalObm.toString(),
                                    valueTextStyle:
                                        totalObm > 0
                                            ? AppTextStyle.ts14SB(
                                              color: AppColor.green,
                                            )
                                            : AppTextStyle.ts14M(),
                                  ),
                                ],
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
      ),
    );
  }
}
