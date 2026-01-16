import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryState.initial());

  // REPOSITORY
  final InventoryRepository _inventoryRepository =
      serviceLocator<InventoryRepository>();

  bool _isApiCallInProgress = false;

  // GET ENTIRE INVENTORY
  Future getInventory(BuildContext context, int projectId) async {
    // Only prevent if API is already in progress OR if we already have data and are loading
    if (_isApiCallInProgress) {
      return;
    }
    
    // If we have data and are loading, don't call again
    if (state.isLoading == true && state.buildingList.isNotEmpty) {
      return;
    }

    _isApiCallInProgress = true;
    // Reset currentTabIndex and clear building list when project changes
    emit(state.copyWith(
      isLoading: true,
      buildingList: [],
      currentTabIndex: 0,
    ));
    final result = await _inventoryRepository.getInventory(
      projectId: projectId,
    );
    _isApiCallInProgress = false;
    
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (result) {
        emit(
          state.copyWith(
            isLoading: false,
            buildingList: result["data"] as List<BuildingModel>,
            currentTabIndex: 0,
          ),
        );
      },
    );
  }

  // ADD INVENTORY FLAT
  Future addInventoryFlat(
    BuildContext context, {
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required String flat,
    required String flatType,
    required double flatArea,
    required String flatConfiguration,
    required String flatStatus,
    required String flatFacing,
    required List<FlatSpecificationModel> flatSpecificationList,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "InventoryBuildingId": inventoryBuildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "InventoryFloorId": inventoryFloorId,
      "Flat": flat,
      "FlatType": flatType,
      "RERACarpetAreaSqFt": flatArea,
      "FlatConfiguration": flatConfiguration,
      "FlatStatus": flatStatus,
      "FlatFacing": flatFacing,
      "InventoryFlatSpecificationJSON": getEncodedFlatSpecificationList(
        flatSpecificationList,
      ),
    };
    var addResult = await _inventoryRepository.addInventoryFlat(
      requestBody: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Unit Added Successfully");
      },
    );
  }

  String getEncodedFlatSpecificationList(List<FlatSpecificationModel> data) {
    final result =
        data
            .map(
              (item) => {
                "InventoryFlatSpecificationId":
                    item.inventoryFlatSpecificationId,
                "Uniquekey": item.uniquekey,
                "FlatLayout": item.flatLayout,
                "FlatLayoutAreaSqFt": item.flatLayoutAreaSqFt,
                "FlatLayoutLengthSqFt": item.flatLayoutLengthSqFt,
                "FlatLayoutWidthSqFt": item.flatLayoutWidthSqFt,
                "Note": item.note,
              },
            )
            .toList();

    return jsonEncode(result);
  }

  // UPDATE INVENTORY FLAT
  Future updateInventoryFlat(
    BuildContext context, {
    required int inventoryFlatId,
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required String flat,
    required String flatType,
    required double flatArea,
    required String flatConfiguration,
    required String flatStatus,
    required String flatFacing,
    required List<FlatSpecificationModel> flatSpecificationList,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "InventoryBuildingId": inventoryBuildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "InventoryFloorId": inventoryFloorId,
      "Flat": flat,
      "FlatType": flatType,
      "RERACarpetAreaSqFt": flatArea,
      "FlatConfiguration": flatConfiguration,
      "FlatStatus": flatStatus,
      "InventoryFlatId": inventoryFlatId,
      "FlatFacing": flatFacing,
      "InventoryFlatSpecificationJSON": getEncodedFlatSpecificationList(
        flatSpecificationList,
      ),
    };
    var addResult = await _inventoryRepository.updateInventoryFlat(
      requestBody: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) async {
        // Refresh inventory before navigating back
        await getInventory(context, projectId);
        if (context.mounted) {
          goRouter.pop();
          showSuccessMessage(context, subTitle: "Unit Updated Successfully");
        }
      },
    );
  }

  // EXPORT DATA
  Future exportInventory(
    BuildContext context,
    int projectId,
    String exportType,
  ) async {
    var result = await _inventoryRepository.exportInventory(
      projectId: projectId,
      queryParams: {"ExportType": exportType},
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Failed", failure.message);
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "inventory_${DateTime.now()}.pdf"
              : "inventory${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }
}
