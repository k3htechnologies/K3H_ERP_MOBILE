import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/user_dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/data/repository/dashboard.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState.initial());

  // REPOSITORY
  final DashboardRepository _dashboardRepository =
      serviceLocator<DashboardRepository>();

  // <---- GET ATTENDANCE LIST ---->
  Future getAttendanceList(
    BuildContext context,
    int pageNumber,
    DateTime startDate,
    DateTime endDate,
    int attendanceId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "StartDate": startDate.toIso8601String(),
      "EndDate": endDate.toIso8601String(),
      "AttendanceId": attendanceId,
    };
    var result = await _dashboardRepository.getAttendanceList(
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
        final List<DashboardModel> newData = List<DashboardModel>.from(
          response['data'] ?? [],
        );

        emit(
          state.copyWith(
            dashboardModelList: newData,
            data: newData.isNotEmpty ? newData.first : null,
            isLoading: false,
          ),
        );
      },
    );
  }

  // ADD ATTENDACE
  Future addAttendance(
    BuildContext context, {
    required int attendanceId,
    required String uniquekey,
    required String punchAddress,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "AttendanceId": attendanceId,
      "Uniquekey": uniquekey,
      "PunchAddress": punchAddress,
    };

    var addResult = await _dashboardRepository.addAttendace(
      requestBody: requestBody,
    );

    // close loader
    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: "Punched In Successfully");
      },
    );
  }

  // UPDATE ATTENDANCE
  Future updateAttendance(
    BuildContext context, {
    required int attendanceId,
    required String uniquekey,
    required String punchAddress,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "AttendanceId": attendanceId,
      "Uniquekey": uniquekey,
      "PunchAddress": punchAddress,
    };
    var addResult = await _dashboardRepository.addAttendace(
      requestBody: requestBody,
    );

    // close loader
    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: "Punched In Successfully");
      },
    );
  }

  // <---- GET Dashboard LIST ---->
  Future getDashboardList(BuildContext context) async {
    emit(state.copyWith(isLoading: true));
    var result = await _dashboardRepository.getDashboardList();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<UserDashboardModel> newData = List<UserDashboardModel>.from(
          response['data'] ?? [],
        );

        emit(
          state.copyWith(
            userDashboardModelList: newData,
            userData: newData.isNotEmpty ? newData.first : null,
            isLoading: false,
          ),
        );
      },
    );
  }
}
