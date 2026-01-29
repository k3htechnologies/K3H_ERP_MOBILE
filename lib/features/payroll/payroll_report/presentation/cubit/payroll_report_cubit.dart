import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/repository/attendance.repository.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/repository/outdoor.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'payroll_report_state.dart';

class PayrollReportCubit extends Cubit<PayrollReportState> {
  PayrollReportCubit() : super(PayrollReportState.initial());

  // REPOSITORIES
  final AttendanceRepository _attendanceRepository =
  serviceLocator<AttendanceRepository>();

  final OutdoorRepository _outdoorRepository =
  serviceLocator<OutdoorRepository>();

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
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

}
