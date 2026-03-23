import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/repository/attendance.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(AttendanceState.initial());

  // REPOSITORIES
  final AttendanceRepository _attendanceRepository =
      serviceLocator<AttendanceRepository>();

  // <---- GET ATTENDANCE LIST ---->
  Future getAttendanceList(
    BuildContext context,
    int pageNumber,
    DateTime startDate,
    DateTime endDate,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "StartDate": startDate.toIso8601String(),
      "EndDate": endDate.toIso8601String(),
      "isReport": "false"
    };
    var result = await _attendanceRepository.getAttendanceList(
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
        final List<AttendanceModel> newData = List<AttendanceModel>.from(
          response['data'] ?? [],
        );

        emit(state.copyWith(attendanceList: newData, isLoading: false));
      },
    );
  }

  // TAB CHANGE METHOD
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  Future<void> addAttendanceRegularization({
    required BuildContext context,
    required String attendanceDate,
    required String punchIn,
    required String punchOut,
    required String reason,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "AttendanceRegularizationId": 0.toString(),
      "AttendanceDate": attendanceDate,
      "PunchIn": punchIn,
      "PunchOut": punchOut,
      "Reason": reason,
    };
    var addResult = await _attendanceRepository
        .addUpdateAttendanceRegularization(queryParams: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
        goRouter.pop();
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(
          context,
          subTitle: "Attendance Regularize successfully",
        );
      },
    );
  }
}
