import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      "BranchName": state.filterBranchName,
      "DepartmentName": state.filterDepartmentName,
    };

    if (state.filterFromHolidayDate != null) {
      queryParams["FromHolidayDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterFromHolidayDate!);
    }

    if (state.filterToHolidayDate != null) {
      queryParams["ToHolidayDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterToHolidayDate!);
    }
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
    required String departmentIds,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "HolidayMappingMasterId": "0",
      "HolidayMasterId": holidayMasterId,
      "BranchMasterId": branchMasterId,
      "HolidayDate": holidayDate.toIso8601String(),
      "DepartmentMasterId": departmentIds,
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
    required String departmentIds,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "HolidayMappingMasterId": holidayMappingMasterId,
      "UniqueKey": uniqueKey,
      "HolidayMasterId": holidayMasterId,
      "BranchMasterId": branchMasterId,
      "HolidayDate": holidayDate.toIso8601String(),
      "DepartmentMasterId": departmentIds,
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
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
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
    var result = await holidayMappingMasterRepository.exportHolidayMappings(
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "holidays_mapping_${DateTime.now()}.pdf"
              : "holidays_mapping_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    required String filterHolidayName,
    required String filterBranchName,
    required String filterDepartmentName,
    required DateTime? filterFromHolidayDate,
    required DateTime? filterToHolidayDate,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        searchText: filterHolidayName,
        filterBranchName: filterBranchName,
        filterDepartmentName: filterDepartmentName,
        filterFromHolidayDate: filterFromHolidayDate,
        filterToHolidayDate: filterToHolidayDate,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        holidayMappingList: [],
        currentPage: 1,
      ),
    );

    await getHolidayMappingList(context: context, pageNumber: 1);
  }

  int updateHolidayMappingFilterCount(HolidayMappingMasterState state) {
    final hasSort =
        state.currentSortColumn == "Holiday Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");

    final hasDateFilter =
        state.filterFromHolidayDate != null &&
        state.filterToHolidayDate != null;

    final isValidDateRange =
        hasDateFilter &&
        !state.filterFromHolidayDate!.isAfter(
          DateTime(
            state.filterToHolidayDate!.year,
            state.filterToHolidayDate!.month,
            state.filterToHolidayDate!.day,
          ),
        );

    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterBranchName.trim().isNotEmpty,
      state.filterDepartmentName.trim().isNotEmpty,
      hasSort,
      isValidDateRange,
    ]);
  }
}
