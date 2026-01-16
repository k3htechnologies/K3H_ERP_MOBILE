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

  // <---- PULL RENT DETAILS ---->
  Future pullRentDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _proposedOfferRepository.pullRentDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        List<RentDetailsModel> updatedList = List.from(state.rentDetails);
        updatedList.addAll(response['data'] as List<RentDetailsModel>);
        emit(state.copyWith(isLoading: false, rentDetails: updatedList));
      },
    );
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

    final result = await _rentRepository.pullTenantApplicantCharges(
      pageNumber: pageNumber,
      pageSize: 20,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: {"ChargeType": chargeName, "Tenure": tenure},
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        List<RentModel> updatedList = List.from(state.rentList);
        updatedList.addAll(response['data'] as List<RentModel>);
        emit(
          state.copyWith(
            isLoading: false,
            rentList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
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
    debugPrint("TAB: $tabName");
    debugPrint("PROJECT: $projectId");
    debugPrint("BUILDING: $buildingId");

    switch (tabName) {
      case 'Additional Rent':
        // API call
        pullChargesDetails(
          context: context,
          pageNumber: state.currentPage,
          projectId: projectId,
          buildingId: buildingId!,
          chargeName: tabName,
          tenure: tenure??"",
        );
        break;

      case 'Rent':
        break;

      case 'Corpus':
        break;

      case 'Brokerage':
        break;

      case 'Shifting':
        break;
    }
  }
}
