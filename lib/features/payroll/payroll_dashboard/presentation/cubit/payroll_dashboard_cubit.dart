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


  // <---- GET PAYROLL DASHBOARD LIST ---->
  Future<void> getPayrollDashboardList(BuildContext context) async {
    emit(state.copyWith(isLoading: true));

    final result = await _payrollDashboardRepository.getPayrollDashboardList();

    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
          (response) {
        final PayrollDashboardModel model = response['data'];

        emit(
          state.copyWith(
            isLoading: false,
            payrollDashboardModel: model,
          ),
        );
      },
    );
  }

}
