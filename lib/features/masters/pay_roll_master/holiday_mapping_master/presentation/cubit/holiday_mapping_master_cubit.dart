import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/repository/holiday_mapping_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

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
    getHolidayMappingList(context: context, pageNumber: 1);
  }

  Future getHolidayMappingList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "HolidayName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await holidayMappingMasterRepository.getMappedHolidayList(
      pageNumber: pageNumber,
      pageSize: 10,
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

  Future addHolidayMapping({
    required BuildContext context,
    required int holidayMasterId,
    required String branchMasterId,
    required DateTime holidayDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "HolidayMappingMasterId": "0",
      "HolidayMasterId": holidayMasterId,
      "BranchMasterId": branchMasterId,
      "HolidayDate": holidayDate.toIso8601String(),
    };

    var result = await holidayMappingMasterRepository.addUpdateMappedHoliday(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = response['data'][0] as HolidayMappingModel;

        var list = [newResponse, ...state.holidayMappingList];
        emit(
          state.copyWith(
            holidayMappingList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: 'Holiday Mapping Added Successfully',
        );
      },
    );
  }

  Future updateHolidayMapping({
    required int index,
    required BuildContext context,
    required int holidayMappingMasterId,
    required String uniqueKey,
    required int holidayMasterId,
    required String branchMasterId,
    required DateTime holidayDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "HolidayMappingMasterId": holidayMappingMasterId,
      "UniqueKey": uniqueKey,
      "HolidayMasterId": holidayMasterId,
      "BranchMasterId": branchMasterId,
      "HolidayDate": holidayDate.toIso8601String(),
    };
    var result = await holidayMappingMasterRepository.addUpdateMappedHoliday(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as HolidayMappingModel;

        if (state.holidayMappingList.isNotEmpty &&
            index < state.holidayMappingList.length) {
          final updatedListModel = List<HolidayMappingModel>.from(
            state.holidayMappingList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(holidayMappingList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Holiday Mapping Updated Successfully",
        );
      },
    );
  }

  Future deleteHolidayMapping(
    int index,
    HolidayMappingModel holidayMapping,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await holidayMappingMasterRepository.deleteMappedHoliday(
      holidayMappingMasterId: holidayMapping.holidayMappingMasterId,
      uniqueKey: holidayMapping.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<HolidayMappingModel>.from(
          state.holidayMappingList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            holidayMappingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: success["totalNumberOfRecord"],
          ),
        );

        showSuccessMessage(
          context,
          subTitle: "Holiday Mapping Deleted Successfully",
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await holidayMappingMasterRepository.getMappedHolidayList(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {"ExportType": exportType, "HolidayName": state.searchText},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "asset_mapping_${DateTime.now()}.pdf"
              : "asset_mapping_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
