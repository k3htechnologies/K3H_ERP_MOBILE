import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/legal/dashboard/data/model/litigation_dashboard.model.dart';
import 'package:k3h_erp_app/features/legal/dashboard/data/repository/litigation_dashboard.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'litigation_dashboard_state.dart';

class LitigationDashboardCubit extends Cubit<LitigationDashboardState> {
  LitigationDashboardCubit()
    : super(
        LitigationDashboardState.initial(
          selectedRangeIndex: _getCurrentRangeIndex(),
        ),
      );
  static int _getCurrentRangeIndex() {
    final currentMonth = DateTime.now().month;

    if (currentMonth >= 1 && currentMonth <= 4) {
      return 0;
    } else if (currentMonth >= 5 && currentMonth <= 8) {
      return 1;
    } else {
      return 2;
    }
  }

  // REPOSITORY
  final LitigationDashboardRepository _litigationDashboardRepository =
      serviceLocator<LitigationDashboardRepository>();

  void updateRange(int index) {
    emit(state.copyWith(selectedRangeIndex: index));
  }

  // GET Dashboard LIST
  Future getLitigationDashboardList(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true));

    var result = await _litigationDashboardRepository
        .getLitigationDashboardList(projectId: projectId);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final LitigationDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            litigationDashboardModel: model,
            litigationDashboardModelList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }
}
