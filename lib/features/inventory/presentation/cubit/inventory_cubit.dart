import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/model/inventory_dashboard.model.dart';
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

  void searchInventory(String value) {
    final query = value.toLowerCase();

    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchText: value,
          buildingList: state.originalBuildingList,
        ),
      );
      return;
    }

    final filteredBuildings =
        state.originalBuildingList
            .map((building) {
              final filteredWings =
                  building.wingList
                      .map((wing) {
                        final filteredFloors =
                            wing.floorList
                                .map((floor) {
                                  final filteredFlats =
                                      floor.flatList.where((flat) {
                                        return flat.flat.toLowerCase().contains(
                                          query,
                                        );
                                      }).toList();

                                  return floor.copyWith(
                                    flatList: filteredFlats,
                                  );
                                })
                                .where((floor) => floor.flatList.isNotEmpty)
                                .toList();

                        return wing.copyWith(floorList: filteredFloors);
                      })
                      .where((wing) => wing.floorList.isNotEmpty)
                      .toList();

              return building.copyWith(wingList: filteredWings);
            })
            .where((building) => building.wingList.isNotEmpty)
            .toList();

    emit(
      state.copyWith(
        searchText: value,
        buildingList: filteredBuildings,
        currentTabIndex: 0,
        wingCurrentPage: 0,
      ),
    );
  }

  void reset() {
    emit(state.copyWith(isLoading: false));
  }

  // GET ENTIRE INVENTORY
  Future<void> getInventory(BuildContext context, int projectId) async {
    if (_isApiCallInProgress) return;

    _isApiCallInProgress = true;

    emit(state.copyWith(isLoading: true));
    final result = await _inventoryRepository.getInventory(
      projectId: projectId,
    );

    _isApiCallInProgress = false;

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<BuildingModel> buildings =
            response["data"] as List<BuildingModel>;

        if (buildings.isNotEmpty) {
          final Map<String, Map<String, int>> wingCounts = {};

          for (var building in buildings) {
            for (var wing in building.wingList) {
              final wingKey =
                  "${building.inventoryBuildingId}_${wing.inventoryFlatFloorBasementPodiumWingId}";

              wingCounts[wingKey] = calculateWingCounts(wing);
            }
          }
          int buildingIndex =
              state.currentTabIndex < buildings.length
                  ? state.currentTabIndex
                  : 0;

          final selectedBuilding = buildings[buildingIndex];
          final wingList = selectedBuilding.wingList;

          String? wingKey =
              state.wingCurrentPageKey != null &&
                      wingList.any((w) => w.wing == state.wingCurrentPageKey)
                  ? state.wingCurrentPageKey
                  : wingList.isNotEmpty
                  ? wingList.first.wing
                  : null;

          int wingIndex =
              wingKey != null
                  ? wingList.indexWhere((w) => w.wing == wingKey)
                  : 0;

          emit(
            state.copyWith(
              isLoading: false,
              buildingList: buildings,
              currentTabIndex: buildingIndex,
              wingCurrentPage: wingIndex,
              wingCounts: wingCounts,
              wingCurrentPageKey: wingKey,
              originalBuildingList: buildings,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              buildingList: [],
              originalBuildingList: [],
            ),
          );
        }
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

  // DELETE INVENTORY FLAT
  Future deleteInventoryFlat(
    BuildContext context,
    int floorIndex,
    int wingIndex,
    int buildingIndex,
    int flatIndex, {
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required int inventoryFlat,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _inventoryRepository.deleteInventoryFlat(
      projectId: projectId,
      inventoryFloorId: inventoryFloorId,
      inventoryBuildingId: inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          inventoryFlatFloorBasementPodiumWingId,
      inventoryFlatId: inventoryFlat,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: "Unit Deleted Successfully");
        await getInventory(context, projectId);
      },
    );
  }

  Future<void> addFloor(
    BuildContext context, {
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
  }) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    final payload = {
      "ProjectId": projectId,
      "InventoryBuildingId": inventoryBuildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
    };

    final result = await _inventoryRepository.addFloor(requestBody: payload);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: "Floor Added Successfully");
        getInventory(context, projectId);
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
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

  void updateFlatStatus({
    required int inventoryFlatId,
    required String flatStatus,
    required String ownerName,
  }) {
    final updatedBuildingList =
        state.buildingList.map((building) {
          final updatedWingList =
              building.wingList.map((wing) {
                final updatedFloorList =
                    wing.floorList.map((floor) {
                      final updatedFlatList =
                          floor.flatList.map((flat) {
                            if (flat.inventoryFlatId == inventoryFlatId) {
                              return flat.copyWith(
                                flatStatus: flatStatus,
                                ownerName: ownerName,
                              );
                            }
                            return flat;
                          }).toList();

                      return floor.copyWith(flatList: updatedFlatList);
                    }).toList();

                return wing.copyWith(floorList: updatedFloorList);
              }).toList();

          return building.copyWith(wingList: updatedWingList);
        }).toList();

    emit(state.copyWith(buildingList: updatedBuildingList));
  }

  void updateWingSelection(int index, String wing) {
    emit(state.copyWith(wingCurrentPage: index, wingCurrentPageKey: wing));
  }

  Map<String, int> calculateWingCounts(WingModel wing) {
    int total = 0;
    int available = 0;
    int blocked = 0;
    int booked = 0;
    int hold = 0;
    int alloted = 0;

    for (var floor in wing.floorList) {
      for (var flat in floor.flatList) {
        total++;
        switch (flat.flatStatus.toLowerCase()) {
          case "available":
            available++;
            break;
          case "booked":
            booked++;
            break;
          case "blocked":
            blocked++;
            break;
          case "hold":
            hold++;
            break;
          case "alloted":
            alloted++;
            break;
        }
      }
    }

    return {
      "total": total,
      "available": available,
      "blocked": blocked,
      "booked": booked,
      "hold": hold,
      "alloted": alloted,
    };
  }

  // <---- GET Dashboard LIST ---->
  Future getInventoryDashboardList(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true));

    var result = await _inventoryRepository.getInventoryDashboard(
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final InventoryDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            isLoading: false,
            inventoryDashboardModel: model,
            inventoryDashboardModelList: model != null ? [model] : [],
          ),
        );
      },
    );
  }

  void updateStatusFilter(String? status) {
    emit(state.copyWith(selectedFlatStatus: status));
  }

  Future<void> fetchUnitsByProjectId(
    int pageNumber, {
    required Map<String, dynamic> queryParams,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _inventoryRepository.getPaginatedFlats(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(flatList: [], isLoading: false));
      },
      (response) {
        final List<FlatModel> flats = response['data'] as List<FlatModel>;
        final updatedFlats =
            state.currentUnitPage == 0 ? flats : [...state.flatList, ...flats];
        emit(
          state.copyWith(
            flatList: updatedFlats,
            currentUnitPage: pageNumber,
            isLoading: false,
            unitTotalRecords: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  Future<void> resetUnits() async {
    emit(state.copyWith(flatList: [], currentUnitPage: 1, unitTotalRecords: 0));
  }
}
