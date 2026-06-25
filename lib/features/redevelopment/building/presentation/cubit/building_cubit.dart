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

  // <---- ON TAB CHANGED ---->
  void onTabChanged(
    int index,
    BuildContext context,
    int projectId,
    int buildingId,
  ) {
    if (isClosed) return;
    emit(state.copyWith(currentTabIndex: index));

    if (index == 1) {
      // DETAILS TAB
      getBuildingDetails(
        context: context,
        buildingId: buildingId,
        projectId: projectId,
      );
    } else if (index == 2) {
      getBuildingDocumentList(context, projectId, buildingId, 1, 100, null);
    }
  }

  // <---- SEARCH BUILDING ---->
  Future searchBuilding(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, buildingList: [], currentPage: 1));
    await getBuildingList(context, 1, projectId);
  }

  // APPLY FILTER AND SORT
  Future applyFilterAndSort({
    required BuildContext context,
    required int projectId,
    required String filterBuildingName,
    required String filterCTSNumber,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        searchText: filterBuildingName,
        filterCTSNumber: filterCTSNumber,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        buildingList: [],
        currentPage: 1,
      ),
    );

    await getBuildingList(context, 1, projectId);
  }

  // <---- GET ASSET LIST ---->
  Future getBuildingList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    final queryParams = {
      "BuildingName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "CTSNumber": state.filterCTSNumber,
    };

    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final newData = List<RedevelopmentBuildingModel>.from(
          response['data'] as List<RedevelopmentBuildingModel>,
        );

        final List<RedevelopmentBuildingModel> updatedList =
            pageNumber == 1 ? newData : [...state.buildingList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            buildingList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
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
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
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
    int? buildingDocumentId,
  ) async {
    final bool isParentRequest =
        buildingDocumentId == null || buildingDocumentId == 0;
    if (isParentRequest) {
      emit(state.copyWith(isLoading: true));
    }

    final queryParameter = {
      "IsCheckPermission": true,
      "BuildingDocumentId": buildingDocumentId ?? 0,
    };

    final result = await _buildingRepository.pullBuildingDocument(
      pageNumber: pageNumber,
      pageSize: pageSize,
      buildingId: buildingId,
      projectId: projectId,
      queryParams: queryParameter,
    );

    result.fold(
      (failure) {
        if (isParentRequest) {
          emit(state.copyWith(isLoading: false));
        }
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<BuildingDocumentModel> newList =
            pageNumber == 1
                ? List<BuildingDocumentModel>.from(response['data'])
                : [...state.buildingDocumentList, ...response['data']];

        emit(
          state.copyWith(
            isLoading: isParentRequest ? false : state.isLoading,
            buildingDocumentList: newList,
            currentPageDocument: pageNumber,
            totalNumberOfRecordDocument: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  /// <---- GET CHILD BUILDING DOCUMENTS (NO STATE MUTATION) ---->
  Future<List<BuildingDocumentModel>> getBuildingChildDocuments(
    BuildContext context,
    int projectId,
    int buildingId,
    int parentBuildingDocumentId,
  ) async {
    final queryParameter = {
      "IsCheckPermission": true,
      "BuildingDocumentId": parentBuildingDocumentId,
    };

    final result = await _buildingRepository.pullBuildingDocument(
      pageNumber: 1,
      pageSize: 100,
      buildingId: buildingId,
      projectId: projectId,
      queryParams: queryParameter,
    );

    return result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return <BuildingDocumentModel>[];
      },
      (response) {
        return List<BuildingDocumentModel>.from(
          response['data'] as List<BuildingDocumentModel>,
        );
      },
    );
  }

  // <---- ADD BUILDING DOCUMENT ---->
  Future addBuildingDocument({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required String documentName,
    required MultiFilePickerModel files,
  }) async {
    if (isClosed) return;

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

    DialogHelper.showProcessingOverlay(context);

    final body = <String, String>{
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
      "IsMaster": "1",
    };

    var addResult = await _buildingRepository.addUpdateBuildingDocument(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: "Document Added Successfully");
        await getBuildingDocumentList(
          context,
          projectId,
          buildingId,
          1,
          100,
          null,
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

    final isAddMode = buildingDocumentId == 0 || buildingDocumentId == -1;

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

    updateResult.fold(
      (failure) {
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: "Upload Successfully");
        await getBuildingDocumentList(
          context,
          projectId,
          buildingId,
          1,
          100,
          null,
        );
      },
    );
  }

  // <---- ADD BUILDING ---->
  Future addBuilding(
    BuildContext context,
    int projectId,
    Map<String, dynamic> buildingData,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.addUpdateBuilding(
      requestBody: buildingData,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
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
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.addUpdateBuilding(
      requestBody: buildingData,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final updatedBuilding =
            response['data'][0] as RedevelopmentBuildingModel;

        if (state.buildingList.isNotEmpty &&
            index < state.buildingList.length) {
          final updatedList = List<RedevelopmentBuildingModel>.from(
            state.buildingList,
          );
          updatedList[index] = updatedBuilding;

          emit(state.copyWith(buildingList: updatedList));
        }

        showSuccessMessage(context, subTitle: 'Building Updated Successfully');
      },
    );
  }

  // <---- DELETE BUILDING ---->
  Future deleteBuilding(
    int projectId,
    RedevelopmentBuildingModel buildingModel,
    BuildContext context,
    int? index,
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
        if (index != null) {
          final updatedList = List<RedevelopmentBuildingModel>.from(
            state.buildingList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              buildingList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getBuildingList(context, state.currentPage, projectId);
        }
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "building_${DateTime.now()}.pdf"
              : "building_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // <---- UPDATE BUILDING DETAILS ---->
  Future<void> updateBuildingDetails({
    required BuildContext context,
    required Map<String, dynamic> buildingDetailsData,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _buildingRepository.addUpdateBuildingDetails(
      requestBody: buildingDetailsData,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Building Details Updated Successfully',
        );
        if (buildingDetailsData['BuildingId'] != null) {
          getBuildingDetails(
            context: context,
            buildingId: buildingDetailsData['BuildingId'] as int,
            projectId: buildingDetailsData['ProjectId'] as int,
          );
        }
      },
    );
  }

  int updateFilterCount(BuildingState state) {
    final hasSort =
        state.currentSortColumn == "Building Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.isNotEmpty,
      state.filterCTSNumber.isNotEmpty,
      hasSort,
    ]);
  }
}
