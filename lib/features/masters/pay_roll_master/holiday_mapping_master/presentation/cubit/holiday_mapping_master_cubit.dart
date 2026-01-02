import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/repository/holiday_mapping_master.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'holiday_mapping_master_state.dart';

class HolidayMappingMasterCubit extends Cubit<HolidayMappingMasterState> {
  HolidayMappingMasterCubit() : super(HolidayMappingMasterState.initial());

  final HolidayMappingMasterRepository holidayMappingMasterRepository =
      serviceLocator<HolidayMappingMasterRepository>();

  void resetState() {
    emit(HolidayMappingMasterState.initial());
  }

  void searchHolidayMapping(String value, BuildContext context) {
    emit(
      state.copyWith(
        holidayMappingList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getHolidayMappingList(context: context, pageNumber: 1, pageSize: 15);
  }

  Future getHolidayMappingList({
    required BuildContext context,
    required int pageNumber,
    required int pageSize,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "HolidayName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await holidayMappingMasterRepository.getMappedHolidayList(
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
        final List<HolidayMappingModel> newData =
            List<HolidayMappingModel>.from(response['data'] ?? []);

        final List<HolidayMappingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.holidayMappingList, ...newData];

        emit(
          state.copyWith(
            holidayMappingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }
}
