import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'parking_state.dart';

class ParkingCubit extends Cubit<ParkingState> {
  ParkingCubit() : super(ParkingState.initial());

  // REPOSITORY
  final ParkingRepository _parkingRepository =
      serviceLocator<ParkingRepository>();

  // <----LOCAL SEARCH PARKING ---->
  Future searchParking(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    final searchText = value.trim().toLowerCase();
    if (state.originalWingGroupedData == null ||
        state.wingCurrentPageKey == null) {
      return;
    }

    final currentWingKey = state.wingCurrentPageKey!;

    final originalList = state.originalWingGroupedData![currentWingKey] ?? [];

    final filteredList =
        searchText.isEmpty
            ? originalList
            : originalList.where((e) {
              final matchesParking = e.parkingNumber.toLowerCase().contains(
                searchText,
              );
              return matchesParking;
            }).toList();

    final updatedWingData = Map<String, List<ParkingModel>>.from(
      state.originalWingGroupedData!,
    );

    updatedWingData[currentWingKey] = filteredList;

    emit(state.copyWith(searchText: value, wingGroupedData: updatedWingData));
  }

  // GET PARKING
  Future getParking(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true, parkingList: []));
    if (projectId == 0) {
      showErrorMessage(context, "Error", "Project Not Selected");
      ParkingCubit();
      emit(state.copyWith(isLoading: false));

      return;
    }
    final result = await _parkingRepository.getParking(projectId: projectId);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (result) {
        var parkingList = result["data"] as List<ParkingModel>;
        var groupedData =
            parkingList.isNotEmpty
                ? groupBy(parkingList, (element) => element.buildingNumber)
                : null;
        if (groupedData != null) {
          //  Preserve building
          String buildingCurrentPageKey =
              state.buildingCurrentPageKey != null &&
                      groupedData.containsKey(state.buildingCurrentPageKey)
                  ? state.buildingCurrentPageKey!
                  : groupedData.keys.first;

          int buildingCurrentPage = groupedData.keys.toList().indexOf(
            buildingCurrentPageKey,
          );

          //  Create wing grouped data
          var wingGroupedData = groupBy(
            groupedData[buildingCurrentPageKey]!,
            (element) => "${element.wing} / ${element.floor}",
          );

          //  Preserve wing
          String? wingCurrentPageKey =
              state.wingCurrentPageKey != null &&
                      wingGroupedData.containsKey(state.wingCurrentPageKey)
                  ? state.wingCurrentPageKey
                  : wingGroupedData.isNotEmpty
                  ? wingGroupedData.keys.first
                  : null;

          int wingCurrentPage =
              wingCurrentPageKey != null
                  ? wingGroupedData.keys.toList().indexOf(wingCurrentPageKey)
                  : 0;
          // Calculate parking counts
          int availableParking = 0;
          int bookedParking = 0;
          int blockedParking = 0;
          int holdParking = 0;
          int memberParking = 0;

          if (wingCurrentPageKey != null) {
            final floorData = wingGroupedData[wingCurrentPageKey]!;
            availableParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "available")
                    .length;
            bookedParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "booked")
                    .length;
            blockedParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "blocked")
                    .length;
            holdParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "hold")
                    .length;
            memberParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "alloted")
                    .length;
          }

          emit(
            state.copyWith(
              isLoading: false,
              parkingList: parkingList,
              groupedData: groupedData,
              buildingCurrentPageKey: buildingCurrentPageKey,
              buildingCurrentPage: buildingCurrentPage,
              wingCurrentPage: wingCurrentPage,
              wingCurrentPageKey: wingCurrentPageKey,
              wingGroupedData: wingGroupedData,
              originalWingGroupedData: wingGroupedData,
              availableParking: availableParking,
              bookedParking: bookedParking,
              blockedParking: blockedParking,
              holdParking: holdParking,
              allotedParking: memberParking,
            ),
          );
          return;
        } else {
          emit(state.copyWith(isLoading: false, parkingList: parkingList));
        }
      },
    );
  }

  Future getParkingWithPagination(
    BuildContext context, {
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true, parkingList: []));
    if (projectId == 0) {
      showErrorMessage(context, "Error", "Project Not Selected");
      ParkingCubit();
      emit(state.copyWith(isLoading: false));

      return;
    }
    final result = await _parkingRepository.getParkingWithPagination(
      pageNumber: pageNumber,
      projectId: projectId,
      queryParams: queryParams,
      pageSize: 10,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (result) {
        var parkingList = result["data"] as List<ParkingModel>;
        var groupedData =
            parkingList.isNotEmpty
                ? groupBy(parkingList, (element) => element.buildingNumber)
                : null;
        if (groupedData != null) {
          //  Preserve building
          String buildingCurrentPageKey =
              state.buildingCurrentPageKey != null &&
                      groupedData.containsKey(state.buildingCurrentPageKey)
                  ? state.buildingCurrentPageKey!
                  : groupedData.keys.first;

          int buildingCurrentPage = groupedData.keys.toList().indexOf(
            buildingCurrentPageKey,
          );

          //  Create wing grouped data
          var wingGroupedData = groupBy(
            groupedData[buildingCurrentPageKey]!,
            (element) => "${element.wing} / ${element.floor}",
          );

          //  Preserve wing
          String? wingCurrentPageKey =
              state.wingCurrentPageKey != null &&
                      wingGroupedData.containsKey(state.wingCurrentPageKey)
                  ? state.wingCurrentPageKey
                  : wingGroupedData.isNotEmpty
                  ? wingGroupedData.keys.first
                  : null;

          int wingCurrentPage =
              wingCurrentPageKey != null
                  ? wingGroupedData.keys.toList().indexOf(wingCurrentPageKey)
                  : 0;
          // Calculate parking counts
          int availableParking = 0;
          int bookedParking = 0;
          int blockedParking = 0;
          int holdParking = 0;
          int memberParking = 0;

          if (wingCurrentPageKey != null) {
            final floorData = wingGroupedData[wingCurrentPageKey]!;
            availableParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "available")
                    .length;
            bookedParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "booked")
                    .length;
            blockedParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "blocked")
                    .length;
            holdParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "hold")
                    .length;
            memberParking =
                floorData
                    .where((e) => e.parkingStatus.toLowerCase() == "alloted")
                    .length;
          }

          emit(
            state.copyWith(
              isLoading: false,
              parkingList: parkingList,
              groupedData: groupedData,
              buildingCurrentPageKey: buildingCurrentPageKey,
              buildingCurrentPage: buildingCurrentPage,
              wingCurrentPage: wingCurrentPage,
              wingCurrentPageKey: wingCurrentPageKey,
              wingGroupedData: wingGroupedData,
              originalWingGroupedData: wingGroupedData,
              availableParking: availableParking,
              bookedParking: bookedParking,
              blockedParking: blockedParking,
              holdParking: holdParking,
              allotedParking: memberParking,
            ),
          );
          return;
        } else {
          emit(state.copyWith(isLoading: false, parkingList: parkingList));
        }
      },
    );
  }

  // HANDLE BUILDING TAB CHANGE
  void handleBuildingTabChange(int index, String building) {
    if (state.groupedData == null) return;

    var buildingData = state.groupedData![building];
    if (buildingData == null || buildingData.isEmpty) return;

    var wingGroupedData = groupBy(
      buildingData,
      (element) => "${element.wing} / ${element.floor}",
    );
    String? wingCurrentPageKey =
        wingGroupedData.isNotEmpty ? wingGroupedData.keys.first : null;

    // Calculate parking counts
    int availableParking = 0;
    int bookedParking = 0;
    int blockedParking = 0;
    int holdParking = 0;
    int allotedParking = 0;

    if (wingCurrentPageKey != null) {
      final floorData = wingGroupedData[wingCurrentPageKey]!;
      for (var e in floorData) {
        switch (e.parkingStatus) {
          case "Available":
            availableParking++;
            break;
          case "Booked":
            bookedParking++;
            break;
          case "Blocked":
            blockedParking++;
            break;
          case "Hold":
            holdParking++;
            break;
          case "Alloted":
            allotedParking++;
            break;
        }
      }
    }

    emit(
      state.copyWith(
        buildingCurrentPage: index,
        buildingCurrentPageKey: building,
        wingGroupedData: wingGroupedData,
        originalWingGroupedData: wingGroupedData,
        wingCurrentPage: 0,
        wingCurrentPageKey: wingCurrentPageKey,
        availableParking: availableParking,
        bookedParking: bookedParking,
        blockedParking: blockedParking,
        holdParking: holdParking,
        allotedParking: allotedParking,
      ),
    );
  }

  // HANDLE WING TAB CHANGE
  void handleWingTabChange(int index, String wing) {
    if (state.wingGroupedData == null) return;

    var wingData = state.wingGroupedData![wing];
    if (wingData == null || wingData.isEmpty) return;

    // Calculate parking counts
    int availableParking =
        wingData.where((e) => e.parkingStatus == "Available").length;
    int bookedParking =
        wingData.where((e) => e.parkingStatus == "Booked").length;
    int blockedParking =
        wingData.where((e) => e.parkingStatus == "Blocked").length;
    int holdParking = wingData.where((e) => e.parkingStatus == "Hold").length;
    int memberParking =
        wingData.where((e) => e.parkingStatus == "Alloted").length;

    emit(
      state.copyWith(
        wingCurrentPage: index,
        wingCurrentPageKey: wing,
        availableParking: availableParking,
        bookedParking: bookedParking,
        blockedParking: blockedParking,
        holdParking: holdParking,
        allotedParking: memberParking,
      ),
    );
  }

  // <---- UPDATE PARKING ---->
  Future updateParking({
    required BuildContext context,
    required int parkingId,
    required String uniqueKey,
    required int projectId,
    required String parkingNumber,
    required String parkingCategory,
    required String parkingType,
    required String parkingSubType,
    required String parkingDimensions,
    required bool isEVChargingAvailable,
    required String parkingStatus,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ParkingId": parkingId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "ParkingNumber": parkingNumber,
      "ParkingCategory": parkingCategory,
      "ParkingType": parkingType,
      "ParkingSubType": parkingSubType,
      "ParkingDimensions": parkingDimensions,
      "IsEVChargingAvailable": isEVChargingAvailable,
      "ParkingStatus": parkingStatus,
      "InventoryBuildingId": inventoryBuildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "InventoryFloorId": inventoryFloorId,
    };
    var updateResult = await _parkingRepository.addUpdateParking(
      body: requestBody,
    );

    goRouter.pop();

    updateResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedParking = response['data'][0] as ParkingModel;
        if (state.parkingList.isNotEmpty) {
          final updatedList =
              state.parkingList.map((item) {
                return item.parkingId == updatedParking.parkingId
                    ? updatedParking
                    : item;
              }).toList();
          // Regroup the data
          var groupedData = groupBy(
            updatedList,
            (element) => element.buildingNumber,
          );

          // Get current building and wing keys
          final currentBuilding = state.buildingCurrentPageKey;
          final currentWing = state.wingCurrentPageKey;

          if (currentBuilding != null &&
              groupedData.containsKey(currentBuilding)) {
            var wingGroupedData = groupBy(
              groupedData[currentBuilding]!,
              (element) => "${element.wing} / ${element.floor}",
            );

            // Calculate parking counts for current wing
            int availableParking = 0;
            int bookedParking = 0;
            int blockedParking = 0;
            int holdParking = 0;
            int memberParking = 0;

            if (currentWing != null &&
                wingGroupedData.containsKey(currentWing)) {
              final wingData = wingGroupedData[currentWing]!;
              availableParking =
                  wingData.where((e) => e.parkingStatus == "Available").length;
              bookedParking =
                  wingData.where((e) => e.parkingStatus == "Booked").length;
              blockedParking =
                  wingData.where((e) => e.parkingStatus == "Blocked").length;
              holdParking =
                  wingData.where((e) => e.parkingStatus == "Hold").length;
              memberParking =
                  wingData.where((e) => e.parkingStatus == "Alloted").length;
            }

            emit(
              state.copyWith(
                isLoading: false,
                parkingList: updatedList,
                groupedData: groupedData,
                wingGroupedData: wingGroupedData,
                originalWingGroupedData: wingGroupedData,
                availableParking: availableParking,
                bookedParking: bookedParking,
                blockedParking: blockedParking,
                holdParking: holdParking,
                allotedParking: memberParking,
              ),
            );
          } else {
            // If building changed, refresh the entire list
            getParking(context, projectId);
          }

          showSuccessMessage(context, subTitle: "Parking Updated Successfully");
        }
      },
    );
  }

  // EXPORT DATA
  Future exportParking(
    BuildContext context,
    int projectId,
    String exportType,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _parkingRepository.exportParking(
      projectId: projectId,
      queryParams: {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Failed", failure.message);
      },
      (response) {
        var exportData = response["data"];
        if (exportData is String) {
          showSuccessMessage(
            context,
            subTitle: 'Successfully Exported as $exportType',
          );
          exportExcelOrPdfMobile(
            exportData,
            exportType.toLowerCase() == "pdf"
                ? "Parking ${DateTime.now()}.pdf"
                : "Parking ${DateTime.now()}.xlsx",
          );
        } else {
          showErrorMessage(
            context,
            "Error",
            "Export failed: Invalid response format",
          );
        }
      },
    );
  }

  void updateStatusFilter(String? status) {
    emit(state.copyWith(selectedFlatStatus: status));
  }
}
