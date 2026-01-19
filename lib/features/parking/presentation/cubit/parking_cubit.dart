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

  // <---- SEARCH PARKING ---->
  Future searchParking(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, parkingList: []));
    await getParking(context, projectId);
  }

  // GET PARKING
  Future getParking(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true, parkingList: []));
    Map<String, dynamic> queryParams = {"ParkingNumber": state.searchText};
    final result = await _parkingRepository.getParking(
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (result) {
        var parkingList = result["data"] as List<ParkingModel>;
        var groupedData =
            parkingList.isNotEmpty
                ? groupBy(parkingList, (element) => element.buildingNumber)
                : null;
        if (groupedData != null) {
          int buildingCurrentPage = 0;
          String buildingCurrentPageKey = groupedData.keys.last;
          int wingCurrentPage = 0;
          var wingGroupedData = groupBy(
            groupedData[buildingCurrentPageKey]!,
            (element) => element.wing,
          );
          String? wingCurrentPageKey =
              wingGroupedData.isNotEmpty ? wingGroupedData.keys.first : null;

          // Calculate parking counts
          int availableParking = 0;
          int bookedParking = 0;
          int blockedParking = 0;
          int holdParking = 0;
          int memberParking = 0;

          if (wingCurrentPageKey != null) {
            final floorData = wingGroupedData[wingCurrentPageKey]!;
            availableParking =
                floorData.where((e) => e.parkingStatus == "Available").length;
            bookedParking =
                floorData.where((e) => e.parkingStatus == "Booked").length;
            blockedParking =
                floorData.where((e) => e.parkingStatus == "Block").length;
            holdParking =
                floorData.where((e) => e.parkingStatus == "Hold").length;
            memberParking =
                floorData.where((e) => e.parkingStatus == "Member").length;
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
              availableParking: availableParking,
              bookedParking: bookedParking,
              blockedParking: blockedParking,
              holdParking: holdParking,
              memberParking: memberParking,
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

    var wingGroupedData = groupBy(buildingData, (element) => element.wing);
    String? wingCurrentPageKey =
        wingGroupedData.isNotEmpty ? wingGroupedData.keys.first : null;

    // Calculate parking counts
    int availableParking = 0;
    int bookedParking = 0;
    int blockedParking = 0;
    int holdParking = 0;
    int memberParking = 0;

    if (wingCurrentPageKey != null) {
      final floorData = wingGroupedData[wingCurrentPageKey]!;
      availableParking =
          floorData.where((e) => e.parkingStatus == "Available").length;
      bookedParking =
          floorData.where((e) => e.parkingStatus == "Booked").length;
      blockedParking =
          floorData.where((e) => e.parkingStatus == "Block").length;
      holdParking = floorData.where((e) => e.parkingStatus == "Hold").length;
      memberParking =
          floorData.where((e) => e.parkingStatus == "Member").length;
    }

    emit(
      state.copyWith(
        buildingCurrentPage: index,
        buildingCurrentPageKey: building,
        wingGroupedData: wingGroupedData,
        wingCurrentPage: 0,
        wingCurrentPageKey: wingCurrentPageKey,
        availableParking: availableParking,
        bookedParking: bookedParking,
        blockedParking: blockedParking,
        holdParking: holdParking,
        memberParking: memberParking,
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
        wingData.where((e) => e.parkingStatus == "Block").length;
    int holdParking = wingData.where((e) => e.parkingStatus == "Hold").length;
    int memberParking =
        wingData.where((e) => e.parkingStatus == "Member").length;

    emit(
      state.copyWith(
        wingCurrentPage: index,
        wingCurrentPageKey: wing,
        availableParking: availableParking,
        bookedParking: bookedParking,
        blockedParking: blockedParking,
        holdParking: holdParking,
        memberParking: memberParking,
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

        // Find and update the parking item in the list
        int index = state.parkingList.indexWhere(
          (e) => e.uniquekey == uniqueKey,
        );

        if (index == -1) {
          // If not found, refresh the entire list
          getParking(context, projectId);
          showSuccessMessage(context, subTitle: "Parking Updated Successfully");
          return;
        }

        final updatedList = List<ParkingModel>.from(state.parkingList);
        if (response['data'] != null && (response['data'] as List).isNotEmpty) {
          updatedList[index] = ParkingModel.fromJson(response['data'][0]);
        } else {
          // If response doesn't have data, refresh the list
          getParking(context, projectId);
          showSuccessMessage(context, subTitle: "Parking Updated Successfully");
          return;
        }

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
            (element) => element.wing,
          );

          // Calculate parking counts for current wing
          int availableParking = 0;
          int bookedParking = 0;
          int blockedParking = 0;
          int holdParking = 0;
          int memberParking = 0;

          if (currentWing != null && wingGroupedData.containsKey(currentWing)) {
            final wingData = wingGroupedData[currentWing]!;
            availableParking =
                wingData.where((e) => e.parkingStatus == "Available").length;
            bookedParking =
                wingData.where((e) => e.parkingStatus == "Booked").length;
            blockedParking =
                wingData.where((e) => e.parkingStatus == "Block").length;
            holdParking =
                wingData.where((e) => e.parkingStatus == "Hold").length;
            memberParking =
                wingData.where((e) => e.parkingStatus == "Member").length;
          }

          emit(
            state.copyWith(
              isLoading: false,
              parkingList: updatedList,
              groupedData: groupedData,
              wingGroupedData: wingGroupedData,
              availableParking: availableParking,
              bookedParking: bookedParking,
              blockedParking: blockedParking,
              holdParking: holdParking,
              memberParking: memberParking,
            ),
          );
        } else {
          // If building changed, refresh the entire list
          getParking(context, projectId);
        }

        showSuccessMessage(context, subTitle: "Parking Updated Successfully");
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
          exportExcelOrPdfMobile(
            exportData,
            exportType.toLowerCase() == "pdf"
                ? "parking_${DateTime.now()}.pdf"
                : "parking_${DateTime.now()}.xlsx",
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
}
