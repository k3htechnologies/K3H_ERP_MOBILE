import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver_plus/files.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/repository/tenant.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
part 'tenant_state.dart';

class TenantCubit extends Cubit<TenantState> {
  TenantCubit() : super(TenantState.initial());
  // TENANT REPOSITORY
  final TenantRepository _tenantRepository = serviceLocator<TenantRepository>();
  // ON TAB CHANGED
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

  // SEARCH TENANT
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
    required String filterByFlatType,
    required String filterByFlatConfiguration,
    String? filterByFlatNumber,
    String? filterByApplicantName,
    String? filterByFlatCarpetAreaSqFt,
    String? filterByBuildingNumber,
    String? filterByWing,
    String? filterByFlat,
    String? filterByParkingNumber,
    String? filterByTenantCode,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterByFlatType: filterByFlatType,
        filterByFlatConfiguration: filterByFlatConfiguration,
        searchText: filterByFlatNumber,
        filterByApplicantName: filterByApplicantName ?? "",
        filterByFlatCarpetAreaSqFt: filterByFlatCarpetAreaSqFt ?? "",
        filterByBuildingNumber: filterByBuildingNumber ?? "",
        filterByWing: filterByWing ?? "",
        filterByFlat: filterByFlat ?? "",
        filterByParkingNumber: filterByParkingNumber ?? "",
        filterByTenantCode: filterByTenantCode ?? "",
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        buildingList: [],
        currentPage: 1,
      ),
    );
    if (buildingId == 0) return;
    await getTenantList(
      context: context,
      projectId: projectId,
      buildingId: buildingId,
      pageNumber: 1,
    );
  }

  // GET TENANT LIST
  Future getTenantList({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "UnitType": state.filterByFlatType,
      "ApplicantName": state.filterByApplicantName,
      "UnitConfiguration": state.filterByFlatConfiguration,
      "UnitAnnexureSurveyNumber": state.searchText,
      "UnitCarpetAreaSqFt": state.filterByFlatCarpetAreaSqFt,
      "BuildingNumber": state.filterByBuildingNumber,
      "Wing": state.filterByWing,
      "Flat": state.filterByFlat,
      "ParkingNumber": state.filterByParkingNumber,
      "IsCheckPermission": false,
      "SystemGeneratedCode": state.filterByTenantCode,
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

  void searchTenantDocument({
    required String value,
    required int buildingId,
    required int projectId,
    required BuildContext context,
    required int tenantId,
  }) {
    emit(state.copyWith(searchDocumentName: value));
    getTenantDocumentList(
      buildingId: buildingId,
      context: context,
      projectId: projectId,
      tenantId: tenantId,
    );
  }

  // GET TENANT DOCUMENT LIST
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
      queryParams: {
        "IsCheckPermission": true,
        "TenantId": tenantId,
        "DocumentName": state.searchDocumentName,
      },
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

  // ADD TENANT
  Future addTenant({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required String unitAnnexureSurveyNumber,
    required String unitCarpetAreaSqFt,
    required String unitFacing,
    required String unitType,
    required String unitConfiguration,
    required double extraFreeCarpetAreaOfferedPercent,
    required double freeMOFACarpetAreaSqFt,
    required double newEligibilityMOFACarpetAreaSqFt,
    required double newEligibilityRERACarpetAreaSqFt,
    required double mofaCarpetAreaPurchasedSqFt,
    required double reraCarpetAreaPurchasedSqFt,
    required double totalNewMOFACarpetAreaSqFt,
    required double totalNewRERACarpetAreaSqFt,
    required double deckAreaSqFt,
    required double existingTerraceAreaSqFt,
    required double areaAgainstTerraceSqFt,
    required double totalNewRERACarpetAreaWithDeckSqFt,
    required String remark,
    required List<TenantApplicantData> addUpdateTenantApplicant,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    // Build request
    Map<String, String> requestBody = {
      "TenantId": "0",
      "ProjectId": projectId.toString(),
      "BuildingId": buildingId.toString(),
      "UnitAnnexureSurveyNumber": unitAnnexureSurveyNumber,
      "UnitType": unitType,
      "UnitConfiguration": unitConfiguration,
      "UnitCarpetAreaSqFt": unitCarpetAreaSqFt,
      "UnitFacing": unitFacing,
      "ExtraFreeCarpetAreaOfferedPercent":
          extraFreeCarpetAreaOfferedPercent.toString(),
      "FreeMOFACarpetAreaSqFt": freeMOFACarpetAreaSqFt.toString(),
      "NewEligibilityMOFACarpetAreaSqFt":
          newEligibilityMOFACarpetAreaSqFt.toString(),
      "NewEligibilityRERACarpetAreaSqFt":
          newEligibilityRERACarpetAreaSqFt.toString(),
      "MOFACarpetAreaPurchasedSqFt": mofaCarpetAreaPurchasedSqFt.toString(),
      "RERACarpetAreaPurchasedSqFt": reraCarpetAreaPurchasedSqFt.toString(),
      "TotalNewMOFACarpetAreaSqFt": totalNewMOFACarpetAreaSqFt.toString(),
      "TotalNewRERACarpetAreaSqFt": totalNewRERACarpetAreaSqFt.toString(),
      "DeckAreaSqFt": deckAreaSqFt.toString(),
      "ExistingTerraceAreaSqFt": existingTerraceAreaSqFt.toString(),
      "AreaAgainstTerraceSqFt": areaAgainstTerraceSqFt.toString(),
      "TotalNewRERACarpetAreaWithDeckSqFt":
          totalNewRERACarpetAreaWithDeckSqFt.toString(),
      "Remark": remark,
    };
    for (
      int applicantIndex = 0;
      applicantIndex < addUpdateTenantApplicant.length;
      applicantIndex++
    ) {
      var e = addUpdateTenantApplicant[applicantIndex];
      requestBody.addAll({
        "AddUpdateTenantApplicants[$applicantIndex].BuildingId":
            buildingId.toString(),
        "AddUpdateTenantApplicants[$applicantIndex].ProjectId":
            projectId.toString(),
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
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PhotoURL",
        fileModel: applicantData.profilePhotoImage,
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.aadhaarImage,
        fieldName: "AadharCardURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.panImage,
        fieldName: "PanCardURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.passportImage,
        fieldName: "PassportURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.drivingLicenseImage,
        fieldName: "DrivingLicenseURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.votingIdImage,
        fieldName: "VotingIdURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.gstImage,
        fieldName: "GstNumberURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.chequeImage,
        fieldName: "ChequeURL",
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
        showSuccessMessage(context, subTitle: 'Tenant Updated Successfully');
        getTenantList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          pageNumber: 1,
        );
      },
    );
  }

  // UPDATE TENANT
  Future updateTenant({
    required BuildContext context,
    required String projectId,
    required int index,
    required String tenantId,
    required String uniqueKey,
    required String buildingId,
    required String unitAnnexureSurveyNumber,
    required String unitCarpetAreaSqFt,
    required String unitFacing,
    required String unitType,
    required String unitConfiguration,
    required double extraFreeCarpetAreaOfferedPercent,
    required double freeMOFACarpetAreaSqFt,
    required double newEligibilityMOFACarpetAreaSqFt,
    required double newEligibilityRERACarpetAreaSqFt,
    required double mofaCarpetAreaPurchasedSqFt,
    required double reraCarpetAreaPurchasedSqFt,
    required double totalNewMOFACarpetAreaSqFt,
    required double totalNewRERACarpetAreaSqFt,
    required double deckAreaSqFt,
    required double existingTerraceAreaSqFt,
    required double areaAgainstTerraceSqFt,
    required double totalNewRERACarpetAreaWithDeckSqFt,
    required String remark,
    required List<TenantApplicantData> addUpdateTenantApplicant,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    // Build request
    Map<String, String> requestBody = {
      "TenantId": tenantId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "BuildingId": buildingId,
      "UnitAnnexureSurveyNumber": unitAnnexureSurveyNumber,
      "UnitType": unitType,
      "UnitConfiguration": unitConfiguration,
      "UnitCarpetAreaSqFt": unitCarpetAreaSqFt,
      "UnitFacing": unitFacing,
      "ExtraFreeCarpetAreaOfferedPercent":
          extraFreeCarpetAreaOfferedPercent.toString(),
      "FreeMOFACarpetAreaSqFt": freeMOFACarpetAreaSqFt.toString(),
      "NewEligibilityMOFACarpetAreaSqFt":
          newEligibilityMOFACarpetAreaSqFt.toString(),
      "NewEligibilityRERACarpetAreaSqFt":
          newEligibilityRERACarpetAreaSqFt.toString(),
      "MOFACarpetAreaPurchasedSqFt": mofaCarpetAreaPurchasedSqFt.toString(),
      "RERACarpetAreaPurchasedSqFt": reraCarpetAreaPurchasedSqFt.toString(),
      "TotalNewMOFACarpetAreaSqFt": totalNewMOFACarpetAreaSqFt.toString(),
      "TotalNewRERACarpetAreaSqFt": totalNewRERACarpetAreaSqFt.toString(),
      "DeckAreaSqFt": deckAreaSqFt.toString(),
      "ExistingTerraceAreaSqFt": existingTerraceAreaSqFt.toString(),
      "AreaAgainstTerraceSqFt": areaAgainstTerraceSqFt.toString(),
      "TotalNewRERACarpetAreaWithDeckSqFt":
          totalNewRERACarpetAreaWithDeckSqFt.toString(),
      "Remark": remark,
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
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fieldName: "PhotoURL",
        fileModel: applicantData.profilePhotoImage,
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.aadhaarImage,
        fieldName: "AadharCardURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.panImage,
        fieldName: "PanCardURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.passportImage,
        fieldName: "PassportURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.drivingLicenseImage,
        fieldName: "DrivingLicenseURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.votingIdImage,
        fieldName: "VotingIdURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.gstImage,
        fieldName: "GstNumberURL",
      );
      await _addFiles(
        fileList: fileList,
        applicantIndex: applicantIndex,
        fileModel: applicantData.chequeImage,
        fieldName: "ChequeURL",
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

  Future<void> _addFiles({
    required List<Map<String, dynamic>> fileList,
    required int applicantIndex,
    required String fieldName,
    required MultiFilePickerModel fileModel,
  }) async {
    for (int i = 0; i < fileModel.fileNameList.length; i++) {
      final fileName = fileModel.fileNameList[i];
      // skip already uploaded files
      if (fileName.contains("http")) continue;
      if (i >= fileModel.fileBytesList.length) continue;
      final bytes = fileModel.fileBytesList[i];
      final finalBytes = isImage(fileName) ? await compress(bytes) : bytes;
      fileList.add({
        "key": "AddUpdateTenantApplicants[$applicantIndex].$fieldName",
        "value": finalBytes,
        "fileName": fileName,
      });
    }
  }

  // DELETE TENANT
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

  // EXPORT
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

  // ADD TENaNT DOCUMENT
  Future addTenantDocument({
    required BuildContext context,
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
        showSuccessMessage(context, subTitle: response['message']);
        await getTenantDocumentList(
          context: context,
          projectId: projectId,
          buildingId: buildingId,
          tenantId: tenantId,
        );
      },
    );
  }

  // ADD/UPDATE BUILDING DOCUMENT
  Future updateTenantDocument({
    required BuildContext context,
    required int tenantDocumentId,
    required String uniqueKey,
    required int tenantId,
    required int projectId,
    required int buildingId,
    required String documentName,
    required MultiFilePickerModel files,
    required int index,
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
      'TenantId': tenantId.toString(),
      'BuildingId': buildingId.toString(),
      'ProjectId': projectId.toString(),
      'DocumentName': documentName,
      'RemoveDocumentURL': files.deletedFileList,
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
        final updatedChannelPartner =
            (response['data'] as List<TenantDocumentModel>).first;
        if (state.tenantDocumentList.isNotEmpty &&
            index < state.tenantDocumentList.length) {
          final updatedList = List<TenantDocumentModel>.from(
            state.tenantDocumentList,
          );
          updatedList[index] = updatedChannelPartner;
          emit(
            state.copyWith(isLoading: false, tenantDocumentList: updatedList),
          );
        }
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  void deleteTenantDocument({
    required BuildContext context,
    required int tenantDocumentId,
    required String uniqueKey,
    required int tenantId,
    required int projectId,
    required int buildingId,
    required int index,
  }) async {
    final result = await _tenantRepository.deleteTenantDocument(
      tenantDocumentId: tenantDocumentId,
      uniquekey: uniqueKey,
      projectId: projectId,
      buildingId: buildingId,
      tenantId: tenantId,
    );
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        final updatedList = List<TenantDocumentModel>.from(
          state.tenantDocumentList,
        );
        updatedList.removeAt(index);
        emit(state.copyWith(tenantDocumentList: updatedList, isLoading: false));
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  int updateFilterCount(TenantState state) {
    final hasSort =
        state.currentSortColumn == "Applicant Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByTenantCode.trim().isNotEmpty,
      state.filterByApplicantName.trim().isNotEmpty,
      state.filterByFlatType.trim().isNotEmpty,
      state.filterByFlatConfiguration.trim().isNotEmpty,
      state.filterByFlatCarpetAreaSqFt.trim().isNotEmpty,
      state.filterByBuildingNumber.trim().isNotEmpty,
      state.filterByWing.trim().isNotEmpty,
      state.filterByFlat.trim().isNotEmpty,
      state.filterByParkingNumber.trim().isNotEmpty,
      hasSort,
    ]);
  }
}
