import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/pages/route_map_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayrollReportScreen extends StatefulWidget {
  const PayrollReportScreen({super.key});

  @override
  State<PayrollReportScreen> createState() => _PayrollReportScreenState();
}

class _PayrollReportScreenState extends State<PayrollReportScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late PayrollReportCubit _payrollReportCubit;

  // TEXT CONTROLLER
  late TextEditingController _searchC;

  // SELECTED DATE
  late ValueNotifier<DateTime> _selectedDateNotifier;

  // ATTENDANCE PAGINATION
  late ScrollController _attendanceScrollController;
  Timer? _attendanceDebounce;

  // COMP OFF PAGINATION
  late ScrollController _regularizationScrollerController;
  Timer? _regularizationDebounce;

  // COMP OFF PAGINATION
  late ScrollController _compOffScrollerController;
  Timer? _compOffDebounce;

  // LEAVE PAGINATION
  late ScrollController _leaveScrollController;
  Timer? _leaveDebounce;

  // OUTDOOR PAGINATION
  late ScrollController _outdoorScrollController;
  Timer? _outdoorDebounce;

  // RESIGNATION PAGINATION
  late ScrollController _resignationScrollController;
  Timer? _resignationDebounce;

  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  @override
  void initState() {
    super.initState();
    _payrollReportCubit = context.read<PayrollReportCubit>();
    _searchC = TextEditingController();
    _selectedDateNotifier = ValueNotifier(DateTime.now());
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    _attendanceScrollController = ScrollController();
    _regularizationScrollerController = ScrollController();
    _compOffScrollerController = ScrollController();
    _leaveScrollController = ScrollController();
    _outdoorScrollController = ScrollController();
    _resignationScrollController = ScrollController();
    _setupAttendancePagination();
    _setupRegularizationPagination();
    _setupCompOffPagination();
    _setupLeavePagination();
    _setupOutdoorPagination();
    _setupResignationPagination();
    _selectedDateNotifier.addListener(_onSelectedDateChanged);
    _loadDataForTab(_tabController.index);
  }

  @override
  void dispose() {
    _selectedDateNotifier.removeListener(_onSelectedDateChanged);
    _tabController.dispose();
    _searchC.dispose();
    _selectedDateNotifier.dispose();
    _attendanceDebounce?.cancel();
    _leaveDebounce?.cancel();
    _outdoorDebounce?.cancel();
    _resignationDebounce?.cancel();
    _attendanceScrollController.dispose();
    _leaveScrollController.dispose();
    _outdoorScrollController.dispose();
    _resignationScrollController.dispose();
    super.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final index = _tabController.index;
      _payrollReportCubit.onTabChanged(index, context);
      _loadDataForTab(index);
    }
  }

  // FORWARD ARROW CLICKED
  void _onForwardArrowClicked() {
    _selectedDateNotifier.value = _selectedDateNotifier.value.add(
      const Duration(days: 1),
    );
  }

  // BACK ARROW CLICKED
  void _onBackArrowClicked() {
    _selectedDateNotifier.value = _selectedDateNotifier.value.subtract(
      const Duration(days: 1),
    );
  }

  // WHEN SELECTED DATE CHANGES, REFETCH CURRENT TAB DATA
  void _onSelectedDateChanged() {
    final date = _selectedDateNotifier.value;
    switch (_tabController.index) {
      case 0:
        _payrollReportCubit.getAttendanceList(
          context,
          1,
          startDate: date,
          endDate: date,
          isReport: 1,
        );
        break;
      case 1:
        _payrollReportCubit.getAttendanceRegularizationList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
      case 2:
        _payrollReportCubit.getCompOffList(
          context,
          1,
          startDate: date,
          endDate: date,
        );

      case 3:
        _payrollReportCubit.getLeaveList(
          context: context,
          pageNumber: 1,
          startDate: date,
          endDate: date,
        );
        break;
      case 4:
        _payrollReportCubit.getOutdoorList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
        break;
      case 5:
        _payrollReportCubit.getResignationList(
          context,
          1,
          startDate: date,
          endDate: date,
        );
        break;
      default:
        break;
    }
  }

  // LOAD DATA BASED ON CURRENT TAB
  void _loadDataForTab(int index) {
    final date = _selectedDateNotifier.value;
    switch (index) {
      case 0: // Attendance
        if (_payrollReportCubit.state.attendanceList.isEmpty) {
          _payrollReportCubit.getAttendanceList(
            context,
            1,
            startDate: date,
            endDate: date,
            isReport: 1,
          );
        }
        break;
      case 1: // Regularize
        if (_payrollReportCubit.state.regularizationList.isEmpty) {
          _payrollReportCubit.getAttendanceRegularizationList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 2: //Comp Off
        if (_payrollReportCubit.state.compOffList.isEmpty) {
          _payrollReportCubit.getCompOffList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 3: // Leave
        if (_payrollReportCubit.state.leaveList.isEmpty) {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: 1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 4: // Outdoor
        if (_payrollReportCubit.state.outdoorList.isEmpty) {
          _payrollReportCubit.getOutdoorList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      case 5: // Resignation
        if (_payrollReportCubit.state.resignationList.isEmpty) {
          _payrollReportCubit.getResignationList(
            context,
            1,
            startDate: date,
            endDate: date,
          );
        }
        break;
      default:
        break;
    }
  }

  // <---- ATTENDANCE PAGINATION ---->
  void _setupAttendancePagination() {
    _attendanceScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_attendanceScrollController.position.pixels >=
              _attendanceScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.attendanceList.length < state.totalNumberOfRecordAttendance) {
        if (_attendanceDebounce?.isActive ?? false) {
          _attendanceDebounce?.cancel();
        }
        final date = _selectedDateNotifier.value;
        _attendanceDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getAttendanceList(
            context,
            state.currentPageAttendance + 1,
            startDate: date,
            endDate: date,
            isReport: 1,
          );
        });
      }
    });
  }

  // <---- REGULARIZATION PAGINATION ---->
  void _setupRegularizationPagination() {
    _regularizationScrollerController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_regularizationScrollerController.position.pixels >=
              _regularizationScrollerController.position.maxScrollExtent -
                  100 &&
          !(state.isLoading ?? false) &&
          state.regularizationList.length <
              state.totalNumberOfRecordRegurization) {
        if (_regularizationDebounce?.isActive ?? false) {
          _regularizationDebounce?.cancel();
        }
        final date = _selectedDateNotifier.value;
        _regularizationDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getAttendanceRegularizationList(
            context,
            state.currentPageRegurization + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- COMPOFF PAGINATION ---->
  void _setupCompOffPagination() {
    _compOffScrollerController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_compOffScrollerController.position.pixels >=
              _compOffScrollerController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.compOffList.length < state.totalNumberOfRecordCompOff) {
        if (_compOffDebounce?.isActive ?? false) _compOffDebounce?.cancel();
        final date = _selectedDateNotifier.value;
        _compOffDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getCompOffList(
            context,
            state.currentPageCompOff + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- LEAVE PAGINATION ---->
  void _setupLeavePagination() {
    _leaveScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_leaveScrollController.position.pixels >=
              _leaveScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.leaveList.length < state.totalNumberOfRecordLeave) {
        if (_leaveDebounce?.isActive ?? false) _leaveDebounce?.cancel();
        final date = _selectedDateNotifier.value;
        _leaveDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: state.currentPageLeave + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- OUTDOOR PAGINATION ---->
  void _setupOutdoorPagination() {
    _outdoorScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_outdoorScrollController.position.pixels >=
              _outdoorScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.outdoorList.length < state.totalNumberOfRecordOutdoor) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_outdoorDebounce?.isActive ?? false) _outdoorDebounce?.cancel();
        final date = _selectedDateNotifier.value;
        _outdoorDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getOutdoorList(
            context,
            state.currentPageOutdoor + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  // <---- RESIGNATION PAGINATION ---->
  void _setupResignationPagination() {
    _resignationScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_resignationScrollController.position.pixels >=
              _resignationScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.resignationList.length < state.totalNumberOfRecordResignation) {
        if (_resignationDebounce?.isActive ?? false) {
          _resignationDebounce?.cancel();
        }
        final date = _selectedDateNotifier.value;
        _resignationDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getResignationList(
            context,
            state.currentPageResignation + 1,
            startDate: date,
            endDate: date,
          );
        });
      }
    });
  }

  void _prefillFilterFromState() {
    final s = _payrollReportCubit.state;
    _startDateNotifier.value = s.filterStartDate;
    _endDateNotifier.value = s.filterEndDate;
  }

  // PAYROLL REPORT FILTER
  Future<void> _showBottomSheetToFilterPayrollReport(
    BuildContext context,
  ) async {
    _prefillFilterFromState();
    final state = _payrollReportCubit.state;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(
      state.filterStartDate != null || state.filterEndDate != null,
    );
    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Payroll Master",
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
        _payrollReportCubit.clearFilterOnPayrollReport(context);
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
        _payrollReportCubit.applyFilterOnCompOff(
          context: context,
          startDate: startDate,
          endDate: endDate,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        screenTitle: "Report",
        authorization: AuthorizationModel(),
        onSearchSubmit: (value) {
          _payrollReportCubit.searchPayrollReport(context, value);
        },
        textController: _searchC,
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterPayrollReport(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            tabs: [
              "Attendance",
              "Regularize",
              "Comp-Off",
              "Leave",
              "Outdoor",
              "Resignation",
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: BlocBuilder<PayrollReportCubit, PayrollReportState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _onBackArrowClicked,
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: AppColor.black.withValues(alpha: .5),
                        ),
                      ),
                      horizontalSpacing(width: 20),
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDateNotifier,
                        builder: (context, date, _) {
                          final startDate = state.filterStartDate;
                          final endDate = state.filterEndDate;
                          if (startDate != null && endDate != null) {
                            return Text(
                              "${formatDateTimeAsDDMMMYYYY(startDate)} - "
                              "${formatDateTimeAsDDMMMYYYY(endDate)}",
                              style: AppTextStyle.ts14M(),
                            );
                          }
                          if (startDate != null && endDate == null) {
                            return Text(
                              formatDateTimeAsDDMMMYYYY(startDate),
                              style: AppTextStyle.ts14M(),
                            );
                          }
                          return Text(
                            formatDateTimeAsDDMMMYYYY(date),
                            style: AppTextStyle.ts14M(),
                          );
                        },
                      ),

                      horizontalSpacing(width: 20),

                      InkWell(
                        onTap: _onForwardArrowClicked,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColor.black.withValues(alpha: .5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildAttendanceSection(),
                buildRegularizeSection(),
                buildCompOffSection(),
                buildLeaveSection(),
                buildOutdoorSection(),
                buildResignationSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD ATTENDANCE SECTION
  Widget buildAttendanceSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.attendanceList.isEmpty) {
          return Center(child: loader());
        }

        if (state.attendanceList.isEmpty) {
          return Center(child: noDataWidget(message: "No Attendance Found"));
        }

        final Map<String, List<AttendanceModel>> groupedData = {};

        for (final item in state.attendanceList) {
          final key = item.fullName;
          if (!groupedData.containsKey(key)) {
            groupedData[key] = [];
          }
          groupedData[key]!.add(item);
        }

        final employees = groupedData.keys.toList();

        return ListView.builder(
          controller: _attendanceScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: employees.length + 1,
          itemBuilder: (context, index) {
            /// Pagination loader
            if (index == employees.length) {
              return state.attendanceList.length <
                      state.totalNumberOfRecordAttendance
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final employeeName = employees[index];
            final employeeRecords = groupedData[employeeName]!;

            employeeRecords.sort(
              (a, b) => b.attendanceDate.compareTo(a.attendanceDate),
            );

            return _buildEmployeeExpansionTile(
              employeeName: employeeName,
              records: employeeRecords,
              state: state,
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeExpansionTile({
    required String employeeName,
    required List<AttendanceModel> records,
    required PayrollReportState state,
  }) {
    final bool isFilterApplied =
        state.filterStartDate != null || state.filterEndDate != null;

    AttendanceModel? todayRecord;
    if (!isFilterApplied) {
      final today = DateTime.now();
      try {
        todayRecord = records.firstWhere(
          (e) =>
              e.attendanceDate.year == today.year &&
              e.attendanceDate.month == today.month &&
              e.attendanceDate.day == today.day,
        );
      } catch (_) {
        todayRecord = records.first;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: commonCardDecoration(),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 6.0),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColor.black.withValues(alpha: 0.50),
        collapsedIconColor: AppColor.black.withValues(alpha: 0.50),
        shape: const Border(),
        collapsedShape: const Border(),
        title: _buildEmployeeHeader(
          employeeName: employeeName,
          record: todayRecord ?? records.first,
          isFilterApplied: isFilterApplied,
        ),
        children: [
          ..._buildEmployeeAttendanceList(
            isFilterApplied
                ? records
                : (todayRecord != null ? [todayRecord] : []),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader({
    required String employeeName,
    required AttendanceModel record,
    required bool isFilterApplied,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              CircleAvatar(radius: 18, child: Text(employeeName[0])),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: AppTextStyle.ts16M(color: AppColor.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEmployeeAttendanceList(List<AttendanceModel> list) {
    return list.map((attendance) {
      final bool hasLocation =
          attendance.startLatitude != 0 &&
          attendance.startLongitude != 0 &&
          attendance.endLatitude != 0 &&
          attendance.endLongitude != 0;

      return Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatDateTimeAsDDMMMYYYY(attendance.attendanceDate),
                    style: AppTextStyle.ts14M().copyWith(color: AppColor.black),
                  ),
                ),
                _statusChip(attendance.attendanceStatus),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _infoItem(
                    "Punch In Time",
                    attendance.punchIn != null
                        ? DateFormat('hh:mm a').format(attendance.punchIn!)
                        : "-",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoItem(
                    "Punch Out Time",
                    attendance.punchOut != null
                        ? DateFormat('hh:mm a').format(attendance.punchOut!)
                        : "-",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _infoItem(
                    "Punch In Address",
                    attendance.punchInAddress.isEmpty
                        ? "-"
                        : attendance.punchInAddress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoItem(
                    "Punch Out Address",
                    attendance.punchOutAddress.isEmpty
                        ? "-"
                        : attendance.punchOutAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _infoItem(
                    "Working Hours",
                    attendance.workingHours.isEmpty
                        ? "-"
                        : attendance.workingHours,
                  ),
                ),
                if (hasLocation) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MapScreen(
                                  startLatitude: attendance.startLatitude,
                                  startLongitude: attendance.startLongitude,
                                  endLatitude: attendance.endLatitude,
                                  endLongitude: attendance.endLongitude,
                                  polyline: attendance.polyline,
                                  distance: attendance.distance.toDouble(),
                                  attendanceDataModel: attendance,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        "View Location",
                        style: AppTextStyle.ts12M().copyWith(
                          color: AppColor.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Divider(color: AppColor.grey, thickness: 0.50),
            verticalSpacing(),
          ],
        ),
      );
    }).toList();
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12R(
            color: AppColor.grey.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.ts12M().copyWith(color: AppColor.black),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final normalized = status.toLowerCase().trim();

    Color bg;
    Color text;
    Color border;

    switch (normalized) {
      case "late in":
        text = const Color(0xFFE65100);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "early leave":
        text = const Color(0xFFF0B357);
        bg = text.withValues(alpha: 0.15);
        border = text;
        break;

      case "present":
        text = const Color(0xFF1B9E4B);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "absent":
        text = const Color(0xFFFF2D2D);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "halfday":
      case "half day":
        text = const Color(0xFF1389A5);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "checkout missing":
        text = const Color(0xFF8E3B52);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "week-off":
      case "week off":
      case "weekoff":
        text = const Color(0xFF3F5067);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "comp-off":
      case "comp off":
        text = const Color(0xFF4B5BD3);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "leave":
        text = const Color(0xFFD81B60);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "holiday":
        text = const Color(0xFF7B1FA2);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      default:
        text = AppColor.primary;
        bg = AppColor.lightBlue;
        border = AppColor.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        status.isEmpty ? "Pending" : status,
        style: AppTextStyle.ts12SB(color: text),
      ),
    );
  }

  // BUILD REGULARIZE SECTION
  Widget buildRegularizeSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.regularizationList.isEmpty) {
          return Center(child: loader());
        }

        if (state.regularizationList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _regularizationScrollerController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.regularizationList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.regularizationList.length) {
              return state.regularizationList.length <
                      state.totalNumberOfRecordRegurization
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final attendanceRegularize = state.regularizationList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Employee Name",
                            style: AppTextStyle.ts16M(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Designation",
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      _statusButton(''),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Punch In",
                    value:
                        attendanceRegularize.punchIn != null
                            ? DateFormat(
                              'hh:mm a',
                            ).format(attendanceRegularize.punchIn!)
                            : "-",
                  ),
                  buildRowTitleValue(
                    title: "Punch Out",
                    value:
                        attendanceRegularize.punchOut != null
                            ? DateFormat(
                              'hh:mm a',
                            ).format(attendanceRegularize.punchOut!)
                            : "-",
                  ),
                  buildRowTitleValue(
                    title: "Date",
                    value: formatDateTimeAsDDMMMYYYY(
                      attendanceRegularize.attendanceDate,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Reason",
                    value: attendanceRegularize.reason,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD COMP-OFF SECTION
  Widget buildCompOffSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.compOffList.isEmpty) {
          return Center(child: loader());
        }

        if (state.compOffList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _compOffScrollerController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.compOffList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.compOffList.length) {
              return state.compOffList.length < state.totalNumberOfRecordCompOff
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final compOff = state.compOffList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: NetworkImageWidget(
                            imageUrl:
                                "https://plus.unsplash.com/premium_photo-1667358091118-29e916ddbcc5?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fGh1c2t5fGVufDB8fDB8fHww",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(55),
                          ),
                          title: Text('Employee Name'),
                          subtitle: Text(
                            "Designation",
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      _statusButton(''),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "CompOff Date",
                    value: formatDateTimeAsDDMMMYYYY(compOff.compOffDate),
                  ),
                  buildRowTitleValue(
                    title: "Working Date",
                    value: formatDateTimeAsDDMMMYYYY(compOff.workingDate),
                  ),
                  buildRowTitleValue(title: "Reason", value: compOff.reason),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD LEAVE SECTION
  Widget buildLeaveSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.leaveList.isEmpty) {
          return Center(child: loader());
        }

        if (state.leaveList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _leaveScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.leaveList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.leaveList.length) {
              return state.leaveList.length < state.totalNumberOfRecordLeave
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final leave = state.leaveList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.createdBy,
                    style: AppTextStyle.ts16M(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Leave Type",
                    value: leave.leaveType,
                  ),
                  buildRowTitleValue(
                    title: "Start Date",
                    value: formatDateTimeAsDDMMMYYYY(leave.startDate),
                  ),
                  buildRowTitleValue(
                    title: "End Date",
                    value: formatDateTimeAsDDMMMYYYY(leave.endDate),
                  ),
                  buildRowTitleValue(
                    title: "No Of Days",
                    value: leave.noOfDays.toString(),
                  ),
                  buildRowTitleValue(title: "Reason", value: leave.reason),
                  buildRowTitleValue(
                    title: "Leave Status",
                    value: leave.leaveStatus,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD OUTDOOR SECTION
  Widget buildOutdoorSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.outdoorList.isEmpty) {
          return Center(child: loader());
        }

        if (state.outdoorList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _outdoorScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.outdoorList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.outdoorList.length) {
              return state.outdoorList.length < state.totalNumberOfRecordOutdoor
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final outdoor = state.outdoorList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outdoor.createdBy,
                    style: AppTextStyle.ts16M(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Date",
                    value: formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate),
                  ),
                  buildRowTitleValue(
                    title: "Time",
                    value: DateFormat('hh:mm a').format(outdoor.outDoorTime),
                  ),
                  buildRowTitleValue(
                    title: "Company",
                    value: outdoor.companyName,
                  ),
                  buildRowTitleValue(
                    title: "Department",
                    value: outdoor.departmentName,
                  ),
                  buildRowTitleValue(
                    title: "Accompanied By",
                    value: outdoor.accompaniedByName,
                  ),
                  buildRowTitleValue(title: "Purpose", value: outdoor.purpose),
                  if (outdoor.conclusion.isNotEmpty)
                    buildRowTitleValue(
                      title: "Conclusion",
                      value: outdoor.conclusion,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD RESIGNATION SECTION
  Widget buildResignationSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.resignationList.isEmpty) {
          return Center(child: loader());
        }

        if (state.resignationList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _resignationScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.resignationList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.resignationList.length) {
              return state.resignationList.length <
                      state.totalNumberOfRecordResignation
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final resignation = state.resignationList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          resignation.employeeName,
                          style: AppTextStyle.ts16M(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusButton(resignation.approvalStatus),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Resignation Date",
                    value: formatDateTimeAsDDMMMYYYY(
                      resignation.resignationDate,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Expected Relieving Date",
                    value: formatDateTimeAsDDMMMYYYY(
                      resignation.expectedRelievingDate,
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Reason Of Leaving",
                    value: resignation.reasonOfLeaving,
                  ),
                  buildRowTitleValue(
                    title: "Offer In Hand",
                    value: resignation.isAnyOfferInHand ? "Yes" : "No",
                  ),
                  buildRowTitleValue(
                    title: "Offer Amount",
                    value: resignation.offerAmount.toString(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // HELPER WIDGET FOR STATE
  Widget _statusButton(String status) {
    String status;
    status = '';

    late String buttonText;
    late Color bgColor;
    late Color textColor;

    switch (status) {
      default:
        buttonText = "Pending";
        bgColor = AppColor.darkBlue;
        textColor = AppColor.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(buttonText, style: AppTextStyle.ts14M(color: textColor)),
    );
  }
}
