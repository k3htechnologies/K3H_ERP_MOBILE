import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/repository/proposed_plans.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'proposed_plans_state.dart';

class ProposedPlansCubit extends Cubit<ProposedPlansState> {
  ProposedPlansCubit() : super(ProposedPlansState.initial());

  // REPOSITORIES
  final ProposedPlansRepository _proposedPlansRepository =
      serviceLocator<ProposedPlansRepository>();

  // GET PROPOSED PLANS LIST
  Future getDepartmentList(BuildContext context, int projectId) async {
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
        final List<ProposedPlansModel> list = List<ProposedPlansModel>.from(
          response['data'] ?? [],
        );

        emit(state.copyWith(proposedPlansList: list, isLoading: false));
      },
    );
  }

  // ADD OR UPDATE PROPOSED PLANS
  Future<void> addProposedPlans({
    required BuildContext context,
    required String projectId,
    required String totalNumberOfFloors,
    required String totalUnits,
    required String totalParking,
    required String amenities,
    required MultiFilePickerModel planFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "ProposedOfferProposedPlanId": "0",
      "ProjectId": projectId,
      "TotalNumberOfFloors": totalNumberOfFloors,
      "TotalUnits": totalUnits,
      "TotalParking": totalParking,
      "Amenities": amenities,
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

    var addResult = await _proposedPlansRepository.addUpdateProposedPlans(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<ProposedPlansModel> list = List<ProposedPlansModel>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(isLoading: false, proposedPlansList: list));
        showSuccessMessage(
          context,
          subTitle: "Proposed plans added successfully",
        );
      },
    );
  }

  // UPDATE PROPOSED PLANS
  Future<void> updateProposedPlans({
    required BuildContext context,
    required String proposedOfferProposedPlanId,
    required String uniquekey,
    required String projectId,
    required String totalNumberOfFloors,
    required String totalUnits,
    required String totalParking,
    required String amenities,
    required MultiFilePickerModel planFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
      "Uniquekey": uniquekey,
      "ProjectId": projectId,
      "TotalNumberOfFloors": totalNumberOfFloors,
      "TotalUnits": totalUnits,
      "TotalParking": totalParking,
      "Amenities": amenities,
      "RemovePlanDocumentURL": planFile.deletedFileList,
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

    var addResult = await _proposedPlansRepository.addUpdateProposedPlans(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<ProposedPlansModel> list = List<ProposedPlansModel>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(isLoading: false, proposedPlansList: list));
        showSuccessMessage(
          context,
          subTitle: "Proposed plans updated successfully",
        );
      },
    );
  }

  // ON TAB CHANGE
  void onTabChanged(int index, BuildContext context, projectId) {
    // PROJECT CHANGED
    if (state.currentProjectId != projectId) {
      emit(state.copyWith(currentProjectId: projectId, proposedPlansList: []));

      getDepartmentList(context, projectId);
      return;
    }

    emit(state.copyWith(currentTabIndex: index));
    // IF TAB IS DETAILS
    if (index == 0) {
      getDepartmentList(context, projectId);
    }
  }
}
