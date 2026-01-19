import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/repository/proposed_offer.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/rent.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/repository/rent.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'rent_state.dart';

class RentCubit extends Cubit<RentState> {
  RentCubit() : super(RentState.initial());

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // PROPOSED OFFER REPOSITORY
  final ProposedOfferRepository _proposedOfferRepository =
      serviceLocator<ProposedOfferRepository>();

  // RENT REPOSITORY
  final RentRepository _rentRepository = serviceLocator<RentRepository>();

  // <---- GET BUILDING LIST ---->
  Future getBuildingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final newData = List<RedevelopmentBuildingModel>.from(
          response['data'] as List<RedevelopmentBuildingModel>,
        );
        final existingIds = state.buildingList.map((b) => b.buildingId).toSet();
        final uniqueNewData =
            newData
                .where((building) => !existingIds.contains(building.buildingId))
                .toList();
        List<RedevelopmentBuildingModel> updatedList = List.from(
          state.buildingList,
        );
        updatedList.addAll(uniqueNewData);
        final totalCount = response['totalNumberOfRecord'] ?? 0;
        emit(
          state.copyWith(
            isLoading: false,
            buildingList: updatedList,
            buildingTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- PULL RENT DETAILS (For Tenure List) ---->
  Future pullRentDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    final result = await _proposedOfferRepository.pullRentDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    return result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final List<RentDetailsModel> rentDetailsList =
            List<RentDetailsModel>.from(response['data'] ?? []);

        emit(state.copyWith(rentDetails: rentDetailsList));
      },
    );
  }

  // <---- EXTRACT TENURE LIST FROM RENT DETAILS ---->
  void extractTenureList(String chargeType) {
    final List<RentDetailsModel> rentDetailsList = state.rentDetails;

    final Set<String> tenureSet = {};
    for (var item in rentDetailsList) {
      debugPrint("  - Type: '${item.type}', Tenure: '${item.tenure}'");
      final String tenureValue = item.tenure.trim();
      if (tenureValue.isNotEmpty) {
        String tenure = tenureValue;
        if (tenureValue.toLowerCase().startsWith('tenure')) {
          tenure = tenureValue.substring(6).trim();
        }
        if (tenure.isNotEmpty) {
          tenureSet.add(tenure);
          debugPrint("    -> Added tenure: '$tenure' (from '$tenureValue')");
        }
      }
    }
    final List<String> tenureList = tenureSet.toList()..sort();

    emit(state.copyWith(tenureList: tenureList));
  }

  // <---- PULL CHARGES DETAILS ---->
  Future pullChargesDetails({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
    required int buildingId,
    required String chargeName,
    required String tenure,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"ChargeType": chargeName};
    if (tenure.isNotEmpty) {
      queryParams["Tenure"] = tenure;
    }

    final result = await _rentRepository.pullTenantApplicantCharges(
      pageNumber: pageNumber,
      pageSize: 5,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: queryParams,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final List<RentModel> rawData = List<RentModel>.from(
          response['data'] ?? [],
        );
        final int totalRecords = response['totalNumberOfRecord'] ?? 0;
        final Map<String, RentModel> uniqueItemsMap = {};
        for (var item in rawData) {
          final String uniqueKey =
              "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
          if (!uniqueItemsMap.containsKey(uniqueKey)) {
            uniqueItemsMap[uniqueKey] = item;
          }
        }
        final List<RentModel> newData = uniqueItemsMap.values.toList();

        List<RentModel> updatedList;
        if (pageNumber == 1) {
          updatedList = newData;
        } else {
          final Map<String, RentModel> existingItemsMap = {};
          for (var item in state.rentList) {
            final String uniqueKey =
                "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
            existingItemsMap[uniqueKey] = item;
          }
          final List<RentModel> uniqueNewData = [];
          for (var item in newData) {
            final String uniqueKey =
                "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
            if (!existingItemsMap.containsKey(uniqueKey)) {
              uniqueNewData.add(item);
            }
          }

          updatedList = [...state.rentList, ...uniqueNewData];
        }
        emit(
          state.copyWith(
            isLoading: false,
            rentList: updatedList,
            totalNumberOfRecord: totalRecords,
            currentPage: pageNumber,
            selectedTenure: tenure,
          ),
        );
      },
    );
  }

  void onTabChanged(
    int index,
    BuildContext context, {
    required int projectId,
    required int? buildingId,
    required String? tenure,
    required String tabName,
  }) {
    // Clear rent list and selected tenure when switching tabs
    emit(
      state.copyWith(
        rentList: [],
        selectedTenure: "",
        selectedTenureIndex: -1,
        currentPage: 1,
        currentTabIndex: index,
      ),
    );

    if (buildingId == null) {
      return;
    }

    if (tabName == 'Rent' || tabName == 'Brokerage') {
      extractTenureList(tabName);
      pullChargesDetails(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        buildingId: buildingId,
        chargeName: tabName,
        tenure: "",
      );
    } else {
      emit(state.copyWith(tenureList: []));
      pullChargesDetails(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        buildingId: buildingId,
        chargeName: tabName,
        tenure: "",
      );
    }
  }

  void onTenureChanged(
    BuildContext context, {
    required int projectId,
    required int buildingId,
    required String tabName,
    required String tenure,
    required int tenureIndex,
  }) {
    emit(
      state.copyWith(
        selectedTenure: tenure,
        selectedTenureIndex: tenureIndex,
        rentList: [],
        currentPage: 1,
      ),
    );

    pullChargesDetails(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      buildingId: buildingId,
      chargeName: tabName,
      tenure: tenure,
    );
  }
}
