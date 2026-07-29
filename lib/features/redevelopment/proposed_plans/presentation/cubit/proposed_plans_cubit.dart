import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/repository/proposed_plans.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_state.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/building_form_model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class ProposedPlansCubit extends Cubit<ProposedPlansState> {
  ProposedPlansCubit() : super(ProposedPlansState.initial());

  // REPOSITORIES
  final ProposedPlansRepository _proposedPlansRepository =
      serviceLocator<ProposedPlansRepository>();

  // GET PROPOSED PLANS LIST
  Future getProposedPlanList(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }

    var result = await _proposedPlansRepository.getProposedPlanList(
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ProposedPlanBuilding> list = List<ProposedPlanBuilding>.from(
          response['data'] ?? [],
        );

        emit(
          state.copyWith(
            proposedPlansList: list,
            isLoading: false,
            buildingForm:
                list.isEmpty
                    ? null
                    : list.first.buildingProposedPlanData.isEmpty
                    ? null
                    : BuildingFormDataModel.fromModel(
                      list.first.buildingProposedPlanData.first,
                    ),
            currentBuildingDetailTabIndex: 0,
            currentBuildingIndex: 0,
          ),
        );
      },
    );
  }

  // ON TAB CHANGE
  void onTabChanged(int index) {
    emit(state.copyWith(currentBuildingDetailTabIndex: index));
  }

  Future<void> addUpdateBuildingProposedPlan({
    required BuildContext context,
    required int projectId,
    required int proposedOfferProposedPlanId,
    required int totalNumberOfBuilding,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = {
      "ProjectId": projectId,
      "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
      "TotalNumberOfBuilding": totalNumberOfBuilding,
      if (proposedOfferProposedPlanId != 0) "Uniquekey": uniquekey,
    };

    final result = await _proposedPlansRepository.addUpdateProposedPlan(
      body: body,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<ProposedPlanBuilding> list = List<ProposedPlanBuilding>.from(
          response['data'] ?? [],
        );

        emit(state.copyWith(isLoading: false, proposedPlansList: list));

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  void changeBuildingTab(int index) {
    emit(state.copyWith(currentBuildingIndex: index));
  }

  Future<void> addUpdateProposedPlans({
    required BuildContext context,
    required int projectId,
    required int proposedOfferProposedPlanId,
    required int buildingProposedPlanId,
    required String uniquekey,
    required int totalNumberOfWing,
    required int totalPodium,
    required int totalUnits,
    required int totalParking,
    required List<WingProposedPlanDataModel> wingProposedPlanJSON,
    required String amenities,
    required MultiFilePickerModel planFile,
    required MultiFilePickerModel threeDViewFile,
    required MultiFilePickerModel salesPlanFile,
    required MultiFilePickerModel walkthroughViewFile,
    required int salesResidentialParking,
    required int salesCommercialParking,
    required int salesVisitorsParking,
    required int memberResidentialParking,
    required int memberCommercialParking,
    required int memberVisitorsParking,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, String> body = {
      "ProjectId": projectId.toString(),
      "ProposedOfferProposedPlanId": proposedOfferProposedPlanId.toString(),
      "BuildingProposedPlanId": buildingProposedPlanId.toString(),
      "Uniquekey": uniquekey,

      "TotalNumberOfWing": totalNumberOfWing.toString(),

      "TotalPodium": totalPodium.toString(),

      "TotalUnits": totalUnits.toString(),

      "TotalParking": totalParking.toString(),

      "WingProposedPlanJSON": jsonEncode(
        wingProposedPlanJSON.map((e) => e.toJson()).toList(),
      ),

      "Amenities": amenities,

      "RemovePlanDocumentURL": planFile.deletedFileList,
      "RemoveThreeDViewURL": threeDViewFile.deletedFileList,
      "RemoveSalesPlanURL": salesPlanFile.deletedFileList,
      "RemoveWalkthroughViewURL": salesPlanFile.deletedFileList,
      "SalesResidentialParking": salesResidentialParking.toString(),
      "SalesCommercialParking": salesCommercialParking.toString(),
      "SalesVisitorsParking": salesVisitorsParking.toString(),
      "MemberResidentialParking": memberResidentialParking.toString(),
      "MemberCommercialParking": memberCommercialParking.toString(),
      "MemberVisitorsParking": memberVisitorsParking.toString(),
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < planFile.fileNameList.length; i++) {
      if (planFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "PlanDocumentURL",
        "value": planFile.fileBytesList[i],
        "fileName": planFile.fileNameList[i],
      });
    }

    for (int i = 0; i < threeDViewFile.fileNameList.length; i++) {
      if (threeDViewFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "ThreeDViewURL",
        "value": threeDViewFile.fileBytesList[i],
        "fileName": threeDViewFile.fileNameList[i],
      });
    }
    for (int i = 0; i < salesPlanFile.fileNameList.length; i++) {
      if (salesPlanFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "SalesPlanURL",
        "value": salesPlanFile.fileBytesList[i],
        "fileName": salesPlanFile.fileNameList[i],
      });
    }

    for (int i = 0; i < walkthroughViewFile.fileNameList.length; i++) {
      if (walkthroughViewFile.fileNameList[i].contains("http")) {
        continue;
      }

      fileList.add({
        "key": "WalkthroughViewURL",
        "value": walkthroughViewFile.fileBytesList[i],
        "fileName": walkthroughViewFile.fileNameList[i],
      });
    }
    final result = await _proposedPlansRepository.addUpdateBuildingProposedPlan(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<ProposedPlanBuilding> list = List<ProposedPlanBuilding>.from(
          response['data'] ?? [],
        );

        emit(state.copyWith(isLoading: false, proposedPlansList: list));

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  void updateBuildingForm(BuildingFormDataModel formData) {
    emit(state.copyWith(buildingForm: formData));
  }

  Future<void> copyBuildingProposedPlan({
    required BuildContext context,
    required int projectId,
    required int proposedOfferProposedPlanId,
    required int sourceBuildingProposedPlanId,
    required String copyBuildingProposedPlanId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = {
      "ProjectId": projectId,
      "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
      "SourceBuildingProposedPlanId": sourceBuildingProposedPlanId,
      "CopyBuildingProposedPlanId": copyBuildingProposedPlanId,
    };

    final result = await _proposedPlansRepository.copyProposedPlan(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<ProposedPlanBuilding> list = List<ProposedPlanBuilding>.from(
          response['data'] ?? [],
        );
        goRouter.pop();

        emit(state.copyWith(isLoading: false, proposedPlansList: list));

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }
}
