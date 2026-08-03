import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/additional_information_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/bank_guarantee_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/corpus_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/extra_carpet_area.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/gst_on_existing_plus_free_area.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/lien_to_society_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/parking_allotment.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/project_completion.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/ready_reckover_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/security_deposite.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/shifting_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/repository/proposed_offer.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'proposed_offer_state.dart';

class ProposedOfferCubit extends Cubit<ProposedOfferState> {
  ProposedOfferCubit() : super(ProposedOfferState.initial());

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // BUILDING REPOSITORY
  final ProposedOfferRepository _proposedOfferRepository =
      serviceLocator<ProposedOfferRepository>();

  final InventoryRepository _inventoryRepository =
      serviceLocator<InventoryRepository>();

  void updateBuildingDetails(
    RedevelopmentBuildingModel? buildingModel, {
    bool clearBuildingDetails = false,
  }) {
    emit(
      state.copyWith(
        buildingDetails: buildingModel,
        clearbuildingDetails: clearBuildingDetails,
      ),
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL EXTRA CARPET AREA
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

  // ADD UPDATE EXTRA CARPET AREA
  Future<void> addUpdateExtraCarpetArea(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required String extraCarpetAreaOfferedType,
    required double residentialExtraCarpetPercent,
    required double commercialExtraCarpetPercent,
    required String remark,
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
      "Remark": remark,
    };

    final result = await _proposedOfferRepository.addUpdateExtraCarpetArea(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
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

  // PULL CORPUS DETAILS
  Future pullHardshipDetails({
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearHardshipOffer: true));

    final result = await _proposedOfferRepository.pullHardshipDetails(
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
            hardshipOfferDetails:
                (response['data'] as List<HardshipOfferDetailsModel>)[0],
          ),
        );
        return true;
      },
    );
  }

  // ADD UPDATE CORPUS DETAILS
  Future<void> addUpdateHardshipDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double corpusOfferedToResidentialAmount,
    required double corpusOfferedToCommercialAmount,
    required String remark,
    required List<ProposedOfferHardshipDetailsWithPaymentStageData>
    paymentStageList,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final paymentStageListJson =
        paymentStageList
            .map(
              (item) => {
                "ProposedOfferHardshipDetailsWithPaymentStageId":
                    item.proposedOfferHardshipDetailsWithPaymentStageId,
                "Type": item.type,
                "Stage": item.stage,
                "StagePercentage": item.stagePercentage,
                "Amount": item.amount,
                "UnitSqFtLumsum": item.unitSqFtLumsum,
                "CarpetAreaSqFt": item.carpetAreaSqFt,
              },
            )
            .toList();

    Map<String, dynamic> body = {
      "ProposedOfferHardshipDetailsId":
          state.hardshipOfferDetails?.proposedOfferHardshipDetailsId ?? 0,
      if (state.hardshipOfferDetails != null)
        "Uniquekey": state.hardshipOfferDetails!.uniquekey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "HardshipOfferedToResidentialAmount": corpusOfferedToResidentialAmount,
      "HardshipOfferedToCommercialAmount": corpusOfferedToCommercialAmount,
      "HardshipDetailsWithPaymentStageJSON": jsonEncode(paymentStageListJson),
      "Remark": remark,
    };

    final result = await _proposedOfferRepository.addUpdateHardshipDetails(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            hardshipOfferDetails:
                (response['data'] as List<HardshipOfferDetailsModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteHardshipDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _proposedOfferRepository.deleteHardshipDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);

        emit(state.copyWith(clearHardshipOffer: true));
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL SHIFTING DETAILS
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

  // ADD UPDATE SHIFTING DETAILS
  Future<void> addUpdateShiftingDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double shiftingOfferedToResidentialAmount,
    required double shiftingOfferedToCommercialAmount,
    required List<ProposedOfferShiftingDetailsWithPaymentStageData>
    paymentStageList,
    required String remark,
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
      "Remark": remark,
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

  Future deleteShiftingDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _proposedOfferRepository.deleteShiftingDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);

        emit(state.copyWith(clearShifting: true));
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  Future<List<Map<String, dynamic>>> fetchUnitsByProjectId() async {
    emit(state.copyWith(isLoading: true));
    final result = await _inventoryRepository.getPaginatedFlats(
      pageNumber: 1,
      pageSize: 1000,
      projectId: getProject().projectId,
    );

    return result.fold((failure) => <Map<String, dynamic>>[], (response) {
      emit(state.copyWith(isLoading: false));
      final flats = response['data'] as List<FlatModel>;

      return flats
          .map(
            (flat) => {
              "zAttributesId": flat.inventoryFlatId,
              "DisplayName":
                  "${flat.buildingNumber} - ${flat.wing} - ${flat.floor} - ${flat.flat}",
            },
          )
          .toList();
    });
  }

  // PULL LIEN TO SOCIETY DETAILS
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

  // ADD UPDATE LIEN TO SOCIETY DETAILS
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
    required String commercialInventoryFlatId,
    required String residentialInventoryFlatId,
    required String remark,
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
      "ResidentialInventoryFlatId": residentialInventoryFlatId,
      "CommercialInventoryFlatId": commercialInventoryFlatId,
      "Remark": remark,
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

  // PULL SECURITY DEPOSIT DETAILS
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

  // ADD UPDATE SECURITY DEPOSIT DETAILS
  Future<void> addUpdateSecurityDepositDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double securityDepositToSocietyAmount,
    required double interestAmount,
    required List<ProposedOfferSecurityDepositDetailsWithPaymentStageData>
    paymentStageList,
    required String remark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final paymentStageListJson =
        paymentStageList
            .map(
              (item) => {
                "Type": item.type,
                "Stage": item.stage,
                "Amount": item.amount,
                "IsRelease": item.isRelease,
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
      "InterestAmount": interestAmount,
      "Remark": remark,
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

  Future deleteSecurityDepositDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _proposedOfferRepository
        .deleteSecurityDepositDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);

        emit(state.copyWith(clearSecurityDeposit: true));
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL PARKING ALLOTMENT
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

  // ADD UPDATE PARKING ALLOTMENT
  Future<void> addUpdateParkingAllotment(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int numberOfParkingAllottedToMembers,
    required double totalParkingPercentageAllottedToSociety,
    required String remark,
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
      "Remark": remark,
    };

    final result = await _proposedOfferRepository.addUpdateParkingAllotment(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
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

  // PULL GST ON EXISTING PLUS FREE AREA
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

  // ADD UPDATE GST ON EXISTING PLUS FREE AREA
  Future<void> addUpdateGSTonExistingPlusFreeArea(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required double gstOnAreaByMemberPercent,
    required double gstOnAreaByDeveloperPercent,
    required String remark,
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
      "Remark": remark,
    };

    final result = await _proposedOfferRepository
        .addUpdateGSTonExistingPlusFreeArea(body: body);

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
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

  // PULL PROJECT COMPLETION
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

  // ADD UPDATE PROJECT COMPLETION
  Future<void> addUpdateProjectCompletion(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int completionTimelineMonths,
    required int gracePeriodMonths,
    required String remark,
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
      "Remark": remark,
    };

    final result = await _proposedOfferRepository.addUpdateProjectCompletion(
      body: body,
    );

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
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

  // PULL RENT DETAILS
  Future pullTemporaryAccommodationAlternativeDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _proposedOfferRepository
        .pullTemporaryAccommodationAlternativeDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            temporaryAccommodationAlternativeDetails:
                response['data']
                    as List<TemporaryAlternativeAccommodationDetailsModel>,
            totalNumberOfRecordTemporaryAccommodationAlternative:
                response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  // ADD RENT DETAILS
  Future<void> addTemporaryAccommodationAlternativeDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required bool isAdditionalTemporaryAlternateAccommodation,
    required String type,
    required String tenure,
    required double amount,
    required String unitSqFtLumsum,
    required double carpetAreaSqFt,
    required DateTime? temporaryAlternateAccommodationStartDate,
    required DateTime? temporaryAlternateAccommodationEndDate,
    required bool isPayBrokerage,
    required bool isPayTAA,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> body = {
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "IsAdditionalTemporaryAlternateAccommodation":
          isAdditionalTemporaryAlternateAccommodation,
      "Type": type,
      "Tenure": tenure,
      "Amount": amount,
      "UnitSqFtLumsum": unitSqFtLumsum,
      "CarpetAreaSqFt": carpetAreaSqFt,
      "TemporaryAlternateAccommodationStartDate":
          temporaryAlternateAccommodationStartDate?.toIso8601String(),
      "TemporaryAlternateAccommodationEndDate":
          temporaryAlternateAccommodationEndDate?.toIso8601String(),
      "IsPayBrokerage": isPayBrokerage,
      "IsPayTAA": isPayTAA,
    };

    final result = await _proposedOfferRepository
        .addUpdateTemporaryAccommodationAlternativeDetails(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final list = [
          response['data'][0] as TemporaryAlternativeAccommodationDetailsModel,
          ...state.temporaryAccommodationAlternativeDetails,
        ];

        emit(
          state.copyWith(
            isLoading: false,
            temporaryAccommodationAlternativeDetails: list,
            totalNumberOfRecordTemporaryAccommodationAlternative:
                state.totalNumberOfRecordTemporaryAccommodationAlternative == -1
                    ? 1
                    : state.totalNumberOfRecordTemporaryAccommodationAlternative +
                        1,
          ),
        );

        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // UPDATE RENT DETAILS
  Future<void> updateTemporaryAccommodationAlternativeDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int proposedOfferTemporaryAccommodationAlternativeDetailsId,
    required bool isAdditionalTemporaryAlternateAccommodation,
    required String uniqueKey,
    required String type,
    required String tenure,
    required double amount,
    required String unitSqFtLumsum,
    required double carpetAreaSqFt,
    required DateTime? temporaryAlternateAccommodationStartDate,
    required DateTime? temporaryAlternateAccommodationEndDate,
    required bool isPayBrokerage,
    required int index,
    required bool isPayTAA,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, dynamic> body = {
      "ProposedOfferTemporaryAlternateAccommodationDetailsId":
          proposedOfferTemporaryAccommodationAlternativeDetailsId,
      "Uniquekey": uniqueKey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "IsAdditionalTemporaryAlternateAccommodation":
          isAdditionalTemporaryAlternateAccommodation,
      "Type": type,
      "Tenure": tenure,
      "Amount": amount,
      "UnitSqFtLumsum": unitSqFtLumsum,
      "CarpetAreaSqFt": carpetAreaSqFt,
      "TemporaryAlternateAccommodationStartDate":
          temporaryAlternateAccommodationStartDate?.toIso8601String(),
      "TemporaryAlternateAccommodationEndDate":
          temporaryAlternateAccommodationEndDate?.toIso8601String(),
      "IsPayBrokerage": isPayBrokerage,
      "IsPayTAA": isPayTAA,
    };

    final result = await _proposedOfferRepository
        .addUpdateTemporaryAccommodationAlternativeDetails(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedList =
            List<TemporaryAlternativeAccommodationDetailsModel>.from(
              state.temporaryAccommodationAlternativeDetails,
            );

        updatedList[index] =
            response['data'][0]
                as TemporaryAlternativeAccommodationDetailsModel;

        emit(
          state.copyWith(
            isLoading: false,
            temporaryAccommodationAlternativeDetails: updatedList,
          ),
        );
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // DELETE RENT DETAILS
  Future deleteRentDetails({
    required BuildContext context,
    required int proposedOfferTemporaryAccommodationAlternativeDetailsId,
    required int projectId,
    required int buildingId,
    required String uniqueKey,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _proposedOfferRepository.deleteRentDetails(
      projectId: projectId,
      buildingId: buildingId,
      proposedOfferTemporaryAccommodationAlternativeDetailsId:
          proposedOfferTemporaryAccommodationAlternativeDetailsId,
      uniquekey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedList =
            List<TemporaryAlternativeAccommodationDetailsModel>.from(
              state.temporaryAccommodationAlternativeDetails,
            );
        updatedList.removeAt(index!);

        emit(
          state.copyWith(temporaryAccommodationAlternativeDetails: updatedList),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future<void> generateProposedOffer(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required String chargeType,
    bool? isAdditionalTemporaryAlternateAccommodation,
    String? tenure,
    bool? isPayBrokerage,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "BuildingId": buildingId,
      "ProjectId": projectId,
      if (isAdditionalTemporaryAlternateAccommodation != null)
        "IsAdditionalTemporaryAccommodationAlternative":
            isAdditionalTemporaryAlternateAccommodation,
      if (isPayBrokerage != null) "IsPayBrokerage": isPayBrokerage,
      "ChargeType": chargeType,
      if (tenure != null) "Tenure": tenure,
    };

    final result = await _proposedOfferRepository
        .addUpdateGenerateProposedOffer(body: body);

    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL READY RECKONER RATE DETAILS DETAILS
  Future pullReadyReckonerRateDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _proposedOfferRepository.pullReadyReckonerRateDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            readyReckonerRateDetails:
                response['data'] as List<ReadyReckonerRateDetailsModel>,
          ),
        );
      },
    );
  }

  Future<void> addReadyReckonerRateDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required String financialYear,
    required String residentialRate,
    required String commercialRate,
    required String industrialRate,
    required String shopRate,
    required String landRate,
    required DateTime effectiveStartDate,
    required DateTime effectiveEndDate,
    required String remark,
    required String zone,
    required String subZone,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> body = {
      "ProposedOfferReadyReckonerRateDetailsId": 0,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "FinancialYear": financialYear,
      "ResidentialRate": residentialRate,
      "CommercialRate": commercialRate,
      "IndustrialRate": industrialRate,
      "ShopRate": shopRate,
      "LandRate": landRate,
      "EffectiveStartDate":
          effectiveStartDate.toIso8601String().split('T').first,
      "EffectiveEndDate": effectiveEndDate.toIso8601String().split('T').first,
      "Remark": remark,
      "Zone": zone,
      "SubZone": subZone,
    };

    final result = await _proposedOfferRepository
        .addUpdateReadyReckonerRateDetails(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final list = [
          (response['data'] as List<ReadyReckonerRateDetailsModel>)[0],
          ...state.readyReckonerRateDetails,
        ];

        emit(state.copyWith(isLoading: false, readyReckonerRateDetails: list));

        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future<void> updateReadyReckonerRateDetails(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int proposedOfferReadyReckonerRateDetailsId,
    required String uniqueKey,
    required String financialYear,
    required String residentialRate,
    required String commercialRate,
    required String industrialRate,
    required String shopRate,
    required String landRate,
    required DateTime effectiveStartDate,
    required DateTime effectiveEndDate,
    required String remark,
    required String zone,
    required String subZone,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> body = {
      "ProposedOfferReadyReckonerRateDetailsId":
          proposedOfferReadyReckonerRateDetailsId,
      "Uniquekey": uniqueKey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "FinancialYear": financialYear,
      "ResidentialRate": residentialRate,
      "CommercialRate": commercialRate,
      "IndustrialRate": industrialRate,
      "ShopRate": shopRate,
      "LandRate": landRate,
      "EffectiveStartDate":
          effectiveStartDate.toIso8601String().split('T').first,
      "EffectiveEndDate": effectiveEndDate.toIso8601String().split('T').first,
      "Remark": remark,
      "Zone": zone,
      "SubZone": subZone,
    };

    final result = await _proposedOfferRepository
        .addUpdateReadyReckonerRateDetails(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedList = List<ReadyReckonerRateDetailsModel>.from(
          state.readyReckonerRateDetails,
        );

        updatedList[index] =
            (response['data'] as List<ReadyReckonerRateDetailsModel>)[0];

        emit(
          state.copyWith(
            isLoading: false,
            readyReckonerRateDetails: updatedList,
          ),
        );

        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteReadyReckonerRateDetails({
    required BuildContext context,
    required int proposedOfferReadyReckonerRateDetailsId,
    required int projectId,
    required int buildingId,
    required String uniqueKey,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _proposedOfferRepository
        .deleteReadyReckonerRateDetails(
          projectId: projectId,
          buildingId: buildingId,
          proposedOfferReadyReckonerRateDetailsId:
              proposedOfferReadyReckonerRateDetailsId,
          uniquekey: uniqueKey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedList = List<ReadyReckonerRateDetailsModel>.from(
          state.readyReckonerRateDetails,
        );
        updatedList.removeAt(index!);

        emit(state.copyWith(readyReckonerRateDetails: updatedList));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL CARPET PLOT DETAILS
  Future pullCarpetPlotDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _buildingRepository.pullBuildingDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            carpetPlotDetails: response['data'][0] as BuildingDetailsModel,
          ),
        );
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL ADDITIONAL INFORMARION DETAILS
  Future pullAdditionalInformationDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _proposedOfferRepository
        .pullAdditionalInformationDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            additionalInformationDetails:
                response['data'].isEmpty
                    ? null
                    : response['data'][0] as AdditionalInformationDetailsModel,
          ),
        );
      },
    );
  }

  Future<void> addUpdateAdditionalInformation(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int proposedOfferAdditionalInformationId,
    required String uniqueKey,
    required String additionalRemark,
    required String purchaseOfAdditionalAreaRemark,
    required String taxAndDutiesDetails,
    required String taxRemark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> body = {
      "ProposedOfferAdditionalInformationId":
          proposedOfferAdditionalInformationId,
      "Uniquekey": uniqueKey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "AdditionalRemark": additionalRemark,
      "PurchaseOfAdditonalAreaRemark": purchaseOfAdditionalAreaRemark,
      "TaxAndDutiesDetails": taxAndDutiesDetails,
      "TaxRemark": taxRemark,
    };

    final result = await _proposedOfferRepository
        .addUpdateAdditionalInformationDetails(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            additionalInformationDetails:
                (response['data']
                    as List<AdditionalInformationDetailsModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // < ---------------------------------------------------------------------------------------------------------- >

  // PULL BANK GUARANTEE DETAILS
  Future pullBankGuaranteeDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true, clearBankGuaranteeDetails: true));

    final result = await _proposedOfferRepository.pullBankGuaranteeDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            bankGuaranteeDetails:
                response['data'].isEmpty
                    ? null
                    : response['data'][0] as BankGuaranteeDetailsModel,
          ),
        );
      },
    );
  }

  Future<void> addUpdateBankGuarantee(
    BuildContext context, {
    required int buildingId,
    required int projectId,
    required int proposedOfferBankGuaranteeDetailsId,
    required String uniqueKey,
    required double bankGuaranteeAmount,
    required List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
    proposedOfferBankGuaranteeDetailsWithPaymentStageData,
    required String accountHolderName,
    required String remark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> body = {
      "ProposedOfferBankGuaranteeDetailsId":
          proposedOfferBankGuaranteeDetailsId,
      if (uniqueKey.isNotEmpty) "Uniquekey": uniqueKey,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "BankGuaranteeAmount": bankGuaranteeAmount,
      "AccountHolderName": accountHolderName,
      "Remark": remark,
      "BankGuaranteePaymentStageJSON": jsonEncode(
        proposedOfferBankGuaranteeDetailsWithPaymentStageData
            .map((p) => p.bankGuaranteePaymentStageJSONPayload())
            .toList(),
      ),
    };

    final result = await _proposedOfferRepository.addUpdateBankGuaranteeDetails(
      body: body,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            bankGuaranteeDetails:
                (response['data'] as List<BankGuaranteeDetailsModel>)[0],
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteBankGuaranteeDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _proposedOfferRepository
        .deleteBankGuaranteeDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        emit(
          state.copyWith(
            bankGuaranteeDetails: null,
            clearBankGuaranteeDetails: true,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // EXPORT EXCEL PDF
  Future exportExcelPdf(
    BuildContext context, {
    required int buildingId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _proposedOfferRepository.pullProposedOfferPDF(
      projectId: projectId,
      buildingId: buildingId,
      queryParams: {"ExportType": 'PDF'},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(
          context,
          'Error',
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
      },
      (response) {
        showSuccessMessage(context, subTitle: 'Successfully Exported as PDF');
        exportExcelOrPdfMobile(
          response["data"],
          "Proposed Offer ${DateTime.now()}.pdf",
        );
      },
    );
  }
}
