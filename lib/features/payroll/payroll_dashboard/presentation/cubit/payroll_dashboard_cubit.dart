import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/model/payroll_dashboard_model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/respository/payroll_dashboard_repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'payroll_dashboard_state.dart';

class PayrollDashboardCubit extends Cubit<PayrollDashboardState> {
  PayrollDashboardCubit() : super(PayrollDashboardState.initial());

  // REPOSITORY
  final PayrollDashboardRepository _payrollDashboardRepository =
      serviceLocator<PayrollDashboardRepository>();

  // GET PAYROLL DASHBOARD LIST
  Future<void> getPayrollDashboardList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    DateTime startDate,
    DateTime endDate,
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
    };
    final result = await _payrollDashboardRepository.getPayrollDashboardList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final PayrollDashboardModel model = response['data'];

        emit(state.copyWith(isLoading: false, payrollDashboardModel: model));
      },
    );
  }
}
