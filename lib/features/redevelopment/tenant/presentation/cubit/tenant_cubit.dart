import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/repository/tenant.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'tenant_state.dart';

class TenantCubit extends Cubit<TenantState> {
  TenantCubit() : super(TenantState.initial());

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();
  // TENANT REPOSITORY
  final TenantRepository _tenantRepository = serviceLocator<TenantRepository>();

  // <---- ON TAB CHANGED ---->
  void onTabChanged(
    int index,
    BuildContext context,
    int projectId,
    int buildingId,
    int tenantId,
  ) {
    emit(state.copyWith(currentTabIndex: index));

    if (index == 1) {
      // Document tab
      getTenantDocumentList(
        context: context,
        projectId: projectId,
        buildingId: buildingId,
        tenantId: tenantId,
      );
    }
  }

  // <---- SEARCH TENANT ---->
  void searchTenant(
    String value,
    BuildContext context,
    int projectId,
    int buildingId,
  ) {
    emit(
      state.copyWith(
        tenantList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getTenantList(
      context: context,
      projectId: projectId,
      buildingId: buildingId,
      pageNumber: 1,
    );
  }

  // APPLY FILTER AND SORT
  Future applyFilterAndSort({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required String filterFlatType,
    required String filterFlatConfiguration,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterFlatType: filterFlatType,
        filterFlatConfiguration: filterFlatConfiguration,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        buildingList: [],
        currentPage: 1,
      ),
    );

    await getTenantList(
      context: context,
      projectId: projectId,
      buildingId: buildingId,
      pageNumber: 1,
    );
  }

  // <---- GET BUILDING LIST ---->
  Future<List<RedevelopmentBuildingModel>> getBuildingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId, {
    String? searchQuery,
  }) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return [];
    }
    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      queryParams:
          searchQuery != null && searchQuery.isNotEmpty
              ? {"BuildingName": searchQuery}
              : null,
    );

    final buildingList = result.fold<List<RedevelopmentBuildingModel>>(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
        return state.buildingList;
      },

      (response) {
        final newData = List<RedevelopmentBuildingModel>.from(response['data']);

        List<RedevelopmentBuildingModel> updatedList;

        if (pageNumber == 1) {
          updatedList =
              state.buildingList
                  .where((b) => b.projectId != projectId)
                  .toList();
        } else {
          updatedList = List.from(state.buildingList);
        }

        final Map<int, RedevelopmentBuildingModel> uniqueMap = {
          for (var b in updatedList) b.buildingId: b,
        };

        for (final b in newData) {
          if (b.projectId == projectId) {
            uniqueMap[b.buildingId] = b;
          }
        }

        updatedList = uniqueMap.values.toList();

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            buildingList: updatedList,
            buildingTotalCount: totalCount,
          ),
        );

        return updatedList;
      },
    );

    return buildingList;
  }

  // <---- GET TENANT LIST ---->
  Future getTenantList({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "FlatNumber": state.searchText,
      "FlatType": state.filterFlatType,
      "FlatConfiguration": state.filterFlatConfiguration,
      "IsCheckPermission": false,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await _tenantRepository.getTenantList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<TenantModel> newData = List<TenantModel>.from(
          response['data'] ?? [],
        );

        final List<TenantModel> updatedList =
            pageNumber == 1 ? newData : [...state.tenantList, ...newData];
        emit(
          state.copyWith(
            tenantList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET TENANT DOCUMENT LIST ---->
  Future<void> getTenantDocumentList({
    required BuildContext context,
    int? tenantId,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _tenantRepository.getTenantDocumentList(
      pageNumber: 1,
      pageSize: 100,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: {"IsCheckPermission": true, "TenantId": tenantId},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            tenantDocumentList: List<TenantDocumentModel>.from(
              response['data'],
            ),
          ),
        );
      },
    );
  }

  // <---- ADD TENANT ---->
  Future addTenant({
    required BuildContext context,
    required String projectId,
    required String buildingId,
    required String flatNumber,
    required String flatCarpetAreaSqFt,
    required String facing,
    required String flatType,
    required String flatConfiguration,
    required String freeAreaOfferedPercentage,
    required String extraAreaPurchasedSqFt,
    required String totalAreaSqFt,
    required List<TenantApplicantData> addUpdateTenantApplicant,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    // ---------- Request Body ----------
    Map<String, String> requestBody = {
      "TenantId": "0",
      "ProjectId": projectId,
      "BuildingId": buildingId,
      "FlatNumber": flatNumber,
      "FlatCarpetAreaSqFt": flatCarpetAreaSqFt,
      "Facing": facing,
      "FlatType": flatType,
      "FlatConfiguration": flatConfiguration,
      "FreeAreaOfferedPercent": freeAreaOfferedPercentage,
      "ExtraAreaPurchasedSqFt": extraAreaPurchasedSqFt,
      "TotalAreaSqFt": totalAreaSqFt,
    };

    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateTenantApplicant.length;
      applicantIndex++
    ) {
      var e = addUpdateTenantApplicant[applicantIndex];

      requestBody.addAll({
        "AddUpdateTenantApplicants[$applicantIndex].BuildingId": buildingId,
        "AddUpdateTenantApplicants[$applicantIndex].ProjectId": projectId,
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantType":
            e.applicantType,
        "AddUpdateTenantApplicants[$applicantIndex].TenantId":
            e.tenantId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].TenantApplicantId":
            e.tenantApplicantId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantName":
            e.applicantName,
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantMobileNumber":
            e.applicantMobileNumber,
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantEmailId":
            e.applicantEmailId,

        // Remove file URLs
        "AddUpdateTenantApplicants[$applicantIndex].RemovePhotoURL":
            e.profilePhotoImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].AadharCardNumber":
            e.aadharCardNumber,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveAadharCardURL":
            e.aadhaarImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].PanNumber": e.panNumber,
        "AddUpdateTenantApplicants[$applicantIndex].RemovePanCardURL":
            e.panImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].PassportNumber":
            e.passportNumber,
        "AddUpdateTenantApplicants[$applicantIndex].RemovePassportURL":
            e.passportImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].DrivingLicenseNumber":
            e.drivingLicenseNumber,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveDrivingLicenseURL":
            e.drivingLicenseImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveChequeURL":
            e.chequeImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].VotingIdNumber":
            e.votingIdNumber,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveVotingIdURL":
            e.votingIdImage.deletedFileList,
        "AddUpdateTenantApplicants[$applicantIndex].GstNumber": e.gstNumber,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveGSTNumberURL":
            e.gstImage.deletedFileList,

        // Bank details
        "AddUpdateTenantApplicants[$applicantIndex].BankListMasterId":
            e.bankListMasterId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].AccountNumber":
            e.accountNumber,
        "AddUpdateTenantApplicants[$applicantIndex].IFSCCode": e.ifscCode,
      });
    }

    // ---------- File Uploads ----------
    List<Map<String, dynamic>> fileList = [];

    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateTenantApplicant.length;
      applicantIndex++
    ) {
      var applicantData = addUpdateTenantApplicant[applicantIndex];

      void addFiles(List<String> names, List<dynamic> bytes, String keyName) {
        for (int fileIndex = 0; fileIndex < names.length; fileIndex++) {
          if (names[fileIndex].contains("http")) continue;
          fileList.add({
            "key": "AddUpdateTenantApplicants[$applicantIndex].$keyName",
            "value": bytes[fileIndex],
            "fileName": names[fileIndex],
          });
        }
      }

      addFiles(
        applicantData.profilePhotoImage.fileNameList,
        applicantData.profilePhotoImage.fileBytesList,
        "PhotoURL",
      );

      addFiles(
        applicantData.aadhaarImage.fileNameList,
        applicantData.aadhaarImage.fileBytesList,
        "AadharCardURL",
      );

      addFiles(
        applicantData.panImage.fileNameList,
        applicantData.panImage.fileBytesList,
        "PanCardURL",
      );

      addFiles(
        applicantData.passportImage.fileNameList,
        applicantData.passportImage.fileBytesList,
        "PassportURL",
      );

      addFiles(
        applicantData.drivingLicenseImage.fileNameList,
        applicantData.drivingLicenseImage.fileBytesList,
        "DrivingLicenseURL",
      );

      addFiles(
        applicantData.votingIdImage.fileNameList,
        applicantData.votingIdImage.fileBytesList,
        "VotingIdURL",
      );

      addFiles(
        applicantData.gstImage.fileNameList,
        applicantData.gstImage.fileBytesList,
        "GstNumberURL",
      );

      addFiles(
        applicantData.chequeImage.fileNameList,
        applicantData.chequeImage.fileBytesList,
        "ChequeURL",
      );
    }

    // ---------- API CALL ----------
    var addResult = await _tenantRepository.addUpdateTenant(
      body: requestBody,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false));
        await showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Tenant Added Successfully');
      },
    );
  }

  // <---- UPDATE TENANT ---->
  Future updateTenant({
    required BuildContext context,
    required String projectId,
    required int index,
    required String tenantId,
    required String uniqueKey,
    required String buildingId,
    required String flatNumber,
    required String flatCarpetAreaSqFt,
    required String facing,
    required String flatType,
    required String flatConfiguration,
    required String freeAreaOfferedPercentage,
    required String extraAreaPurchasedSqFt,
    required String totalAreaSqFt,
    required List<TenantApplicantData> addUpdateTenantApplicant,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    // Build request
    Map<String, String> requestBody = {
      "TenantId": tenantId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "BuildingId": buildingId,
      "FlatNumber": flatNumber,
      "FlatCarpetAreaSqFt": flatCarpetAreaSqFt,
      "Facing": facing,
      "FlatType": flatType,
      "FlatConfiguration": flatConfiguration,
      "FreeAreaOfferedPercent": freeAreaOfferedPercentage,
      "ExtraAreaPurchasedSqFt": extraAreaPurchasedSqFt,
      "TotalAreaSqFt": totalAreaSqFt,
    };

    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateTenantApplicant.length;
      applicantIndex++
    ) {
      var e = addUpdateTenantApplicant[applicantIndex];

      requestBody.addAll({
        "AddUpdateTenantApplicants[$applicantIndex].BuildingId": buildingId,
        "AddUpdateTenantApplicants[$applicantIndex].ProjectId": projectId,
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantType":
            e.applicantType,
        "AddUpdateTenantApplicants[$applicantIndex].TenantId":
            e.tenantId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].TenantApplicantId":
            e.tenantApplicantId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantName":
            e.applicantName,
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantMobileNumber":
            e.applicantMobileNumber,
        "AddUpdateTenantApplicants[$applicantIndex].ApplicantEmailId":
            e.applicantEmailId,

        // Keep original URLs, send deleted files separately
        "AddUpdateTenantApplicants[$applicantIndex].PhotoURL": e.photoURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemovePhotoURL":
            e.profilePhotoImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].AadharCardNumber":
            e.aadharCardNumber,
        "AddUpdateTenantApplicants[$applicantIndex].AadharCardURL":
            e.aadharCardURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveAadharCardURL":
            e.aadhaarImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].PanNumber": e.panNumber,
        "AddUpdateTenantApplicants[$applicantIndex].PanCardURL": e.panCardURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemovePanCardURL":
            e.panImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].PassportNumber":
            e.passportNumber,
        "AddUpdateTenantApplicants[$applicantIndex].PassportURL": e.passportURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemovePassportURL":
            e.passportImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].DrivingLicenseNumber":
            e.drivingLicenseNumber,
        "AddUpdateTenantApplicants[$applicantIndex].DrivingLicenseURL":
            e.drivingLicenseURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveDrivingLicenseURL":
            e.drivingLicenseImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].ChequeURL": e.chequeURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveChequeURL":
            e.chequeImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].VotingIdNumber":
            e.votingIdNumber,
        "AddUpdateTenantApplicants[$applicantIndex].VotingIdURL": e.votingIdURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveVotingIdURL":
            e.votingIdImage.deletedFileList,

        "AddUpdateTenantApplicants[$applicantIndex].GstNumber": e.gstNumber,
        "AddUpdateTenantApplicants[$applicantIndex].GstNumberURL":
            e.gstNumberURL,
        "AddUpdateTenantApplicants[$applicantIndex].RemoveGSTNumberURL":
            e.gstImage.deletedFileList,

        // Bank details
        "AddUpdateTenantApplicants[$applicantIndex].BankListMasterId":
            e.bankListMasterId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].AccountNumber":
            e.accountNumber,
        "AddUpdateTenantApplicants[$applicantIndex].IFSCCode": e.ifscCode,
      });
    }

    List<Map<String, dynamic>> fileList = [];
    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateTenantApplicant.length;
      applicantIndex++
    ) {
      var applicantData = addUpdateTenantApplicant[applicantIndex];

      void addFiles(List<String> names, List<dynamic> bytes, String keyName) {
        for (int fileIndex = 0; fileIndex < names.length; fileIndex++) {
          if (names[fileIndex].contains("http")) {
            continue;
          }
          fileList.add({
            "key": "AddUpdateTenantApplicants[$applicantIndex].$keyName",
            "value": bytes[fileIndex],
            "fileName": names[fileIndex],
          });
        }
      }

      addFiles(
        applicantData.profilePhotoImage.fileNameList,
        applicantData.profilePhotoImage.fileBytesList,
        "PhotoURL",
      );
      addFiles(
        applicantData.aadhaarImage.fileNameList,
        applicantData.aadhaarImage.fileBytesList,
        "AadharCardURL",
      );
      addFiles(
        applicantData.panImage.fileNameList,
        applicantData.panImage.fileBytesList,
        "PanCardURL",
      );
      addFiles(
        applicantData.passportImage.fileNameList,
        applicantData.passportImage.fileBytesList,
        "PassportURL",
      );
      addFiles(
        applicantData.drivingLicenseImage.fileNameList,
        applicantData.drivingLicenseImage.fileBytesList,
        "DrivingLicenseURL",
      );
      addFiles(
        applicantData.votingIdImage.fileNameList,
        applicantData.votingIdImage.fileBytesList,
        "VotingIdURL",
      );
      addFiles(
        applicantData.gstImage.fileNameList,
        applicantData.gstImage.fileBytesList,
        "GstNumberURL",
      );
      addFiles(
        applicantData.chequeImage.fileNameList,
        applicantData.chequeImage.fileBytesList,
        "ChequeURL",
      );
    }

    var updateResult = await _tenantRepository.addUpdateTenant(
      body: requestBody,
      fileList: fileList,
    );

    goRouter.pop();

    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        goRouter.pop();
        final updatedTenant = response['data'][0] as TenantModel;

        if (state.tenantList.isNotEmpty && index < state.tenantList.length) {
          final updatedList = List<TenantModel>.from(state.tenantList);
          updatedList[index] = updatedTenant;
          emit(state.copyWith(tenantList: updatedList, isLoading: false));
        }
        showSuccessMessage(context, subTitle: 'Tenant Updated Successfully');
      },
    );
  }

  // <---- DELETE TENANT ---->
  Future deleteTenant(
    int projectId,
    int buildingId,
    TenantModel tenantModel,
    BuildContext context,
    int? index,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _tenantRepository.deleteTenant(
      buildingId: tenantModel.buildingId,
      uniquekey: tenantModel.uniquekey,
      projectId: projectId,
      tenantId: tenantModel.tenantId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(context, subTitle: "Tenant Deleted Successfully");

        if (index != null) {
          final updatedList = List<TenantModel>.from(state.tenantList);
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              tenantList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getTenantList(
            context: context,
            pageNumber: state.currentPage,
            projectId: projectId,
            buildingId: buildingId,
          );
        }
      },
    );
  }

  // <---- EXPORT ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
    int buildingId,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _tenantRepository.exportTenant(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: {"ExportType": exportType, "FlatNumber": state.searchText},
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
              ? "tenant_${DateTime.now()}.pdf"
              : "tenant_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // <---- ADD TENaNT DOCUMENT ---->
  Future addTenantDocument({
    required BuildContext context,
    required int tenantId,
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
      'TenantDocumentId': "0",
      'TenantId': tenantId.toString(),
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
    };

    var updateResult = await _tenantRepository.addUpdateTenantDocument(
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
        await getTenantDocumentList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          tenantId: tenantId,
        );
      },
    );
  }

  // <---- ADD/UPDATE BUILDING DOCUMENT ---->
  Future updateTenantDocument({
    required BuildContext context,
    required int tenantDocumentId,
    required String uniqueKey,
    required int tenantId,
    required int projectId,
    required int buildingId,
    required String documentName,
    required MultiFilePickerModel files,
  }) async {
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
      'TenantDocumentId': tenantDocumentId.toString(),
      'Uniquekey': uniqueKey,
      'ProjectId': projectId.toString(),
      'BuildingId': buildingId.toString(),
      'DocumentName': documentName,
      'RemoveDocumentURL': files.deletedFileList,
    };

    var updateResult = await _tenantRepository.addUpdateTenantDocument(
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
        showSuccessMessage(context, subTitle: "Upload Successfully");
        await getTenantDocumentList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          tenantId: tenantId,
        );
      },
    );
  }
}
