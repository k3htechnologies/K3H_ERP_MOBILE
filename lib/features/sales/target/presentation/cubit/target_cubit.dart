import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/target.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/repository/target.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'target_state.dart';

class TargetCubit extends Cubit<TargetState> {
  TargetCubit() : super(TargetState.initial());

  final TargetRepository _salesTargetRepository =
      serviceLocator<TargetRepository>();

  // <---- SEARCH SALES TARGET ---->
  Future<void> searchSalesTarget(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, salesTargets: []));
    await getSalesTargetList(
      context: context,
      projectId: projectId,
      pageNumber: 1,
    );
  }

  // <---- GET TARGET LIST ---->
  Future getSalesTargetList({
    required BuildContext context,
    required int projectId,
    int pageNumber = 1,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> searchQueryParams = {
      "EmployeeName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      ...?queryParams,
    };
    var result = await _salesTargetRepository.getSalesTargets(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      targetMonth: state.currentTargetMonth,
      queryParams: searchQueryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<TargetModel> newData = List<TargetModel>.from(
          response['data'] ?? [],
        );

        final List<TargetModel> updatedList =
            pageNumber == 1 ? newData : [...state.salesTargets, ...newData];
        emit(
          state.copyWith(
            salesTargets: updatedList,
            isLoading: false,
            totalNumberOfRecords: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }
}
