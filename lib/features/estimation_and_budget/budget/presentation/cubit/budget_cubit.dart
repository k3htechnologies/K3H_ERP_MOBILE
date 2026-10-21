import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/inventory_project_basement_podium_wing_budget.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/repository/budget.repository.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit() : super(BudgetState.initial());
  // REPOSITORIES
  final BudgetRepository _budgetRepository = serviceLocator<BudgetRepository>();
  // SEARCH BUDGET
  Future searchBudget(
    BuildContext context,
    String value,
    int projectId,
    int inventoryFlatFloorBasementPodiumWingId,
  ) async {
    emit(state.copyWith(searchText: value, budgetList: []));
    await getBudgetList(
      context,
      1,
      projectId: projectId,
      inventoryFlatFloorBasementPodiumWingId:
          inventoryFlatFloorBasementPodiumWingId,
    );
  }

  // GET BUDGET LIST
  Future getBudgetList(
    BuildContext context,
    int pageNumber, {
    required int projectId,
    required int inventoryFlatFloorBasementPodiumWingId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "CategoryName": state.searchText,
      "ProjectId": projectId,
      "LevelType": state.filterByLevelType,
      "Uom": state.filterByUom,
      "Flat": state.filterByFlatType,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
    };
    var result = await _budgetRepository.pullBudget(
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
        final List<BudgetModel> newData = List<BudgetModel>.from(
          response['data'] ?? [],
        );
        final List<BudgetModel> updatedList =
            pageNumber == 1 ? newData : [...state.budgetList, ...newData];

        final keepExistingOriginalBudgetList =
            (state.searchText.isNotEmpty ||
                state.filterByUom.isNotEmpty ||
                state.filterByLevelType.isNotEmpty ||
                state.filterByFlatType.isNotEmpty);
        emit(
          state.copyWith(
            isLoading: false,
            budgetList: updatedList,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            originalBudgetList:
                keepExistingOriginalBudgetList
                    ? state.originalBudgetList
                    : updatedList,
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> applyBudgetFilter({
    required BuildContext context,
    required int projectId,
    required int inventoryFlatFloorBasementPodiumWingId,
    String? categoryName,
    String? uom,
    String? levelType,
    String? flatType,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByCategoryName: "",
          filterByUom: "",
          filterByLevelType: "",
          filterByFlatType: "",
          budgetList: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: categoryName ?? state.searchText,
          filterByUom: uom ?? state.filterByUom,
          filterByLevelType: levelType ?? state.filterByLevelType,
          filterByFlatType: flatType ?? state.filterByFlatType,
          budgetList: [],
        ),
      );
    }
    await getBudgetList(
      context,
      1,
      projectId: projectId,
      inventoryFlatFloorBasementPodiumWingId:
          inventoryFlatFloorBasementPodiumWingId,
    );
  }

  Future exportExcelPdf(
    BuildContext context,
    String exportType, {
    required int projectId,
  }) async {
    if (projectId == 0) {
      showErrorMessage(context, "Error", "Please Select a Project");
      return;
    }
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, 'Error', 'No Data Found');
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _budgetRepository.pullBudgetForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {
        "ExportType": exportType,
        "IsCheckPermission": true,
        "ProjectId": projectId,
      },
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
              ? "Budget ${DateTime.now()}.pdf"
              : "Budget ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(BudgetState state) {
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByFlatType.trim().isNotEmpty,
      state.filterByLevelType.trim().isNotEmpty,
      state.filterByUom.trim().isNotEmpty,
    ]);
  }

  Future<Map<String, dynamic>> fetchInventoryProjectBasementPodiumWingBudget(
    int pageNumber, {
    String? value,
    required int projectId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required bool isDisplayProjectBudget,
  }) async {
    final result = await _budgetRepository
        .pullInventoryProjectBasementPodiumWingBudget(
          queryParams: {
            "ProjectId": projectId,
            "InventoryFlatFloorBasementPodiumWingId":
                inventoryFlatFloorBasementPodiumWingId,
            "IsDisplayProjectBudget": isDisplayProjectBudget,
          },
        );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project =
            response['data']
                as List<InventoryProjectBasementPodiumWingBudgetModel>;
        return {
          "itemList":
              project.map((b) {
                return {
                  "zAttributesId": b.inventoryFlatFloorBasementPodiumWingId,
                  "DisplayName": b.projectBuildingNumberWing,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }
}
