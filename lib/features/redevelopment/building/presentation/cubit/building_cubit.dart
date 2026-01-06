import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'building_state.dart';

class BuildingCubit extends Cubit<BuildingState> {
  BuildingCubit() : super(BuildingState.initial());

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // <---- SEARCH BUILDING ---->
  Future searchBuilding(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    if (isClosed) return;
    emit(state.copyWith(searchText: value, buildingList: [], currentPage: 1));
    await getBuildingList(context, 1, 10, projectId);
  }

  // <---- GET ASSET LIST ---->
  Future getBuildingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));

    final queryParams = {
      "BuildingName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      queryParams: queryParams,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        if (isClosed) return;
        final List<RedevelopmentBuildingModel> newData =
            List<RedevelopmentBuildingModel>.from(response['data'] ?? []);

        final List<RedevelopmentBuildingModel> updatedList =
            pageNumber == 1 ? newData : [...state.buildingList, ...newData];

        emit(
          state.copyWith(
            buildingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET BUILDING DETAILS ---->
  Future<void> getBuildingDetails({
    required BuildContext context,
    required int buildingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _buildingRepository.pullBuildingDetails(
      buildingId: buildingId,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        if (isClosed) return;
        final buildingDetailsList =
            response['data'] as List<BuildingDetailsModel>;
        if (buildingDetailsList.isNotEmpty) {
          emit(
            state.copyWith(
              isLoading: false,
              buildingDetails: buildingDetailsList.first,
            ),
          );
        } else {
          emit(state.copyWith(isLoading: false, buildingDetails: null));
          showErrorMessage(context, 'Error', 'No Data Found');
        }
      },
    );
  }

  // <---- GET BUILDING DOCUMENT LIST ---->
  Future getBuildingDocumentList(
    BuildContext context,
    int projectId,
    int buildingId,
    int pageNumber,
    int pageSize,
  ) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));

    var queryParameter = {
      "IsCheckPermission":true
    };

    final result = await _buildingRepository.pullBuildingDocument(
      pageNumber: pageNumber,
      pageSize: pageSize,
      buildingId: buildingId,
      projectId: projectId,
      queryParams: queryParameter
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        if (isClosed) return;
        List<BuildingDocumentModel> newList =
            pageNumber == 1
                ? List<BuildingDocumentModel>.from(response['data'])
                : [...state.buildingDocumentList, ...response['data']];

        emit(
          state.copyWith(
            isLoading: false,
            buildingDocumentList: newList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  // <---- ADD/UPDATE BUILDING DOCUMENT ---->
  Future updateBuildingDocument({
    required BuildContext context,
    required int buildingDocumentId,
    required String uniqueKey,
    required int projectId,
    required int buildingId,
    required String documentName,
    required MultiFilePickerModel files,
  }) async {
    if (isClosed) return;

    // For new documents, use 0 for BuildingDocumentId and empty string for UniqueKey
    final isAddMode = buildingDocumentId == 0 || buildingDocumentId == -1;

    // Prepare file list (exclude URLs that are already uploaded)
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < files.fileNameList.length; i++) {
      if (files.fileNameList[i].contains("http")) {
        continue;
      }
      if (i < files.fileBytesList.length && files.fileBytesList[i].isNotEmpty) {
        fileList.add({
          "key": "DocumentURL",
          "value": files.fileBytesList[i],
          "fileName": files.fileNameList[i],
        });
      }
    }

    // For add mode, ensure we have files to upload
    if (isAddMode && fileList.isEmpty && files.deletedFileList.isEmpty) {
      showErrorMessage(
        context,
        'Error',
        'Please select at least one file to upload',
      );
      return;
    }

    DialogHelper.showProcessingOverlay(context);

    final body = <String, String>{
      'BuildingDocumentId': isAddMode ? '0' : buildingDocumentId.toString(),
      'Uniquekey': isAddMode ? '' : uniqueKey,
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
      'RemoveDocumentURL': files.deletedFileList,
    };

    var updateResult = await _buildingRepository.addUpdateBuildingDocument(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();

    if (isClosed) return;

    updateResult.fold(
      (failure) {
        if (isClosed) return;
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        if (isClosed) return;
        showSuccessMessage(context, subTitle: response["successMessage"]);
        await getBuildingDocumentList(context, projectId, buildingId, 1, 100);
      },
    );
  }

  // <---- ADD BUILDING ---->
  Future addBuilding(
    BuildContext context,
    int projectId,
    Map<String, dynamic> buildingData,
  ) async {
    if (isClosed) return;
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.addUpdateBuilding(
      requestBody: buildingData,
    );

    goRouter.pop();

    if (isClosed) return;

    result.fold(
      (failure) {
        if (isClosed) return;
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        if (isClosed) return;
        goRouter.pop();

        final newBuilding = response['data'][0] as RedevelopmentBuildingModel;
        emit(
          state.copyWith(
            buildingList: [newBuilding, ...state.buildingList],
            totalNumberOfRecord: state.totalNumberOfRecord + 1,
          ),
        );

        showSuccessMessage(context, subTitle: 'Building Added Successfully');
      },
    );
  }

  // <---- UPDATE BUILDING ---->
  Future updateBuilding(
    BuildContext context,
    int projectId,
    int index,
    Map<String, dynamic> buildingData,
  ) async {
    if (isClosed) return;
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.addUpdateBuilding(
      requestBody: buildingData,
    );

    goRouter.pop();

    if (isClosed) return;

    result.fold(
      (failure) {
        if (isClosed) return;
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        if (isClosed) return;
        goRouter.pop();

        if (index < state.buildingList.length) {
          final updatedList = List<RedevelopmentBuildingModel>.from(
            state.buildingList,
          );
          updatedList[index] =
              response['data'][0] as RedevelopmentBuildingModel;

          emit(state.copyWith(buildingList: updatedList));
        }

        showSuccessMessage(context, subTitle: 'Building Updated Successfully');
      },
    );
  }

  // <---- DELETE ASSET ---->
  Future deleteBuilding(
    int projectId,
    RedevelopmentBuildingModel buildingModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.deleteBuilding(
      buildingId: buildingModel.buildingId,
      uniqueKey: buildingModel.uniquekey,
      projectId: projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(context, subTitle: "Building Deleted Successfully");

        getBuildingList(context, state.currentPage, 10, projectId);
      },
    );
  }

  // <---- EXPORT ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.pullBuildingForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams: {"ExportType": exportType, "BuildingName": state.searchText},
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "asset_${DateTime.now()}.pdf"
              : "asset_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void onTabChanged(
    int index,
    BuildContext context,
    int projectId,
    int buildingId,
  ) {
    if (isClosed) return;
    emit(state.copyWith(currentTabIndex: index));

    if (index == 1) {
      // Details tab
      getBuildingDetails(
        context: context,
        buildingId: buildingId,
        projectId: projectId,
      );
    } else if (index == 2) {
      // Document tab
      getBuildingDocumentList(context, projectId, buildingId, 1, 100);
    }
  }
}
