import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/data/model/setting_dashboard.model.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/data/repository/setting_dashbaord.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'setting_dashboard_state.dart';

class SettingDashboardCubit extends Cubit<SettingDashboardState> {
  SettingDashboardCubit() : super(SettingDashboardState.initial());

  // REPOSITORY
  final SettingDashbaordRepository _settingDashbaordRepository =
      serviceLocator<SettingDashbaordRepository>();

  // GET Dashboard LIST
  Future getSettingDashboardList(BuildContext context) async {
    emit(state.copyWith(isLoading: true));

    var result = await _settingDashbaordRepository.getSettingDashboardList();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final SettingDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            settingDashboardModel: model,
            settingDashboardList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }
}
