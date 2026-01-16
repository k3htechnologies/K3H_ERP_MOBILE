import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/repository/holiday_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'holiday_master_state.dart';

class HolidayMasterCubit extends Cubit<HolidayMasterState> {
  HolidayMasterCubit() : super(HolidayMasterState.initial());

  final HolidayMasterRepository holidayMasterRepository =
      serviceLocator<HolidayMasterRepository>();

  void resetState() {
    emit(HolidayMasterState.initial());
  }

  void searchHolidays(String value, BuildContext context) {
    emit(
      state.copyWith(
        holidays: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getHolidayList(context: context, pageNumber: 1);
  }

  Future getHolidayList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "HolidayName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await holidayMasterRepository.getHolidayList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<HolidayMasterModel> newData = List<HolidayMasterModel>.from(
          response['data'] ?? [],
        );

        final List<HolidayMasterModel> updatedList = [
          ...state.holidays,
          ...newData,
        ];

        emit(
          state.copyWith(
            holidays: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addHoliday({
    required BuildContext context,
    required String holidayName,
    required MultiFilePickerModel holidayFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {"HolidayMasterId": "0", "HolidayName": holidayName};
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < holidayFile.fileNameList.length; i++) {
      if (holidayFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "HolidayURL",
        "value": holidayFile.fileBytesList[i],
        "fileName": holidayFile.fileNameList[i],
      });
    }
    var result = await holidayMasterRepository.addUpdateHoliday(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = HolidayMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.holidays];
        emit(
          state.copyWith(
            holidays: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(context, subTitle: 'Holiday Added Successfully');
      },
    );
  }

  Future updateAssetMapping({
    required int index,
    required BuildContext context,
    required String holidayMasterId,
    required String holidayName,
    required String uniqueKey,
    required MultiFilePickerModel holidayFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "HolidayMasterId": holidayMasterId,
      "UniqueKey": uniqueKey,
      "HolidayName": holidayName,
      "RemoveHolidayURL": holidayFile.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < holidayFile.fileNameList.length; i++) {
      if (holidayFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "HolidayURL",
        "value": holidayFile.fileBytesList[i],
        "fileName": holidayFile.fileNameList[i],
      });
    }
    var result = await holidayMasterRepository.addUpdateHoliday(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = HolidayMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.holidays.isNotEmpty && index < state.holidays.length) {
          final updatedListModel = List<HolidayMasterModel>.from(
            state.holidays,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(holidays: updatedListModel));
        }

        showSuccessMessage(context, subTitle: "Holiday Updated Successfully");
      },
    );
  }

  Future deleteHoliday(
    int index,
    HolidayMasterModel assetMapping,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await holidayMasterRepository.deleteHoliday(
      holidayMasterId: assetMapping.holidayMasterId,
      uniqueKey: assetMapping.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<HolidayMasterModel>.from(state.holidays);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            holidays: updatedList,
            isLoading: false,
            totalNumberOfRecord: success["totalNumberOfRecord"],
          ),
        );
        showSuccessMessage(context, subTitle: "Holiday Deleted Successfully");
      },
    );
  }
}
