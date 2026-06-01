import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/dashboard/data/model/crm_dashboard.model.dart';
import 'package:k3h_erp_app/features/crm/dashboard/data/repository/crm_dashboard.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'crm_dashboard_state.dart';

class CrmDashboardCubit extends Cubit<CrmDashboardState> {
  CrmDashboardCubit() : super(CrmDashboardState.initial());

  final CrmDashboardRepository _crmDashboardRepository =
      serviceLocator<CrmDashboardRepository>();

  Future getCrmDashboardList(
    BuildContext context, {
    required String filterType,
    required int projectId,
    String? fromDate,
    String? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _crmDashboardRepository.getDashboardList(
      filterType: filterType,
      projectId: projectId,
      fromDate: fromDate,
      toDate: toDate,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final CrmDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            crmDashboardModel: model,
            crmDashboardList: model != null ? [model] : [],
            isLoading: false,
            selectedFilterType: filterType,
          ),
        );
      },
    );
  }
}
