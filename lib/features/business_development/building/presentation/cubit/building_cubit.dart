import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
part 'building_state.dart';

class BuildingCubit extends Cubit<BuildingState> {
  BuildingCubit() : super(BuildingState.initial());
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();
  void onTabChanged(
    int index,
    BuildContext context,
    int projectId,
    int buildingId,
  ) {
    if (isClosed) return;
    emit(state.copyWith(currentTabIndex: index, documentSearchText: ''));
    if (index == 1) {
      getBuildingDetails(
        context: context,
        buildingId: buildingId,
        projectId: projectId,
      );
    } else if (index == 2) {
      getBuildingDocumentList(
        context: context,
        projectId: projectId,
        buildingId: buildingId,
        pageNumber: 1,
      );
    }
  }

  Future searchBuilding(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(state.copyWith(searchText: value, buildingList: [], currentPage: 1));
    await getBuildingList(context, 1, projectId);
  }

  Future searchDocument({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required String value,
  }) async {
    emit(
      state.copyWith(
        documentSearchText: value,
        buildingDocumentList: [],
        currentPageDocument: 1,
      ),
    );
    await await getBuildingDocumentList(
      context: context,
      projectId: projectId,
      buildingId: buildingId,
      pageNumber: 1,
    );
  }

  Future applyFilterAndSort({
    required BuildContext context,
    required int projectId,
    required String filterBuildingName,
    required String filterCTSNumber,
    required String filterRoadWidth,
    required String filterCity,
    required String filterVillage,
    required String filterWard,
    required String filterCategory,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        searchText: filterBuildingName,
        filterCTSNumber: filterCTSNumber,
        filterRoadWidth: filterRoadWidth,
        filterCity: filterCity,
        filterVillage: filterVillage,
        filterWard: filterWard,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        filterCategory: filterCategory,
        buildingList: [],
        currentPage: 1,
      ),
    );
    await getBuildingList(context, 1, projectId);
  }

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
      "RoadWidth": state.filterRoadWidth,
      "CityName": state.filterCity,
      "VillageName": state.filterVillage,
      "WardName": state.filterWard,
      "Category": state.filterCategory,
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
        final newData = List<BusinessDevelopmentBuildingModel>.from(
          response['data'] as List<BusinessDevelopmentBuildingModel>,
        );
        final List<BusinessDevelopmentBuildingModel> updatedList =
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

  Future<void> getBuildingDetails({
    required BuildContext context,
    required int buildingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(
      state.copyWith(
        isLoading: true,
        buildingDocumentList: [],
        currentPageDocument: 1,
        totalNumberOfRecordDocument: 0,
        documentSearchText: '',
      ),
    );
    var result = await _buildingRepository.pullBuildingDetails(
      buildingId: buildingId,
      projectId: projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        goRouter.pop();
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
        goRouter.pop();
      },
    );
  }

  Future getBuildingDocumentList({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int pageNumber,
    int? buildingDocumentId,
  }) async {
    final bool isParentRequest =
        buildingDocumentId == null || buildingDocumentId == 0;
    if (isParentRequest) {
      emit(state.copyWith(isLoading: true));
    }
    final queryParameter = {
      "IsCheckPermission": true,
      "BuildingDocumentId": buildingDocumentId,
      "DocumentName": state.documentSearchText,
    };
    final result = await _buildingRepository.pullBuildingDocument(
      pageNumber: pageNumber,
      pageSize: 20,
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

  Future addBuildingParentDocument({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required String documentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
      "IsMaster": "1",
    };
    var addResult = await _buildingRepository.addUpdateBuildingDocument(
      body: body,
      fileList: [],
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        await getBuildingDocumentList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          pageNumber: 1,
        );
      },
    );
  }

  Future updateBuildingParentDocument({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required String documentName,
    required int buildingDocumentId,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
      "IsMaster": "1",
      "BuildingDocumentId": buildingDocumentId.toString(),
      "Uniquekey": uniquekey,
    };
    var addResult = await _buildingRepository.addUpdateBuildingDocument(
      body: body,
      fileList: [],
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        await getBuildingDocumentList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          pageNumber: 1,
        );
      },
    );
  }

  Future updateBuildingChildDocument({
    required BuildContext context,
    required int buildingDocumentId,
    required String uniqueKey,
    required int projectId,
    required int buildingId,
    required String documentName,
    required String documentRemark,
    required MultiFilePickerModel files,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < files.fileNameList.length; i++) {
      if (files.fileNameList[i].contains("http")) continue;
      fileList.add({
        "key": "DocumentURL",
        "value": files.fileBytesList[i],
        "fileName": files.fileNameList[i],
      });
    }
    DialogHelper.showProcessingOverlay(context);
    final body = <String, String>{
      'BuildingDocumentId': buildingDocumentId.toString(),
      'Uniquekey': uniqueKey,
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
      'RemoveDocumentURL': files.deletedFileList,
      'IsMaster': '0',
      'DocumentRemark': documentRemark,
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
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop(true);
        await await getBuildingDocumentList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          pageNumber: 1,
        );
      },
    );
  }

  Future addBuilding({
    required BuildContext context,
    required int projectId,
    required String buildingName,
    required String ctsNumber,
    required String roadWidth,
    required String landOwnershipType,
    required String googleLocation,
    required String category,
    required String tenderAmount,
    required String tenderPurchaseStartDate,
    required String tenderPurchaseEndDate,
    required String tenderAmountPaymentMode,
    required String tenderChequeNumber,
    required MultiFilePickerModel tenderChequeNumberFile,
    required String tenderPayorderRemark,
    required String tenderEMDAmount,
    required String tenderSubmissionDate,
    required MultiFilePickerModel tenderEmdChequeNumberFile,
    required String tenderEmdPaymentMode,
    required String tenderEmdChequeNumber,
    required String tenderEmdPayorderRemark,
    required double totalPlotAreaSqFt,
    required double totalPlotAreaSqMt,
    required double totalUnitsAreaUtilizedSqFt,
    required int totalNumberOfUnits,
    required int numberOfFloors,
    required int numberOfWings,
    required int propertyAgeYears,
    required double fsiTdrUtilizationSqFt,
    required bool isGarden,
    required double totalGardenAreaSqFt,
    required bool isReligiousStructure,
    required double totalReligiousStructureAreaSqFt,
    required String litigationRemarks,
    required bool isLitigation,
    required int countryMasterId,
    required int? districtMasterId,
    required int? stateMasterId,
    required int? cityMasterId,
    required int? villageMasterId,
    required int? wardMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> buildingData = {
      'BuildingId': 0.toString(),
      'ProjectId': projectId.toString(),
      'BuildingName': buildingName,
      'CTSNumber': ctsNumber,
      'GoogleLocation': googleLocation,
      "Category": category,
      "TenderAmount": tenderAmount,
      "TenderPurchaseStartDate": tenderPurchaseStartDate,
      "TenderPurchaseEndDate": tenderPurchaseEndDate,
      "TenderAmountPaymentMode": tenderAmountPaymentMode,
      "TenderAmountChequeNumber": tenderChequeNumber,
      "TenderAmountPayorderRemark": tenderPayorderRemark,
      "TenderEMDAmount": tenderEMDAmount,
      "TenderSubmissionDate": tenderSubmissionDate,
      "TenderEMDPaymentMode": tenderEmdPaymentMode,
      "TenderEMDChequeNumber": tenderEmdChequeNumber,
      "TenderEMDPayorderRemark": tenderEmdPayorderRemark,
      'TotalPlotAreaSqFt': totalPlotAreaSqFt.toString(),
      'TotalPlotAreaSqMt': totalPlotAreaSqMt.toString(),
      'RoadWidth': roadWidth,
      'CountryMasterId': countryMasterId.toString(),
      'DistrictMasterId': districtMasterId.toString(),
      'StateMasterId': stateMasterId.toString(),
      'CityMasterId': cityMasterId.toString(),
      'VillageMasterId': villageMasterId.toString(),
      'WardMasterId': wardMasterId.toString(),
      'TotalNumberOfUnits': totalNumberOfUnits.toString(),
      'NumberOfWings': numberOfWings.toString(),
      'TotalUnitsAreaUtilizedSqFt': totalUnitsAreaUtilizedSqFt.toString(),
      'IsGarden': isGarden.toString(),
      'TotalGardenAreaSqFt': totalGardenAreaSqFt.toString(),
      'IsReligiousStructure': isReligiousStructure.toString(),
      'TotalReligiousStructureAreaSqFt':
          totalReligiousStructureAreaSqFt.toString(),
      'PropertyAgeYears': propertyAgeYears.toString(),
      'NumberOfFloors': numberOfFloors.toString(),
      'FSI_TDR_UtilizationSqFt': fsiTdrUtilizationSqFt.toString(),
      'LandOwnershipType': landOwnershipType,
      'IsLitigation': isLitigation.toString(),
      'LitigationRemarks': litigationRemarks,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < tenderChequeNumberFile.fileBytesList.length; i++) {
      if (tenderChequeNumberFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TenderAmountChequeNumberURL",
        "value": tenderChequeNumberFile.fileBytesList[i],
        "fileName": tenderChequeNumberFile.fileNameList[i],
      });
    }
    for (int i = 0; i < tenderEmdChequeNumberFile.fileBytesList.length; i++) {
      if (tenderEmdChequeNumberFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TenderEMDChequeNumberURL",
        "value": tenderEmdChequeNumberFile.fileBytesList[i],
        "fileName": tenderEmdChequeNumberFile.fileNameList[i],
      });
    }
    final result = await _buildingRepository.addUpdateBuilding(
      body: buildingData,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getBuildingList(context, 1, projectId);
      },
    );
  }

  Future<void> updateBuilding({
    required int index,
    required int buildingId,
    required String uniqueKey,
    required BuildContext context,
    required int projectId,
    required String buildingName,
    required String ctsNumber,
    required String roadWidth,
    required String landOwnershipType,
    required String googleLocation,
    required String category,
    required String tenderAmount,
    required String tenderPurchaseStartDate,
    required String tenderPurchaseEndDate,
    required String tenderAmountPaymentMode,
    required String tenderChequeNumber,
    required MultiFilePickerModel tenderChequeNumberFile,
    required String tenderPayorderRemark,
    required String tenderEMDAmount,
    required String tenderSubmissionDate,
    required MultiFilePickerModel tenderEmdChequeNumberFile,
    required String tenderEmdPaymentMode,
    required String tenderEmdChequeNumber,
    required String tenderEmdPayorderRemark,
    required double totalPlotAreaSqFt,
    required double totalPlotAreaSqMt,
    required double totalUnitsAreaUtilizedSqFt,
    required int totalNumberOfUnits,
    required int numberOfFloors,
    required int numberOfWings,
    required int propertyAgeYears,
    required double fsiTdrUtilizationSqFt,
    required bool isGarden,
    required double totalGardenAreaSqFt,
    required bool isReligiousStructure,
    required double totalReligiousStructureAreaSqFt,
    required String litigationRemarks,
    required bool isLitigation,
    required int countryMasterId,
    required int? districtMasterId,
    required int? stateMasterId,
    required int? cityMasterId,
    required int? villageMasterId,
    required int? wardMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> buildingData = {
      'BuildingId': buildingId.toString(),
      'UniqueKey': uniqueKey,
      'ProjectId': projectId.toString(),
      'BuildingName': buildingName,
      'CTSNumber': ctsNumber,
      'GoogleLocation': googleLocation,
      "Category": category,
      "TenderAmount": tenderAmount,
      "TenderPurchaseStartDate": tenderPurchaseStartDate,
      "TenderPurchaseEndDate": tenderPurchaseEndDate,
      "TenderAmountPaymentMode": tenderAmountPaymentMode,
      "TenderAmountChequeNumber": tenderChequeNumber,
      "TenderAmountPayorderRemark": tenderPayorderRemark,
      "TenderEMDAmount": tenderEMDAmount,
      "TenderSubmissionDate": tenderSubmissionDate,
      "TenderEMDPaymentMode": tenderEmdPaymentMode,
      "TenderEMDChequeNumber": tenderEmdChequeNumber,
      "TenderEMDPayorderRemark": tenderEmdPayorderRemark,
      'TotalPlotAreaSqFt': totalPlotAreaSqFt.toString(),
      'TotalPlotAreaSqMt': totalPlotAreaSqMt.toString(),
      'RoadWidth': roadWidth,
      'CountryMasterId': countryMasterId.toString(),
      'DistrictMasterId': districtMasterId.toString(),
      'StateMasterId': stateMasterId.toString(),
      'CityMasterId': cityMasterId.toString(),
      'VillageMasterId': villageMasterId.toString(),
      'WardMasterId': wardMasterId.toString(),
      'TotalNumberOfUnits': totalNumberOfUnits.toString(),
      'NumberOfWings': numberOfWings.toString(),
      'TotalUnitsAreaUtilizedSqFt': totalUnitsAreaUtilizedSqFt.toString(),
      'IsGarden': isGarden.toString(),
      'TotalGardenAreaSqFt': totalGardenAreaSqFt.toString(),
      'IsReligiousStructure': isReligiousStructure.toString(),
      'TotalReligiousStructureAreaSqFt':
          totalReligiousStructureAreaSqFt.toString(),
      'PropertyAgeYears': propertyAgeYears.toString(),
      'NumberOfFloors': numberOfFloors.toString(),
      'FSI_TDR_UtilizationSqFt': fsiTdrUtilizationSqFt.toString(),
      'LandOwnershipType': landOwnershipType,
      'IsLitigation': isLitigation.toString(),
      'LitigationRemarks': litigationRemarks,
      "RemoveTenderAmountChequeNumberURL":
          tenderChequeNumberFile.deletedFileList,
      "RemoveTenderEMDChequeNumberURL":
          tenderEmdChequeNumberFile.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < tenderChequeNumberFile.fileBytesList.length; i++) {
      if (tenderChequeNumberFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TenderAmountChequeNumberURL",
        "value": tenderChequeNumberFile.fileBytesList[i],
        "fileName": tenderChequeNumberFile.fileNameList[i],
      });
    }
    for (int i = 0; i < tenderEmdChequeNumberFile.fileBytesList.length; i++) {
      if (tenderEmdChequeNumberFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TenderEMDChequeNumberURL",
        "value": tenderEmdChequeNumberFile.fileBytesList[i],
        "fileName": tenderEmdChequeNumberFile.fileNameList[i],
      });
    }
    final result = await _buildingRepository.addUpdateBuilding(
      body: buildingData,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        final updatedBuilding =
            response['data'][0] as BusinessDevelopmentBuildingModel;
        if (state.buildingList.isNotEmpty &&
            index < state.buildingList.length) {
          final updatedList = List<BusinessDevelopmentBuildingModel>.from(
            state.buildingList,
          );
          updatedList[index] = updatedBuilding;
          emit(state.copyWith(buildingList: updatedList));
        }
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteBuilding(
    int projectId,
    BusinessDevelopmentBuildingModel buildingModel,
    BuildContext context,
    int index,
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
      (response) {
        final updatedList = List<BusinessDevelopmentBuildingModel>.from(
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
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future deleteBuildingDocument({
    required BuildingDocumentModel document,
    required BuildContext context,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final result = await _buildingRepository.deleteBuildingDocument(
      buildingId: document.buildingId,
      uniqueKey: document.uniquekey,
      projectId: document.projectId,
      buildingDocumentId: document.buildingDocumentId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(context, subTitle: success['message']);
        getBuildingDocumentList(
          context: context,
          projectId: document.projectId,
          buildingId: document.buildingId,
          pageNumber: state.currentPage,
        );
      },
    );
  }

  Future<void> updateBuildingDetails({
    required BuildContext context,
    required int buildingId,
    required int projectId,
    required double grossPlotAreaSqFt,
    required double plotAreaPhysicalSurveySqFt,
    required double plotAreaOldApprovedPlanSqFt,
    required double plotAreaConveyanceSqFt,
    required double plotAreaPRCardSqFt,
    required double totalCarpetAreaSqFt,
    required int totalResidentialUnits,
    required double totalResidentialCarpetAreaSqFt,
    required int totalCommercialUnits,
    required double totalCommercialCarpetAreaSqFt,
    required double garageCarpetAreaSqFt,
    required double terraceCarpetAreaSqFt,
    required String chairmanContactName,
    required String chairmanMobileNumber,
    required String chairmanEmailId,
    required String secretaryContactName,
    required String secretaryMobileNumber,
    required String secretaryEmailId,
    required String treasurerContactName,
    required String treasurerMobileNumber,
    required String treasurerEmailId,
    required String pmcContactName,
    required String pmcMobileNumber,
    required String pmcEmailId,
    required String brokerContactName,
    required String brokerMobileNumber,
    required String brokerEmailId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final formData = {
      'BuildingId': buildingId,
      'ProjectId': projectId,
      'GrossPlotAreaSqFt': grossPlotAreaSqFt,
      'PlotAreaPhysicalSurveySqFt': plotAreaPhysicalSurveySqFt,
      'PlotAreaOldApprovedPlanSqFt': plotAreaOldApprovedPlanSqFt,
      'PlotAreaConveyanceSqFt': plotAreaConveyanceSqFt,
      'PlotAreaPRCardSqFt': plotAreaPRCardSqFt,
      'TotalCarpetAreaSqFt': totalCarpetAreaSqFt,
      'TotalResidentialUnits': totalResidentialUnits,
      'TotalResidentialCarpetAreaSqFt': totalResidentialCarpetAreaSqFt,
      'TotalCommercialUnits': totalCommercialUnits,
      'TotalCommercialCarpetAreaSqFt': totalCommercialCarpetAreaSqFt,
      'TotalGarageCarpetAreaSqFt': garageCarpetAreaSqFt,
      'TotalTerraceCarpetAreaSqFt': terraceCarpetAreaSqFt,
      'BuildingKeyContactDetailsJSON': jsonEncode([
        {
          'ContactType': 'Chairman',
          'ContactName': chairmanContactName,
          'MobileNumber': chairmanMobileNumber,
          'EmailId': chairmanEmailId,
        },
        {
          'ContactType': 'Secretary',
          'ContactName': secretaryContactName,
          'MobileNumber': secretaryMobileNumber,
          'EmailId': secretaryEmailId,
        },
        {
          'ContactType': 'Treasurer',
          'ContactName': treasurerContactName,
          'MobileNumber': treasurerMobileNumber,
          'EmailId': treasurerEmailId,
        },
        {
          'ContactType': 'PMC',
          'ContactName': pmcContactName,
          'MobileNumber': pmcMobileNumber,
          'EmailId': pmcEmailId,
        },
        {
          'ContactType': 'Broker',
          'ContactName': brokerContactName,
          'MobileNumber': brokerMobileNumber,
          'EmailId': brokerEmailId,
        },
      ]),
    };
    final result = await _buildingRepository.addUpdateBuildingDetails(
      requestBody: formData,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getBuildingDetails(
          context: context,
          buildingId: buildingId,
          projectId: projectId,
        );
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
      state.filterCity.isNotEmpty,
      state.filterRoadWidth.isNotEmpty,
      state.filterVillage.isNotEmpty,
      state.filterWard.isNotEmpty,
      state.filterCategory.isNotEmpty,
      hasSort,
    ]);
  }

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
}
