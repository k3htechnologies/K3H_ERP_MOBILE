import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/data/model/user_dashboard.model.dart';
import 'package:k3h_erp_app/features/dashboard/data/repository/dashboard.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState.initial());

  // REPOSITORY
  final DashboardRepository _dashboardRepository =
      serviceLocator<DashboardRepository>();

  // PROJECT MASTER REPO
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  //  ON TAB CHANGE METHOD
  
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

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
        final List<AttendanceModel> newData = List<AttendanceModel>.from(
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

  // ADD ATTENDANCE
  Future addAttendance(
    BuildContext context, {
    required int attendanceId,
    required String punchAddress,
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    required String polyline,
    required double distance,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "AttendanceId": attendanceId,
      "PunchAddress": punchAddress,
      "StartLatitude": startLatitude,
      "StartLongitude": startLongitude,
      "EndLatitude": endLatitude,
      "EndLongitude": endLongitude,
      "Polyline": polyline,
      "Distance": distance,
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
        final newItem = response['data'][0] as AttendanceModel;

        emit(state.copyWith(data: newItem));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // UPDATE ATTENDANCE
  Future updateAttendance(
    BuildContext context, {
    required int attendanceId,
    required String uniquekey,
    required String punchAddress,
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    required String polyline,
    required double distance,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "AttendanceId": attendanceId,
      "Uniquekey": uniquekey,
      "PunchAddress": punchAddress,
      "StartLatitude": startLatitude,
      "StartLongitude": startLongitude,
      "EndLatitude": endLatitude,
      "EndLongitude": endLongitude,
      "Polyline": polyline,
      "Distance": distance,
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
        final newItem = response['data'][0] as AttendanceModel;

        emit(state.copyWith(data: newItem));
        showSuccessMessage(context, subTitle: response['message']);
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

  Future getProjectEmployeesList(
    BuildContext context,
    int projectId, {
    String? searchText,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _projectMasterRepository.getProjectWithEmployee(
      projectId: projectId,
      queryParams: {"FullName": searchText ?? ""},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final employees =
            (response['data'] as List? ?? [])
                .map((e) => UserModel.fromJson(e))
                .toList();
        emit(state.copyWith(employeeByProject: employees, isLoading: false));
      },
    );
  }
}
