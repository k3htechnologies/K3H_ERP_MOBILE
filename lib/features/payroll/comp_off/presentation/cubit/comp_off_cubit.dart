import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/repository/comp_off.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'comp_off_state.dart';

class CompOffCubit extends Cubit<CompOffState> {
  CompOffCubit() : super(CompOffState.initial());

  // REPOSITORIES
  final CompOffRepository _compOffRepository =
      serviceLocator<CompOffRepository>();

  // <---- GET COMP OFF LIST ---->
  Future getCompOffList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    var result = await _compOffRepository.getCompOffList(
      pageNumber: pageNumber,
      pageSize: 10,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CompOffModel> newData = List<CompOffModel>.from(
          response['data'] ?? [],
        );

        final List<CompOffModel> updatedList =
            pageNumber == 1 ? newData : [...state.compOffList, ...newData];
        emit(
          state.copyWith(
            compOffList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }
}
