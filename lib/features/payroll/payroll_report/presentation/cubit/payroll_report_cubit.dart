import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance_regularization.model.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/repository/attendance.repository.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/repository/comp_off.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/data/repository/leave.repository.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/repository/outdoor.repository.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/data/repository/payroll_report.repository.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/repository/resignation.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'payroll_report_state.dart';

class PayrollReportCubit extends Cubit<PayrollReportState> {
  PayrollReportCubit() : super(PayrollReportState.initial());

  // REPOSITORIES
  final AttendanceRepository _attendanceRepository =
      serviceLocator<AttendanceRepository>();

  final OutdoorRepository _outdoorRepository =
      serviceLocator<OutdoorRepository>();

  final LeaveRepository _leaveRepository = serviceLocator<LeaveRepository>();

  final ResignationRepository _resignationRepository =
      serviceLocator<ResignationRepository>();
  final CompOffRepository _compOffRepository =
      serviceLocator<CompOffRepository>();
  final PayrollReportRepository _payrollReportRepository =
      serviceLocator<PayrollReportRepository>();

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void search(String value) {
    emit(state.copyWith(searchText: value.trim()));
  }

  // <---- SEARCH PAYROLL REPORT ---->
  Future searchPayrollReport(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, attendanceList: []));
    await getPayrollReportList(context, 1);
  }

  // <---- GET COMP OFF LIST ---->
  Future getPayrollReportList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {};
    if (state.filterStartDate != null) {
      queryParams["StartDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterStartDate!);
    }
    if (state.filterEndDate != null) {
      queryParams["EndDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterEndDate!);
    }
    var result = await _attendanceRepository.getAttendanceList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<AttendanceModel> newData = List<AttendanceModel>.from(
          response['data'] ?? [],
        );

        final List<AttendanceModel> updatedList =
            pageNumber == 1 ? newData : [...state.attendanceList, ...newData];
        emit(
          state.copyWith(
            attendanceList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET ATTENDANCE LIST ---->
  Future getAttendanceList(
    BuildContext context,
    int pageNumber, {
    required DateTime startDate,
    required DateTime endDate,
    required int isReport,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'EmployeeName': state.searchText,
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
      'isReport': "true",
    };
    var result = await _attendanceRepository.getAttendanceList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<AttendanceModel> newData = List<AttendanceModel>.from(
          response['data'] ?? [],
        );

        final List<AttendanceModel> updatedList =
            pageNumber == 1 ? newData : [...state.attendanceList, ...newData];
        emit(
          state.copyWith(
            attendanceList: updatedList,
            isLoading: false,
            totalNumberOfRecordAttendance: response["totalNumberOfRecord"],
            currentPageAttendance: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET LEAVE LIST ---->
  Future getLeaveList({
    required BuildContext context,
    required int pageNumber,
    required DateTime startDate,
    required DateTime endDate,
    bool canApprove = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
      "isReport": true,
      "canApprove": canApprove,
    };

    var result = await _leaveRepository.getLeaveList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<LeaveModel> newData = List<LeaveModel>.from(
          response['data'] ?? [],
        );

        final List<LeaveModel> updatedList =
            pageNumber == 1 ? newData : [...state.leaveList, ...newData];

        if (!canApprove) {
          emit(
            state.copyWith(
              leaveList: updatedList,
              isLoading: false,
              totalNumberOfRecordLeave: response["totalNumberOfRecord"],
              currentPageLeave: pageNumber,
            ),
          );
        } else {
          emit(
            state.copyWith(
              approvalLeaveList: updatedList,
              isLoading: false,
              totalNumberOfRecordApprovalLeave: response["totalNumberOfRecord"],
              currentPageApprovalLeave: pageNumber,
            ),
          );
        }
      },
    );
  }

  // <---- GET COMP OFF LIST ---->
  Future getCompOffList({
    required BuildContext context,
    required int pageNumber,
    required DateTime startDate,
    required DateTime endDate,
    bool canApprove = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
      "isReport": true,
      "canApprove": canApprove,
    };

    var result = await _compOffRepository.getCompOffList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CompOffModel> newData = List<CompOffModel>.from(
          response['data'] ?? [],
        );

        final List<CompOffModel> updatedList =
            pageNumber == 1 ? newData : [...state.compOffList, ...newData];

        if (!canApprove) {
          emit(
            state.copyWith(
              compOffList: updatedList,
              isLoading: false,
              totalNumberOfRecordCompOff: response["totalNumberOfRecord"],
              currentPageCompOff: pageNumber,
            ),
          );
        } else {
          emit(
            state.copyWith(
              approvalCompOffList: updatedList,
              isLoading: false,
              totalNumberOfRecordApprovalCompOff:
                  response["totalNumberOfRecord"],
              currentPageApprovalCompOff: pageNumber,
            ),
          );
        }
      },
    );
  }

  // <---- GET OUTDOOR LIST ---->
  Future getOutdoorList({
    required BuildContext context,
    required int pageNumber,
    required DateTime startDate,
    required DateTime endDate,
    bool canApprove = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
      "isReport": true,
      "canApprove": canApprove,
    };

    var result = await _outdoorRepository.getOutdoorList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<OutdoorModel> newData = List<OutdoorModel>.from(
          response['data'] ?? [],
        );

        final List<OutdoorModel> updatedList =
            pageNumber == 1 ? newData : [...state.outdoorList, ...newData];

        if (!canApprove) {
          emit(
            state.copyWith(
              outdoorList: updatedList,
              isLoading: false,
              totalNumberOfRecordOutdoor: response["totalNumberOfRecord"],
              currentPageOutdoor: pageNumber,
            ),
          );
        } else {
          emit(
            state.copyWith(
              approvalOutdoorList: updatedList,
              isLoading: false,
              totalNumberOfRecordApprovalOutdoor:
                  response["totalNumberOfRecord"],
              currentPageApprovalOutdoor: pageNumber,
            ),
          );
        }
      },
    );
  }

  // <---- GET RESIGNATION LIST ---->
  Future getResignationList({
    required BuildContext context,
    required int pageNumber,
    required DateTime startDate,
    required DateTime endDate,
    bool canApprove = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'ResignationDateFrom': DateFormat('yyyy-MM-dd').format(startDate),
      'ResignationDateTo': DateFormat('yyyy-MM-dd').format(endDate),
      "isReport": true,
      "canApprove": canApprove,
    };

    var result = await _resignationRepository.getResignationList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ResignationModel> newData = List<ResignationModel>.from(
          response['data'] ?? [],
        );

        final List<ResignationModel> updatedList =
            pageNumber == 1 ? newData : [...state.resignationList, ...newData];

        if (!canApprove) {
          emit(
            state.copyWith(
              resignationList: updatedList,
              isLoading: false,
              totalNumberOfRecordResignation: response["totalNumberOfRecord"],
              currentPageResignation: pageNumber,
            ),
          );
        } else {
          emit(
            state.copyWith(
              approvalResignationList: updatedList,
              isLoading: false,
              totalNumberOfRecordApprovalResignation:
                  response["totalNumberOfRecord"],
              currentPageApprovalResignation: pageNumber,
            ),
          );
        }
      },
    );
  }

  // <---- GET ATTENDANCE REGULARIZATION LIST ---->
  Future getAttendanceRegularizationList({
    required BuildContext context,
    required int pageNumber,
    required DateTime startDate,
    required DateTime endDate,
    bool canApprove = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "StartDate": startDate.toIso8601String(),
      "EndDate": endDate.toIso8601String(),
      "isReport": true,
      "canApprove": canApprove,
    };

    var result = await _attendanceRepository.getAttendanceRegularizationList(
      pageNumber: pageNumber,
      pageSize: 50,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<AttendanceRegularizationModel> newData =
            List<AttendanceRegularizationModel>.from(response['data'] ?? []);

        final List<AttendanceRegularizationModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.regularizationList, ...newData];

        if (!canApprove) {
          emit(
            state.copyWith(
              regularizationList: updatedList,
              isLoading: false,
              totalNumberOfRecordRegurization: response["totalNumberOfRecord"],
              currentPageRegurization: pageNumber,
            ),
          );
        } else {
          emit(
            state.copyWith(
              approvalRegularizationList: updatedList,
              isLoading: false,
              totalNumberOfRecordApprovalRegularization:
                  response["totalNumberOfRecord"],
              currentPageApprovalRegularization: pageNumber,
            ),
          );
        }
      },
    );
  }

  // <---- CLEAR FILTER ON COMP OFF ---->
  void clearFilterOnPayrollReport(BuildContext context) {
    emit(
      state.copyWith(
        filterStartDate: null,
        filterEndDate: null,
        clearFilters: true,
      ),
    );

    final now = DateTime.now();

    switch (state.currentTabIndex) {
      case 0: // Attendance
        emit(state.copyWith(attendanceList: [], currentPageAttendance: 1));
        getAttendanceList(
          context,
          1,
          startDate: now,
          endDate: now,
          isReport: 1,
        );
        break;

      case 1: // Attendance Regularization
        if (state.leaveInnerTabIndex == 0) {
          // Report
          emit(
            state.copyWith(regularizationList: [], currentPageRegurization: 1),
          );
          getAttendanceRegularizationList(
            context: context,
            pageNumber: 1,
            startDate: now,
            endDate: now,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalRegularizationList: [],
              currentPageApprovalRegularization: 1,
            ),
          );
          getAttendanceRegularizationList(
            context: context,
            pageNumber: 1,

            startDate: now,
            endDate: now,
            canApprove: true,
          );
        }
        break;

      case 2: // Comp Off
        if (state.compOffInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(compOffList: [], currentPageCompOff: 1));
          getCompOffList(
            context: context,
            pageNumber: 1,

            startDate: now,
            endDate: now,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalCompOffList: [],
              currentPageApprovalCompOff: 1,
            ),
          );
          getCompOffList(
            context: context,
            pageNumber: 1,

            startDate: now,
            endDate: now,
            canApprove: true,
          );
        }
        break;

      case 3: // Leave
        if (state.leaveInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(leaveList: [], currentPageLeave: 1));
          getLeaveList(
            context: context,
            pageNumber: 1,
            startDate: now,
            endDate: now,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(approvalLeaveList: [], currentPageApprovalLeave: 1),
          );
          getLeaveList(
            context: context,
            pageNumber: 1,
            startDate: now,
            endDate: now,
            canApprove: true,
          );
        }
        break;

      case 4: // Outdoor
        if (state.outdoorInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(outdoorList: [], currentPageOutdoor: 1));
          getOutdoorList(
            context: context,
            pageNumber: 1,
            startDate: now,
            endDate: now,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalOutdoorList: [],
              currentPageApprovalOutdoor: 1,
            ),
          );
          getOutdoorList(
            context: context,
            pageNumber: 1,
            startDate: now,
            endDate: now,
            canApprove: true,
          );
        }
        break;

      case 5: // Resignation
        if (state.resignationInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(resignationList: [], currentPageResignation: 1));
          getResignationList(
            context: context,
            pageNumber: 1,
            startDate: now,
            endDate: now,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalResignationList: [],
              currentPageApprovalResignation: 1,
            ),
          );
          getResignationList(
            context: context,
            pageNumber: 1,

            startDate: now,
            endDate: now,
            canApprove: true,
          );
        }
        break;
    }
  }

  // <---- APPLY FILTER ON COMP OFF ---->
  void applyFilterOnPayrollReport({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    emit(state.copyWith(filterStartDate: startDate, filterEndDate: endDate));

    final DateTime start = startDate ?? DateTime.now();
    final DateTime end = endDate ?? DateTime.now();

    switch (state.currentTabIndex) {
      case 0: // Attendance
        emit(state.copyWith(attendanceList: [], currentPageAttendance: 1));
        getAttendanceList(
          context,
          1,
          startDate: start,
          endDate: end,
          isReport: 1,
        );
        break;

      case 1: // Attendance Regularization
        if (state.regularizationList.isEmpty || state.leaveInnerTabIndex == 0) {
          // Report
          emit(
            state.copyWith(regularizationList: [], currentPageRegurization: 1),
          );
          getAttendanceRegularizationList(
            context: context,
            pageNumber: 1,

            startDate: start,
            endDate: end,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalRegularizationList: [],
              currentPageApprovalRegularization: 1,
            ),
          );
          getAttendanceRegularizationList(
            context: context,
            pageNumber: 1,

            startDate: start,
            endDate: end,
            canApprove: true,
          );
        }
        break;

      case 2: // CompOff
        if (state.compOffInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(compOffList: [], currentPageCompOff: 1));
          getCompOffList(
            context: context,
            pageNumber: 1,

            startDate: start,
            endDate: end,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalCompOffList: [],
              currentPageApprovalCompOff: 1,
            ),
          );
          getCompOffList(
            context: context,
            pageNumber: 1,

            startDate: start,
            endDate: end,
            canApprove: true,
          );
        }
        break;

      case 3: // Leave
        if (state.leaveInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(leaveList: [], currentPageLeave: 1));
          getLeaveList(
            context: context,
            pageNumber: 1,
            startDate: start,
            endDate: end,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(approvalLeaveList: [], currentPageApprovalLeave: 1),
          );
          getLeaveList(
            context: context,
            pageNumber: 1,
            startDate: start,
            endDate: end,
            canApprove: true,
          );
        }
        break;

      case 4: // Outdoor
        if (state.outdoorInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(outdoorList: [], currentPageOutdoor: 1));
          getOutdoorList(
            context: context,
            pageNumber: 1,
            startDate: start,
            endDate: end,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalOutdoorList: [],
              currentPageApprovalOutdoor: 1,
            ),
          );
          getOutdoorList(
            context: context,
            pageNumber: 1,
            startDate: start,
            endDate: end,
            canApprove: true,
          );
        }
        break;

      case 5: // Resignation
        if (state.resignationInnerTabIndex == 0) {
          // Report
          emit(state.copyWith(resignationList: [], currentPageResignation: 1));
          getResignationList(
            context: context,
            pageNumber: 1,

            startDate: start,
            endDate: end,
            canApprove: false,
          );
        } else {
          // Approval
          emit(
            state.copyWith(
              approvalResignationList: [],
              currentPageApprovalResignation: 1,
            ),
          );
          getResignationList(
            context: context,
            pageNumber: 1,
            startDate: start,
            endDate: end,
            canApprove: true,
          );
        }
        break;
    }
  }

  // Toggle selection of an individual item
  void toggleSelection({required int id, required int listLength}) {
    switch (state.currentTabIndex) {
      case 1: // Regularization
        final updated = Set<int>.from(state.selectedRegularizationIds);
        if (updated.contains(id)) {
          updated.remove(id);
        } else {
          updated.add(id);
        }

        emit(
          state.copyWith(
            selectedRegularizationIds: updated,
            isAllRegularizationSelected: updated.length == listLength,
          ),
        );
        break;

      case 2: // CompOff
        final updated = Set<int>.from(state.selectedCompOffIds);
        if (updated.contains(id)) {
          updated.remove(id);
        } else {
          updated.add(id);
        }

        emit(
          state.copyWith(
            selectedCompOffIds: updated,
            isAllCompOffSelected: updated.length == listLength,
          ),
        );
        break;

      case 3: // Leave
        final updated = Set<int>.from(state.selectedLeaveIds);
        if (updated.contains(id)) {
          updated.remove(id);
        } else {
          updated.add(id);
        }

        emit(
          state.copyWith(
            selectedLeaveIds: updated,
            isAllLeaveSelected: updated.length == listLength,
          ),
        );
        break;

      case 4: // Outdoor
        final updated = Set<int>.from(state.selectedOutdoorIds);
        if (updated.contains(id)) {
          updated.remove(id);
        } else {
          updated.add(id);
        }

        emit(
          state.copyWith(
            selectedOutdoorIds: updated,
            isAllOutdoorSelected: updated.length == listLength,
          ),
        );
        break;

      case 5: // Resignation
        final updated = Set<int>.from(state.selectedResignationIds);
        if (updated.contains(id)) {
          updated.remove(id);
        } else {
          updated.add(id);
        }

        emit(
          state.copyWith(
            selectedResignationIds: updated,
            isAllResignationSelected: updated.length == listLength,
          ),
        );
        break;
    }
  }

  // Toggle select all items for the current tab
  void toggleSelectAll() {
    switch (state.currentTabIndex) {
      case 1: // Regularization
        final newValue = !state.isAllRegularizationSelected;
        emit(
          state.copyWith(
            isAllRegularizationSelected: newValue,
            selectedRegularizationIds:
                newValue
                    ? state.regularizationList
                        .map((e) => e.attendanceRegularizationId)
                        .toSet()
                    : {},
          ),
        );
        break;

      case 2: // CompOff
        final newValue = !state.isAllCompOffSelected;
        emit(
          state.copyWith(
            isAllCompOffSelected: newValue,
            selectedCompOffIds:
                newValue
                    ? state.compOffList.map((e) => e.compOffId).toSet()
                    : {},
          ),
        );
        break;

      case 3: // Leave
        final newValue = !state.isAllLeaveSelected;
        emit(
          state.copyWith(
            isAllLeaveSelected: newValue,
            selectedLeaveIds:
                newValue ? state.leaveList.map((e) => e.leaveId).toSet() : {},
          ),
        );
        break;

      case 4: // Outdoor
        final newValue = !state.isAllOutdoorSelected;
        emit(
          state.copyWith(
            isAllOutdoorSelected: newValue,
            selectedOutdoorIds:
                newValue
                    ? state.outdoorList.map((e) => e.outdoorId).toSet()
                    : {},
          ),
        );
        break;

      case 5: // Resignation
        final newValue = !state.isAllResignationSelected;
        emit(
          state.copyWith(
            isAllResignationSelected: newValue,
            selectedResignationIds:
                newValue
                    ? state.resignationList
                        .map((e) => e.employeeResignationId)
                        .toSet()
                    : {},
          ),
        );
        break;
    }
  }

  // Update inner tab index for leave
  void onLeaveInnerTabChanged(int index) {
    emit(state.copyWith(leaveInnerTabIndex: index));
  }

  // Update inner tab index for comp off
  void onCompOffInnerTabChanged(int index) {
    emit(state.copyWith(compOffInnerTabIndex: index));
  }

  // Update inner tab index for outdoor
  void onOutdoorInnerTabChanged(int index) {
    emit(state.copyWith(outdoorInnerTabIndex: index));
  }

  // Update inner tab index for resignation
  void onResignationInnerTabChanged(int index) {
    emit(state.copyWith(resignationInnerTabIndex: index));
  }

  // Update inner tab index for regularization
  void onRegularizationInnerTabChanged(int index) {
    emit(state.copyWith(regularizationInnerTabIndex: index));
  }

  // Reset selection for approval tab
  void resetApprovalTabSelection() {
    switch (state.currentTabIndex) {
      case 1: // Regularization
        emit(
          state.copyWith(
            isAllRegularizationSelected: false,
            selectedRegularizationIds: {},
          ),
        );
        break;

      case 2: // CompOff
        emit(
          state.copyWith(isAllCompOffSelected: false, selectedCompOffIds: {}),
        );
        break;

      case 3: // Leave
        emit(state.copyWith(isAllLeaveSelected: false, selectedLeaveIds: {}));
        break;

      case 4: // Outdoor
        emit(
          state.copyWith(isAllOutdoorSelected: false, selectedOutdoorIds: {}),
        );
        break;

      case 5: // Resignation
        emit(
          state.copyWith(
            isAllResignationSelected: false,
            selectedResignationIds: {},
          ),
        );
        break;
    }
  }

  // Reset inner tab index for approval tab
  void resetApprovalTab() {
    switch (state.currentTabIndex) {
      case 1: // Regularization
        emit(state.copyWith(regularizationInnerTabIndex: 0));
        break;

      case 2: // CompOff
        emit(state.copyWith(compOffInnerTabIndex: 0));
        break;

      case 3: // Leave
        emit(state.copyWith(leaveInnerTabIndex: 0));
        break;

      case 4: // Outdoor
        emit(state.copyWith(outdoorInnerTabIndex: 0));
        break;

      case 5: // Resignation
        emit(state.copyWith(resignationInnerTabIndex: 0));
        break;
    }
  }

  String _getModuleName() {
    switch (state.currentTabIndex) {
      case 2:
        return "COMPOFF";
      case 3:
        return "Leave";
      case 4:
        return "OUTDOOR";
      case 5:
        return "RESIGNATION";
      default:
        return "";
    }
  }

  List<int> _getSelectedApprovalIds() {
    switch (state.currentTabIndex) {
      case 2:
        return state.selectedCompOffIds.toList();

      case 3:
        return state.selectedLeaveIds.toList();

      case 4:
        return state.selectedOutdoorIds.toList();

      case 5:
        return state.selectedResignationIds.toList();

      default:
        return [];
    }
  }

  Future<bool> approveRejectSelected({
    required BuildContext context,
    required bool isApproved,
    required String remark,
    required int projectId,
  }) async {
    final moduleName = _getModuleName();
    final approvalIds = _getSelectedApprovalIds();

    if (approvalIds.isEmpty) {
      showErrorMessage(context, "Error", "Please select at least one item");
      return false;
    }

    final List<Map<String, dynamic>> approvalList =
        (approvalIds).map((e) {
          return {
            "ModuleName": moduleName,
            "Id": e,
            "Status": isApproved ? "Approved" : "Rejected",
            "Remarks": remark,
          };
        }).toList();
    final payload = {"ApprovalJson": jsonEncode(approvalList)};
    final result = await _payrollReportRepository.addApproval(body: payload);
    final isSuccess = result.fold(
      (failure) {
        showErrorMessage(context, "Approval Failed", failure.message);
        return false;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Updated Successfully",
        );
        return true;
      },
    );

    resetApprovalTabSelection();
    return isSuccess;
  }
}
