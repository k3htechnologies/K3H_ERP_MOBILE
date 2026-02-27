import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/data/model/redevelopment_dashboard.model.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/data/repository/redevelopment.dashboard_repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'redevlopment_dashboard_state.dart';

class RedevlopmentDashboardCubit extends Cubit<RedevlopmentDashboardState> {
  RedevlopmentDashboardCubit() : super(RedevlopmentDashboardState.initial());

  // REPOSITORY
  final RedevelopmentDashboardRepository _redevelopmentDashboardRepository =
      serviceLocator<RedevelopmentDashboardRepository>();

  // <---- GET Dashboard LIST ---->
  Future getRedevelopmentDashboardList(
    BuildContext context,
    int projectId, {
    int? buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _redevelopmentDashboardRepository
        .getRedevelopmentDashboardList(projectId: projectId);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final RedevelopmentDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            redevelopmentDashboardModel: model,
            redevelopmentDashboardModelList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }
}
