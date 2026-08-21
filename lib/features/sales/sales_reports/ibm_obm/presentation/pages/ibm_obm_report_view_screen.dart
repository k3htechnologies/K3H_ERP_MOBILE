import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/data/model/ibm_obm_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_cubit.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_state.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/pages/widget/ibm_obm_report_datasource.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class IbmObmReportViewScreen extends StatefulWidget {
  final String employeeName;
  final int employeeId;
  const IbmObmReportViewScreen({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<IbmObmReportViewScreen> createState() => _IbmObmReportViewScreenState();
}

class _IbmObmReportViewScreenState extends State<IbmObmReportViewScreen> {
  late IbmObmReportCubit _ibmObmReportCubit;
  final ValueNotifier<Map<String, dynamic>?> _selectedReportType =
      ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> _selectedYear = ValueNotifier(
    null,
  );
  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _ibmObmReportCubit = context.read<IbmObmReportCubit>();
    _filterCount.value = getActiveFilterCount([
      (_ibmObmReportCubit.state.viewFilterByReportType.trim().isNotEmpty),
      (_ibmObmReportCubit.state.viewFilterByYear.trim().isNotEmpty),
      (_ibmObmReportCubit.state.viewFilterByFromDate != null),
      (_ibmObmReportCubit.state.viewFilterByToDate != null),
    ]);
    _ibmObmReportCubit.getIbmObmReportForView(
      employeeId: widget.employeeId,
      context: context,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    _filterCount.dispose();
    super.dispose();
  }

  Future<void> _showBottomSheetToFilterIbmObm(BuildContext context) async {
    final state = _ibmObmReportCubit.state;

    String selectedReportType = state.viewFilterByReportType;
    String selectedYear = state.viewFilterByYear;

    DateTime? selectedFromDate = state.viewFilterByFromDate;
    DateTime? selectedToDate = state.viewFilterByToDate;

    if (_selectedReportType.value == null && selectedReportType.isNotEmpty) {
      _selectedReportType.value =
          ibmObmReportType
              .where((e) => e['DisplayName'].toString() == selectedReportType)
              .first;
    }

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
    final DateTime? initialFromDate = selectedFromDate;
    final DateTime? initialToDate = selectedToDate;
    final Map<String, dynamic>? initialReportTypeMap =
        _selectedReportType.value;

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
            selectedFromDate != initialFromDate ||
            selectedToDate != initialToDate;
        applyEnabled.value = manualClose && !onlyOneDateSet;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - IBM/OBM Report",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          );
        },
      ),

      onClear: () {
        applied = true;

        selectedReportType = '';
        selectedFromDate = null;
        selectedToDate = null;
        selectedYear = '';

        _selectedReportType.value = null;
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _selectedYear.value = null;

        _ibmObmReportCubit.applyIbmObmFilterForView(
          reportType: '',
          fromDate: null,
          year: '',
          toDate: null,
          context: context,
          employeeId: widget.employeeId,
        );
      },

      onApply: () {
        applied = true;
        _ibmObmReportCubit.applyIbmObmFilterForView(
          context: context,
          reportType: selectedReportType,
          fromDate: selectedFromDate,
          toDate: selectedToDate,
          year: selectedYear,
          employeeId: widget.employeeId,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    _filterCount.value = getActiveFilterCount([
      selectedReportType.trim().isNotEmpty,
      selectedYear.trim().isNotEmpty,
      selectedFromDate != null,
      selectedToDate != null,
    ]);
    if (!applied) {
      _startDateNotifier.value = initialFromDate;
      _endDateNotifier.value = initialToDate;

      _selectedReportType.value = initialReportTypeMap;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "IBM OBM Report",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: BlocBuilder<IbmObmReportCubit, IbmObmReportState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.viewReportList.isEmpty) {
              return Center(child: loader());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.employeeName, style: AppTextStyle.ts16M()),

                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.lightBlue2.withValues(alpha: 0.5),
                    border: Border(
                      top: BorderSide(color: AppColor.grey50, width: 0.5),
                      left: BorderSide(color: AppColor.grey50, width: 0.5),
                      right: BorderSide(color: AppColor.grey50, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "DAILY PERFORMANCE LOG",
                          style: AppTextStyle.ts12SB(
                            color: AppColor.black.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomIconButton(
                            onPressed:
                                () => _showBottomSheetToFilterIbmObm(context),
                            icon: Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: AppColor.primary,
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _filterCount,
                            builder: (context, filterCount, child) {
                              if (filterCount <= 0) {
                                return SizedBox.shrink();
                              }
                              return Positioned(
                                top: -6,
                                right: -6,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    filterCount > 99 ? '99+' : '$filterCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child:
                      state.viewReportList.isEmpty
                          ? Center(
                            child: noDataWidget(
                              message: "No IBM OBM Report Found",
                            ),
                          )
                          : SfDataGridTheme(
                            data: SfDataGridThemeData(
                              headerColor: AppColor.lightBlue2.withValues(
                                alpha: 0.3,
                              ),
                              gridLineColor: AppColor.grey50,
                              gridLineStrokeWidth: 0.5,
                            ),

                            child: Builder(
                              builder: (context) {
                                final report = state.viewReportList.first;

                                final gridRows = buildRows(
                                  report.ibmObmStagesData,
                                  state.viewFilterByYear.isNotEmpty,
                                );

                                final dataSource = IbmObmReportDataSource(
                                  rows: gridRows,
                                );
                                return SfDataGrid(
                                  source: dataSource,
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
                                      label: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          state.viewFilterByYear.isNotEmpty
                                              ? 'MONTH'
                                              : 'DATE',
                                          style: AppTextStyle.ts12SB(),
                                        ),
                                      ),
                                    ),

                                    GridColumn(
                                      columnName: 'ibm',
                                      label: Center(
                                        child: Text(
                                          'IBM',
                                          style: AppTextStyle.ts12SB(),
                                        ),
                                      ),
                                    ),

                                    GridColumn(
                                      columnName: 'obm',
                                      label: Center(
                                        child: Text(
                                          'OBM',
                                          style: AppTextStyle.ts12SB(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<IbmObmGridRowModel> buildRows(
    List<IbmObmStageDataModel> stages,
    bool isMonthWise,
  ) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final item in stages) {
      final key =
          isMonthWise
              ? item.monthName
              : DateFormat('dd MMM').format(item.date!);

      grouped.putIfAbsent(key, () => {'label': key, 'ibm': 0, 'obm': 0});

      if (item.stages.toUpperCase() == 'IBM') {
        grouped[key]!['ibm'] = item.stagesCount;
      } else if (item.stages.toUpperCase() == 'OBM') {
        grouped[key]!['obm'] = item.stagesCount;
      }
    }

    return grouped.values
        .map(
          (e) => IbmObmGridRowModel(
            label: e['label'],
            ibm: e['ibm'],
            obm: e['obm'],
          ),
        )
        .toList();
  }
}
