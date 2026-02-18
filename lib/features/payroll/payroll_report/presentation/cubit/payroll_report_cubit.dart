import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
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
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'EmployeeName': state.searchText,
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
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

  // <---- GET OUTDOOR LIST ---->
  Future getOutdoorList(
    BuildContext context,
    int pageNumber, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
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
        emit(
          state.copyWith(
            outdoorList: updatedList,
            isLoading: false,
            totalNumberOfRecordOutdoor: response["totalNumberOfRecord"],
            currentPageOutdoor: pageNumber,
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
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
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
        emit(
          state.copyWith(
            leaveList: updatedList,
            isLoading: false,
            totalNumberOfRecordLeave: response["totalNumberOfRecord"],
            currentPageLeave: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET RESIGNATION LIST ---->
  Future getResignationList(
    BuildContext context,
    int pageNumber, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'ResignationDateFrom': DateFormat('yyyy-MM-dd').format(startDate),
      'ResignationDateTo': DateFormat('yyyy-MM-dd').format(endDate),
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
        emit(
          state.copyWith(
            resignationList: updatedList,
            isLoading: false,
            totalNumberOfRecordResignation: response["totalNumberOfRecord"],
            currentPageResignation: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET ATTENDANCE REGULARIZATION LIST ---->
  Future getAttendanceRegularizationList(
    BuildContext context,
    int pageNumber, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "StartDate": startDate.toIso8601String(),
      "EndDate": endDate.toIso8601String(),
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
        emit(
          state.copyWith(
            regularizationList: updatedList,
            isLoading: false,
            totalNumberOfRecordRegurization: response["totalNumberOfRecord"],
            currentPageRegurization: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET COMP OFF LIST ---->
  Future getCompOffList(
    BuildContext context,
    int pageNumber, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {
      'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
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
        emit(
          state.copyWith(
            compOffList: updatedList,
            isLoading: false,
            totalNumberOfRecordCompOff: response["totalNumberOfRecord"],
            currentPageCompOff: pageNumber,
          ),
        );
      },
    );
  }

  // <---- CLEAR FILTER ON COMP OFF ---->
  void clearFilterOnPayrollReport(BuildContext context) {
    emit(
      state.copyWith(
        clearFilters: true,
        attendanceList: [],
        currentPageAttendance: 1,
      ),
    );
    getPayrollReportList(context, 1);
  }

  // <---- APPLY FILTER ON COMP OFF ---->
  void applyFilterOnCompOff({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    emit(
      state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
        compOffList: [],
        currentPageAttendance: 1,
      ),
    );
    getPayrollReportList(context, 1);
  }
}
