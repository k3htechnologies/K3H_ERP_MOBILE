import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/repository/tenant.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
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
      pageSize: 10,
    );
  }

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
        final uniqueNewData = newData.where((building) => !existingIds.contains(building.buildingId)).toList();
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

  // <---- GET TENANT LIST ---->
  Future getTenantList({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int pageNumber,
    required int pageSize,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "FlatNumber": state.searchText,
      "IsCheckPermission": false,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await _tenantRepository.getTenantList(
      pageNumber: pageNumber,
      pageSize: pageSize,
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

        List<TenantModel> updatedList;
        if (pageNumber == 1) {
          updatedList = newData;
        } else {
          // Get existing tenant IDs to avoid duplicates
          final existingIds = state.tenantList.map((t) => t.tenantId).toSet();
          // Filter out duplicates from new data
          final uniqueNewData = newData.where((tenant) => !existingIds.contains(tenant.tenantId)).toList();
          updatedList = [...state.tenantList, ...uniqueNewData];
        }

        emit(
          state.copyWith(
            tenantList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
            currentPage: pageNumber,
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
      (response) async {
        var list = [
          response['data'][0] as TenantModel,
          ...BlocProvider.of<TenantCubit>(context).state.tenantList,
        ];

        BlocProvider.of<TenantCubit>(context).emit(
          BlocProvider.of<TenantCubit>(context).state.copyWith(
            tenantList: list,
            totalNumberOfRecord:
                BlocProvider.of<TenantCubit>(
                          context,
                        ).state.totalNumberOfRecord ==
                        -1
                    ? 1
                    : BlocProvider.of<TenantCubit>(
                          context,
                        ).state.totalNumberOfRecord +
                        1,
          ),
        );
        await showSuccessMessage(
          context,
          subTitle: 'Tenant Added Successfully',
        );
        goRouter.goNamed(AppRoutes.tenant);
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

    // File uploads (skip URLs)
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
      (response) {
        final tenantCubit = BlocProvider.of<TenantCubit>(
          goRouter.routerDelegate.navigatorKey.currentContext!,
        );

        final tenantList = List<TenantModel>.from(tenantCubit.state.tenantList);
        tenantList[index] = response['data'][0] as TenantModel;

        tenantCubit.emit(tenantCubit.state.copyWith(tenantList: tenantList));

        showSuccessMessage(context, subTitle: 'Tenant Updated Successfully');
        goRouter.goNamed(AppRoutes.tenant);
      },
    );
  }
}
