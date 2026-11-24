import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/village.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/model/dar_allocation.model.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/repository/dar_allocation_repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'dar_allocation_state.dart';

class DarAllocationCubit extends Cubit<DarAllocationState> {
  DarAllocationCubit() : super(DarAllocationState.initial());

  final DarAllocationRepository _darAllocationRepository =
      serviceLocator<DarAllocationRepository>();

  final UtilsRepository _utilsRepository = serviceLocator<UtilsRepository>();

  Future searchDarAllocation(BuildContext context, String value) async {
    emit(
      state.copyWith(searchText: value, darAllocationList: [], currentPage: 1),
    );
    await getDarAllocationList(context, 1);
  }

  Future applyDarAllocationFilterAndSort({
    required BuildContext context,
    String? employeeName,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByEmployeeName: "",
          currentSortColumn: "Created Date",
          currentSortDirection: "DESC",
          darAllocationList: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: employeeName ?? state.searchText,

          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          darAllocationList: [],
        ),
      );
    }
    await getDarAllocationList(context, 1);
  }

  int updateDarAllocationFilterCount(DarAllocationState state) {
    final hasSort =
        state.currentSortColumn == "Employee Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByEmployeeName.trim().isNotEmpty,
      hasSort,
    ]);
  }

  // GET DAR ALLOCATION LIST
  Future getDarAllocationList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    var result = await _darAllocationRepository.getDarAllocationList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "EmployeeName": state.searchText,
        "IsCheckPermission": true,
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<DarAllocationModel> newData = List<DarAllocationModel>.from(
          response['data'] ?? [],
        );

        final List<DarAllocationModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.darAllocationList, ...newData];
        emit(
          state.copyWith(
            darAllocationList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future deleteDarAllocation(
    DarAllocationModel darAllocationModel,
    BuildContext context,
    int index,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    final result = await _darAllocationRepository.deleteDarAllocation(
      darAllocationId: darAllocationModel.darAllocationId,
      uniqueKey: darAllocationModel.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedList = List<DarAllocationModel>.from(
          state.darAllocationList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            darAllocationList: updatedList,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // FETCH VILLAGES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchVillages(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _utilsRepository.getVillageList(
      pageNumber: pageNumber,
      pageSize: 250,
      queryParams:
          value != null && value.isNotEmpty ? {"VillageName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final villages = response['data'] as List<VillageModel>;
        log(
          "the list of village is: ${villages.map((village) {
            return {"zAttributesId": village.villageMasterId.toString(), "DisplayName": village.villageName};
          }).toList()}",
        );
        return {
          "itemList":
              villages.map((village) {
                return {
                  "zAttributesId": village.villageMasterId.toString(),
                  "DisplayName": village.villageName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future<void> updateDarAllocation(
    BuildContext context, {
    required int darAllocationId,
    required String uniquekey,
    required int employeeId,
    required String villageMasterId,
    required int index,
  }) async {
    emit(state.copyWith(isLoading: true));

    final body = {
      "DarAllocationId": darAllocationId,
      "Uniquekey": uniquekey,
      "EmployeeId": employeeId,
      "VillageMasterId": villageMasterId,
    };

    final result = await _darAllocationRepository.addUpdateDarAllocation(
      body: body,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        goRouter.pop();
        final updatedDepartment = response['data'][0] as DarAllocationModel;

        if (state.darAllocationList.isNotEmpty &&
            index < state.darAllocationList.length) {
          final updatedList = List<DarAllocationModel>.from(
            state.darAllocationList,
          );
          updatedList[index] = updatedDepartment;
          emit(
            state.copyWith(darAllocationList: updatedList, isLoading: false),
          );
        }

        showSuccessMessage(context, subTitle: response["message"]);
      },
    );
  }

  Future<void> addDarAllocation(
    BuildContext context, {
    required int employeeId,
    required String villageMasterId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final body = {"EmployeeId": employeeId, "VillageMasterId": villageMasterId};

    final result = await _darAllocationRepository.addUpdateDarAllocation(
      body: body,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        emit(state.copyWith(isLoading: false));

        showSuccessMessage(context, subTitle: response["message"]);
        goRouter.pop();
        await getDarAllocationList(context, 1);
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _darAllocationRepository.exportDarAllocation(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"ApplicantName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Dar Allocation ${DateTime.now()}.pdf"
              : "Dar Allocation ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
