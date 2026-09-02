import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/model/tax_tracker.model.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/repository/tax_tracker.repository.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'tax_tracker_state.dart';

class TaxTrackerCubit extends Cubit<TaxTrackerState> {
  TaxTrackerCubit() : super(TaxTrackerState.initial());
  // REPOSITORY
  final TaxTrackerRepository _taxTrackerRepository =
      serviceLocator<TaxTrackerRepository>();

  Future getTrackTrackerList(BuildContext context, int pageNumber) async {
    emit(state.copywith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "GovernmentCompliance": "${state.searchText} ${state.searchText}",
    };

    var result = await _taxTrackerRepository.getTaxTrackerList(
      pageSize: 10,
      pageNumber: pageNumber,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copywith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<TaxTrackerModel> newList =
            response['data'] as List<TaxTrackerModel>;

        final updatedList =
            pageNumber == 1 ? newList : [...state.taxTrackerList, ...newList];

        emit(
          state.copywith(
            taxTrackerList: updatedList,
            taxTrackerOverview: newList.isNotEmpty ? newList.first : null,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }
}
