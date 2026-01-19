import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

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
                ? groupBy(
                    parkingList,
                    (element) => element.buildingNumber,
                  )
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
            availableParking = floorData
                .where((e) => e.parkingStatus == "Available")
                .length;
            bookedParking = floorData
                .where((e) => e.parkingStatus == "Booked")
                .length;
            blockedParking = floorData
                .where((e) => e.parkingStatus == "Block")
                .length;
            holdParking = floorData
                .where((e) => e.parkingStatus == "Hold")
                .length;
            memberParking = floorData
                .where((e) => e.parkingStatus == "Member")
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
      availableParking = floorData
          .where((e) => e.parkingStatus == "Available")
          .length;
      bookedParking = floorData
          .where((e) => e.parkingStatus == "Booked")
          .length;
      blockedParking = floorData
          .where((e) => e.parkingStatus == "Block")
          .length;
      holdParking = floorData
          .where((e) => e.parkingStatus == "Hold")
          .length;
      memberParking = floorData
          .where((e) => e.parkingStatus == "Member")
          .length;
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
    int availableParking = wingData
        .where((e) => e.parkingStatus == "Available")
        .length;
    int bookedParking = wingData
        .where((e) => e.parkingStatus == "Booked")
        .length;
    int blockedParking = wingData
        .where((e) => e.parkingStatus == "Block")
        .length;
    int holdParking = wingData
        .where((e) => e.parkingStatus == "Hold")
        .length;
    int memberParking = wingData
        .where((e) => e.parkingStatus == "Member")
        .length;
    
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

  // EXPORT DATA
  Future exportParking(
    BuildContext context,
    int projectId,
    String exportType,
  ) async {
    var result = await _parkingRepository.exportParking(
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
              ? "parking_${DateTime.now()}.pdf"
              : "parking_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
