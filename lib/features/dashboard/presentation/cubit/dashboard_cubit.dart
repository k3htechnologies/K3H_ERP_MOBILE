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
    String formatDate(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
    if (endDate.isBefore(startDate)) {
      endDate = startDate;
    }
    Map<String, dynamic> queryParams = {
      "StartDate": formatDate(startDate),
      "EndDate": formatDate(endDate),
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
    required String punchAddress,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "AttendanceId": 0,
      "PunchAddress": punchAddress,
    };

    var addResult = await _dashboardRepository.addAttendace(
      requestBody: requestBody,
    );

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
        showSuccessMessage(context, subTitle: "Punched Out Successfully");
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
        final UserDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            userData: model,
            userDashboardModelList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }
}
