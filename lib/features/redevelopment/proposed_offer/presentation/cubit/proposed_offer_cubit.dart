import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/corpus_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/extra_carpet_area.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/gst_on_existing_plus_free_area.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/lien_to_society_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/parking_allotment.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/project_completion.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/security_deposite.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/shifting_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/repository/proposed_offer.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'proposed_offer_state.dart';

class ProposedOfferCubit extends Cubit<ProposedOfferState> {
  ProposedOfferCubit() : super(ProposedOfferState.initial());

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // BUILDING REPOSITORY
  final ProposedOfferRepository _proposedOfferRepository =
      serviceLocator<ProposedOfferRepository>();

  // <---- GET BUILDING LIST ---->
  Future<List<RedevelopmentBuildingModel>> getBuildingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
    );

    final buildingList = result.fold<List<RedevelopmentBuildingModel>>(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
        return state.buildingList;
      },
      (response) {
        final newData = List<RedevelopmentBuildingModel>.from(
          response['data'] as List<RedevelopmentBuildingModel>,
        );
        // Get existing building IDs to avoid duplicates
        final existingIds = state.buildingList.map((b) => b.buildingId).toSet();
        // Filter out duplicates from new data
        final uniqueNewData =
            newData
                .where((building) => !existingIds.contains(building.buildingId))
                .toList();
        List<RedevelopmentBuildingModel> updatedList = List.from(
          state.buildingList,
        );
        updatedList.addAll(uniqueNewData);
        emit(state.copyWith(isLoading: false, buildingList: updatedList));
        return updatedList;
      },
    );

    return buildingList;
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL EXTRA CARPET AREA ---->
  Future pullExtraCarpetArea({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearExtraCarpet: true));

    final result = await _proposedOfferRepository.pullExtraCarpetArea(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            extraCarpetArea:
                response['data'].isEmpty
                    ? null
                    : (response['data'] as List<ExtraCarpetAreaModel>).first,
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE EXTRA CARPET AREA ---->
  Future<void> addUpdateExtraCarpetArea(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required String extraCarpetAreaOfferedType,
    required double residentialExtraCarpetPercent,
    required double commercialExtraCarpetPercent,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "ProposedOfferExtraCarpetAreaId":
          state.extraCarpetArea?.proposedOfferExtraCarpetAreaId ?? 0,
      if (state.extraCarpetArea != null)
        "Uniquekey": state.extraCarpetArea!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "ExtraCarpetAreaOfferedType": extraCarpetAreaOfferedType,
      "ResidentialExtraCarpetPercent": residentialExtraCarpetPercent,
      "CommercialExtraCarpetPercent": commercialExtraCarpetPercent,
    };

    final result = await _proposedOfferRepository.addUpdateExtraCarpetArea(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            extraCarpetArea:
                (response['data'] as List<ExtraCarpetAreaModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: "Extra Carpet Area Updated");
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL CORPUS DETAILS ---->
  Future pullCorpusDetails({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearCorpus: true));

    final result = await _proposedOfferRepository.pullCorpusDetails(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            corpusDetails: (response['data'] as List<CorpusDetailsModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE CORPUS DETAILS ---->
  Future<void> addUpdateCorpusDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double corpusOfferedToResidentialAmount,
    required double corpusOfferedToCommercialAmount,
    required List<ProposedOfferCorpusDetailsWithPaymentStageData>
    paymentStageList,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final paymentStageListJson =
        paymentStageList
            .map(
              (item) => {
                "Type": item.type,
                "Stage": item.stage,
                "StagePercentage": item.stagePercentage,
                "Amount": item.amount,
              },
            )
            .toList();

    Map<String, dynamic> body = {
      "ProposedOfferCorpusDetailsId":
          state.corpusDetails?.proposedOfferCorpusDetailsId ?? 0,
      if (state.corpusDetails != null)
        "Uniquekey": state.corpusDetails!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "CorpusOfferedToResidentialAmount": corpusOfferedToResidentialAmount,
      "CorpusOfferedToCommercialAmount": corpusOfferedToCommercialAmount,
      "CorpusDetailsWithPaymentStageJSON": jsonEncode(paymentStageListJson),
    };

    final result = await _proposedOfferRepository.addUpdateCorpusDetails(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            corpusDetails: (response['data'] as List<CorpusDetailsModel>)[0],
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL SHIFTING DETAILS ---->
  Future pullShiftingDetails({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearShifting: true));

    final result = await _proposedOfferRepository.pullShiftingDetails(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            shiftingDetails:
                (response['data'] as List<ShiftingDetailsModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE SHIFTING DETAILS ---->
  Future<void> addUpdateShiftingDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double shiftingOfferedToResidentialAmount,
    required double shiftingOfferedToCommercialAmount,
    required List<ProposedOfferShiftingDetailsWithPaymentStageData>
    paymentStageList,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final paymentStageListJson =
        paymentStageList
            .map(
              (item) => {
                "Type": item.type,
                "Stage": item.stage,
                "StagePercentage": item.stagePercentage,
                "Amount": item.amount,
              },
            )
            .toList();

    Map<String, dynamic> body = {
      "ProposedOfferShiftingDetailsId":
          state.shiftingDetails?.proposedOfferShiftingDetailsId ?? 0,
      if (state.shiftingDetails != null)
        "Uniquekey": state.shiftingDetails!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "ShiftingOfferedToResidentialAmount": shiftingOfferedToResidentialAmount,
      "ShiftingOfferedToCommercialAmount": shiftingOfferedToCommercialAmount,
      "ShiftingDetailsWithPaymentStageJSON": jsonEncode(paymentStageListJson),
    };

    final result = await _proposedOfferRepository.addUpdateShiftingDetails(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            shiftingDetails:
                (response['data'] as List<ShiftingDetailsModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: "Shifting Details Updated");
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL LIEN TO SOCIETY DETAILS ---->

  Future pullLienToSocietyDetails({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearLienToSociety: true));

    final result = await _proposedOfferRepository.pullLienToSocietyDetails(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            lienToSocietyDetails:
                (response['data'] as List<LienToSocietyDetailsModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE LIEN TO SOCIETY DETAILS ---->
  Future<void> addUpdateLienToSocietyDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double residentialAreaSqFt,
    required double commercialAreaSqFt,
    required int numberOfResidentialLienUnits,
    required int numberOfCommercialLienUnits,
    required List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>
    paymentStageList,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final paymentStageListJson =
        paymentStageList
            .map(
              (item) => {
                "Type": item.type,
                "Stage": item.stage,
                "CarpetAreaSqFt": item.carpetAreaSqFt,
                "IsRelease": item.isRelease,
              },
            )
            .toList();

    Map<String, dynamic> body = {
      "ProposedOfferLienToSocietyDetailsId":
          state.lienToSocietyDetails?.proposedOfferLienToSocietyDetailsId ?? 0,
      if (state.lienToSocietyDetails != null)
        "Uniquekey": state.lienToSocietyDetails!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "ResidentialAreaSqFt": residentialAreaSqFt,
      "CommercialAreaSqFt": commercialAreaSqFt,
      "NumberOfResidentialLienUnits": numberOfResidentialLienUnits,
      "NumberOfCommercialLienUnits": numberOfCommercialLienUnits,
      "LienToSocietyWithPaymentStageJSON": jsonEncode(paymentStageListJson),
    };

    final result = await _proposedOfferRepository.addUpdateLienToSocietyDetails(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            lienToSocietyDetails:
                (response['data'] as List<LienToSocietyDetailsModel>)[0],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Lien To Society Details Updated",
        );
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL SECURITY DEPOSIT DETAILS ---->
  Future pullSecurityDepositDetails({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearSecurityDeposit: true));

    final result = await _proposedOfferRepository.pullSecurityDepositDetails(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            securityDepositDetails:
                (response['data'] as List<SecurityDepositModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE SECURITY DEPOSIT DETAILS ---->
  Future<void> addUpdateSecurityDepositDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double securityDepositToSocietyAmount,
    required List<ProposedOfferSecurityDepositDetailsWithPaymentStageData>
    paymentStageList,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final paymentStageListJson =
        paymentStageList
            .map(
              (item) => {
                "Type": item.type,
                "Stage": item.stage,
                "Amount": item.amount,
              },
            )
            .toList();

    Map<String, dynamic> body = {
      "ProposedOfferSecurityDepositDetailsId":
          state.securityDepositDetails?.proposedOfferSecurityDepositDetailsId ??
          0,
      if (state.securityDepositDetails != null)
        "Uniquekey": state.securityDepositDetails!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "SecurityDepositToSocietyAmount": securityDepositToSocietyAmount,
      "SecurityDepositToSocietyWithPaymentStageJSON": jsonEncode(
        paymentStageListJson,
      ),
    };

    final result = await _proposedOfferRepository
        .addUpdateSecurityDepositDetails(body: body);

    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            securityDepositDetails:
                (response['data'] as List<SecurityDepositModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: "Security Deposit Updated");
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL PARKING ALLOTMENT ---->
  Future<bool> pullParkingAllotment({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearParkingAllotment: true));

    final result = await _proposedOfferRepository.pullParkingAllotment(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            parkingAllotment:
                (response['data'] as List<ParkingAllotmentModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE PARKING ALLOTMENT ---->
  Future<void> addUpdateParkingAllotment(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int numberOfParkingAllottedToMembers,
    required double totalParkingPercentageAllottedToSociety,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "ProposedOfferParkingAllotmentId":
          state.parkingAllotment?.proposedOfferParkingAllotmentId ?? 0,
      if (state.parkingAllotment != null)
        "Uniquekey": state.parkingAllotment!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "NumberOfParkingAllottedToMembers": numberOfParkingAllottedToMembers,
      "TotalParkingPercentageAllottedToSociety":
          totalParkingPercentageAllottedToSociety,
    };

    final result = await _proposedOfferRepository.addUpdateParkingAllotment(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            parkingAllotment:
                (response['data'] as List<ParkingAllotmentModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: "Parking Allotment Updated");
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL GST ON EXISTING PLUS FREE AREA ---->
  Future pullGSTonExistingPlusFreeArea({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearGST: true));

    final result = await _proposedOfferRepository.pullGSTonExistingPlusFreeArea(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            gstOnExistingPlusFreeArea:
                (response['data'] as List<GstOnExistingPlusFreeAreaModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE GST ON EXISTING PLUS FREE AREA ---->
  Future<void> addUpdateGSTonExistingPlusFreeArea(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double gstOnAreaByMemberPercent,
    required double gstOnAreaByDeveloperPercent,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "ProposedOfferGSTonExistingPlusFreeAreaId":
          state
              .gstOnExistingPlusFreeArea
              ?.proposedOfferGSTonExistingPlusFreeAreaId ??
          0,
      if (state.gstOnExistingPlusFreeArea != null)
        "Uniquekey": state.gstOnExistingPlusFreeArea!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "GSTOnAreaByMemberPercent": gstOnAreaByMemberPercent,
      "GSTOnAreaByDeveloperPercent": gstOnAreaByDeveloperPercent,
    };

    final result = await _proposedOfferRepository
        .addUpdateGSTonExistingPlusFreeArea(body: body);

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            gstOnExistingPlusFreeArea:
                (response['data'] as List<GstOnExistingPlusFreeAreaModel>)[0],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "GST on Existing + Free Area Updated",
        );
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL PROJECT COMPLETION ---->
  Future<bool> pullProjectCompletion({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearProjectCompletion: true));

    final result = await _proposedOfferRepository.pullProjectCompletion(
      projectId: projectId,
      buildingId: buildingId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (response) {
        if (response['data'].isEmpty) {
          emit(state.copyWith(isLoading: false));
          return false;
        }
        emit(
          state.copyWith(
            isLoading: false,
            projectCompletion:
                (response['data'] as List<ProjectCompletionModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // <---- ADD UPDATE PROJECT COMPLETION ---->
  Future<void> addUpdateProjectCompletion(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int completionTimelineMonths,
    required int gracePeriodMonths,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "ProposedOfferProjectCompletionId":
          state.projectCompletion?.proposedOfferProjectCompletionId ?? 0,
      if (state.projectCompletion != null)
        "Uniquekey": state.projectCompletion!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "CompletionTimelineMonths": completionTimelineMonths,
      "GracePeriodMonths": gracePeriodMonths,
    };

    final result = await _proposedOfferRepository.addUpdateProjectCompletion(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            projectCompletion:
                (response['data'] as List<ProjectCompletionModel>)[0],
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // <---- PULL RENT DETAILS ---->
  Future pullRentDetails({
    required BuildContext context,
    required int pageNumber,
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
        emit(
          state.copyWith(
            isLoading: false,
            rentDetails: updatedList,
            totalNumberOfRecordRent:
            response['totalNumberOfRecord'] == 0 &&
                state.currentPageRent != 1
                ? state.totalNumberOfRecordRent - 1
                : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD RENT DETAILS ---->
  Future<void> addUpdateRentDetails(
      BuildContext context, {
        required int buildingId,
        required int projectId,
        required bool isAdditionalRent,
        required String type,
        required String tenure,
        required double amount,
        required String unitSqFtLumsum,
        required double carpetAreaSqFt,
        required DateTime rentStartDate,
        required DateTime rentEndDate,
        required bool isPayBrokerage,
      }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "IsAdditionalRent": isAdditionalRent,
      "Type": type,
      "Tenure": tenure,
      "Amount": amount,
      "UnitSqFtLumsum": unitSqFtLumsum,
      "CarpetAreaSqFt": carpetAreaSqFt,
      "RentStartDate": rentStartDate.toIso8601String(),
      "RentEndDate": rentEndDate.toIso8601String(),
      "IsPayBrokerage": isPayBrokerage,
    };

    final result = await _proposedOfferRepository.addUpdateRentDetails(
      body: body,
    );

    goRouter.pop();
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false,));
        showErrorMessage(context, "Error Message", failure.message);
      },
          (response) {
        goRouter.pop();
        var list = [
          response['data'][0] as RentDetailsModel,
          ...state.rentDetails,
        ];
        emit(
          state.copyWith(
            isLoading: false,
            rentDetails: list,
            totalNumberOfRecordRent:
            state.totalNumberOfRecordRent == -1
                ? 1
                : state.totalNumberOfRecordRent + 1,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // <---- UPDATE RENT DETAILS ---->
  Future<void> updateRentDetails(
      BuildContext context, {
        required int buildingId,
        required int projectId,
        required int proposedOfferRentDetailsId,
        required bool isAdditionalRent,
        required String uniqueKey,
        required String type,
        required String tenure,
        required double amount,
        required String unitSqFtLumsum,
        required double carpetAreaSqFt,
        required DateTime rentStartDate,
        required DateTime rentEndDate,
        required bool isPayBrokerage,
        required int index,
      }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "ProposedOfferRentDetailsId": proposedOfferRentDetailsId,
      "Uniquekey": uniqueKey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "IsAdditionalRent": isAdditionalRent,
      "Type": type,
      "Tenure": tenure,
      "Amount": amount,
      "UnitSqFtLumsum": unitSqFtLumsum,
      "CarpetAreaSqFt": carpetAreaSqFt,
      "RentStartDate": rentStartDate.toIso8601String(),
      "RentEndDate": rentEndDate.toIso8601String(),
      "IsPayBrokerage": isPayBrokerage,
    };

    final result = await _proposedOfferRepository.addUpdateRentDetails(
      body: body,
    );

    goRouter.pop();
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false,));
        showErrorMessage(context, "Error Message", failure.message);
      },
          (response) {
        final updatedList = List<RentDetailsModel>.from(state.rentDetails);
        updatedList[index] = (response['data'][0] as RentDetailsModel);
        goRouter.pop();

        emit(
          state.copyWith(
            rentDetails: updatedList,
          ),
        );
        showSuccessMessage(context,subTitle: "Rent Details Updated");
      },
    );
  }

}
