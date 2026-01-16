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
        List<RedevelopmentBuildingModel> updatedList = List.from(
          state.buildingList,
        );
        updatedList.addAll(
          response['data'] as List<RedevelopmentBuildingModel>,
        );
        emit(state.copyWith(isLoading: false, buildingList: updatedList));
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
        
        // Store rentDetails in state
        emit(state.copyWith(rentDetails: rentDetailsList));
      },
    );
  }

  // <---- EXTRACT TENURE LIST FROM RENT DETAILS ---->
  void extractTenureList(String chargeType) {
    final List<RentDetailsModel> rentDetailsList = state.rentDetails;
    
    debugPrint("=== EXTRACT TENURE LIST ===");
    debugPrint("ChargeType: $chargeType");
    debugPrint("Total rentDetails: ${rentDetailsList.length}");
    
    // Extract unique tenures from ALL rentDetails (don't filter by type)
    // The type field might not match chargeType, so get all tenures
    final Set<String> tenureSet = {};
    for (var item in rentDetailsList) {
      debugPrint("  - Type: '${item.type}', Tenure: '${item.tenure}'");
      final String tenureValue = item.tenure.trim();
      if (tenureValue.isNotEmpty) {
        // Extract just the number if it's "Tenure 1", "Tenure 2", etc.
        String tenure = tenureValue;
        if (tenureValue.toLowerCase().startsWith('tenure')) {
          tenure = tenureValue.substring(6).trim(); // Remove "Tenure" prefix
        }
        if (tenure.isNotEmpty) {
          tenureSet.add(tenure);
          debugPrint("    -> Added tenure: '$tenure' (from '$tenureValue')");
        }
      }
    }
    final List<String> tenureList = tenureSet.toList()..sort();
    
    debugPrint("Extracted Tenures: $tenureList");
    debugPrint("===========================");
    
    // Update tenure list in state
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
        
        // All records are needed for calculations (including TenantApplicantChargesId == 0)
        // Different stages/dates for the same tenant are NOT duplicates - they're needed for calculations
        // Only deduplicate if the exact same record appears multiple times in the response
        // Use a composite key: tenantApplicantChargesId + tenantId + tenantApplicantId + buildingId + stage + date
        final Map<String, RentModel> uniqueItemsMap = {};
        for (var item in rawData) {
          // Create a unique key combining all identifying fields
          // This ensures we don't add the exact same record twice, but allows different stages/dates
          final String uniqueKey = 
              "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
          
          // Only add if key doesn't exist (prevents exact duplicates)
          if (!uniqueItemsMap.containsKey(uniqueKey)) {
            uniqueItemsMap[uniqueKey] = item;
          }
        }
        final List<RentModel> newData = uniqueItemsMap.values.toList();
        
        // Clear list on first page, append on subsequent pages (pagination)
        List<RentModel> updatedList;
        if (pageNumber == 1) {
          // First page - use deduplicated data
          updatedList = newData;
        } else {
          // Subsequent pages - prevent duplicates using the same composite key logic
          final Map<String, RentModel> existingItemsMap = {};
          for (var item in state.rentList) {
            final String uniqueKey = 
                "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
            existingItemsMap[uniqueKey] = item;
          }
          
          // Filter out items that already exist and add new ones
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
        
        // Don't limit to totalRecords - all records are needed for calculations
        // totalRecords represents unique tenant/applicant combinations, not total display records
        // The widgets (CorpusWidget, RentWidget, etc.) need all records to calculate totals
        
        debugPrint("=== PULL CHARGES DETAILS RESPONSE ===");
        debugPrint("PageNumber: $pageNumber");
        debugPrint("ChargeType: $chargeName");
        debugPrint("Tenure: '$tenure'");
        debugPrint("Raw data count: ${rawData.length}");
        debugPrint("Deduplicated data count: ${newData.length}");
        debugPrint("Final list count: ${updatedList.length}");
        debugPrint("TotalNumberOfRecord: $totalRecords");
        debugPrint("=====================================");
        
        // Preserve tenureList when updating state
        emit(
          state.copyWith(
            isLoading: false,
            rentList: updatedList,
            totalNumberOfRecord: totalRecords,
            currentPage: pageNumber,
            selectedTenure: tenure,
            // Preserve tenureList - don't clear it
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
    emit(state.copyWith(
      rentList: [],
      selectedTenure: "",
      selectedTenureIndex: -1,
      currentPage: 1,
      currentTabIndex: index,
    ));

    if (buildingId == null) {
      return;
    }

    // For Rent and Brokerage tabs, extract tenure list from stored rentDetails
    if (tabName == 'Rent' || tabName == 'Brokerage') {
      // Extract tenure list from stored rentDetails
      extractTenureList(tabName);
      // Call API with empty tenure initially to get all data
      pullChargesDetails(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        buildingId: buildingId,
        chargeName: tabName,
        tenure: "", // Empty tenure to get all data initially
      );
    } else {
      // Clear tenure list for other tabs
      emit(state.copyWith(tenureList: []));
      // Call API for other tabs
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
    // Reset and fetch data with tenure filter
    emit(state.copyWith(
      selectedTenure: tenure,
      selectedTenureIndex: tenureIndex,
      rentList: [],
      currentPage: 1,
    ));

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
