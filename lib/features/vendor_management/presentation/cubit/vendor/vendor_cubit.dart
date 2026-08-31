import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/repository/vendor.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

part 'vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit() : super(VendorState.initial());

  // VENDOR REPOSITORY
  VendorRepository vendorRepository = serviceLocator<VendorRepository>();
  UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

  // COMPANY MASTER REPOSITORY
  CompanyMasterRepository companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();

  // SEARCH VENDOR
  Future searchVendor(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, vendorList: []));
    await getVendors(context, 1);
  }

  // GET VENDORS LIST
  Future getVendors(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "VendorName": state.searchText,
      "SystemGeneratedCode": state.filterByVendorCode,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "CompanyName": state.filterByCompanyName,
      "CompanyType": state.filterByCompanyType,
      "MobileNumber": state.filterByMobileNumber,
      "CityName": state.filterByCity,
      "GSTNumber": state.filterByGstNumber,
      "AadharCardNumber": state.filterByAadhaarCardNumber,
      "PanCardNumber": state.filterByPanCardNumber,
    };

    var result = await vendorRepository.getVendorsList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final List<VendorModel> newData = List<VendorModel>.from(
          response['data'] ?? [],
        );

        final List<VendorModel> updatedList =
            pageNumber == 1
                ? newData
                : {
                  for (final v in [...state.vendorList, ...newData])
                    v.vendorId: v,
                }.values.toList();

        emit(
          state.copyWith(
            vendorList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future<List<VendorModel>> fetchVendorByMobile(String? value) async {
    final result = await vendorRepository.getVendorsList(
      pageNumber: 1,
      pageSize: 10,
      queryParams: {"MobileNumber": value ?? "", "IsCheckPermission": false},
    );

    return result.fold((failure) => [], (response) {
      final partners = response['data'] as List<VendorModel>;

      return partners;
    });
  }

  // DELETE VENDOR
  Future deleteVendor({
    required BuildContext context,
    required int vendorId,
    required String uniqueKey,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await vendorRepository.deleteVendor(
      vendorId: vendorId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedList = List<VendorModel>.from(state.vendorList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            vendorList: updatedList,
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

  void closeLoader() {
    emit(state.copyWith(isLoading: false));
  }

  // DROPDOWN FUNCTIONS
  Future<Map<String, dynamic>> getMaterialSubMaterialUOMMaster(
    BuildContext context,
  ) async {
    emit(state.copyWith(isLoading: true));
    int projectId = 0;
    try {
      final projectString = LocalStorageManager().getString(
        StorageKey.selectedProject,
      );
      if (projectString != null) {
        final project = ProjectModel.fromJson(jsonDecode(projectString));
        projectId = project.projectId;
      }
    } catch (e) {
      projectId = 0;
    }

    var result = await utilsRepository
        .getMaterialMasterSubMaterialMasterUOMMaster(projectId: projectId);
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        // HANDLE FAILURE
        return {
          "MaterialMasterSubMaterialMasterData": <SubMaterialModel>[],
          "totalNumberOfRecord": 0,
          "isSuccess": false,
        };
      },
      (response) async {
        final data = response["MaterialMasterSubMaterialMasterData"];
        if (data == null) {
          return {
            "MaterialMasterSubMaterialMasterData": <SubMaterialModel>[],
            "totalNumberOfRecord": 0,
            "isSuccess": false,
          };
        }

        return {
          "MaterialMasterSubMaterialMasterData": List<SubMaterialModel>.from(
            (await compute(
              (m) =>
                  (m as List<dynamic>)
                      .map((e) => SubMaterialModel.fromJson(e))
                      .toList(),
              data,
            )),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
          "isSuccess": true,
        };
      },
    );
  }

  // ADD VENDOR
  Future addVendor({
    required BuildContext context,
    required String companyName,
    required String companyType,
    required String vendorType,
    required String vendorName,
    required String mobileNumberCountryCode,
    required String mobileNumber,
    required String emailId,
    required String aadharCardNumber,
    required String panCardNumber,
    required String gstNumber,
    required String address,
    required String countryMasterId,
    required String stateMasterId,
    required String districtMasterId,
    required String cityMasterId,
    required String subMaterialIds,
    required String contractIds,
    required MultiFilePickerModel aadharCard,
    required MultiFilePickerModel panCard,
    required MultiFilePickerModel gstCertificate,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "CompanyName": companyName,
      "CompanyType": companyType,
      "VendorType": vendorType,
      "VendorName": vendorName,
      "MobileNumberCountryCode": mobileNumberCountryCode,
      "MobileNumber": mobileNumber,
      "EmailId": emailId,
      "AadharCardNumber": aadharCardNumber,
      "RemoveAadharCardURL": "",
      "PanCardNumber": panCardNumber,
      "RemovePanCardURL": "",
      "GSTNumber": gstNumber,
      "RemoveGSTCertificateURL": "",
      "Address": address,
      "CountryMasterId": countryMasterId,
      "StateMasterId": stateMasterId,
      "DistrictMasterId": districtMasterId,
      "CityMasterId": cityMasterId,
      "AvailableMaterialList": subMaterialIds,
      "AvailableContractList": "",
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < aadharCard.fileBytesList.length; i++) {
      fileList.add({
        "key": "AadharCardURL",
        "value": aadharCard.fileBytesList[i],
        "fileName": aadharCard.fileNameList[i],
      });
    }

    for (int i = 0; i < panCard.fileBytesList.length; i++) {
      fileList.add({
        "key": "PanCardURL",
        "value": panCard.fileBytesList[i],
        "fileName": panCard.fileNameList[i],
      });
    }

    for (int i = 0; i < gstCertificate.fileBytesList.length; i++) {
      fileList.add({
        "key": "GSTCertificateURL",
        "value": gstCertificate.fileBytesList[i],
        "fileName": gstCertificate.fileNameList[i],
      });
    }

    var result = await vendorRepository.addUpdateVendor(
      payload: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getVendors(context, 1);
      },
    );
  }

  // UPDATE VENDOR
  Future updateVendor({
    required int index,
    required int vendorId,
    required String uniquekey,
    required BuildContext context,
    required String companyName,
    required String companyType,
    required String vendorType,
    required String vendorName,
    required String mobileNumberCountryCode,
    required String mobileNumber,
    required String emailId,
    required String aadharCardNumber,
    required String panCardNumber,
    required String gstNumber,
    required String address,
    required String countryMasterId,
    required String stateMasterId,
    required String districtMasterId,
    required String cityMasterId,
    required String subMaterialIds,
    required String contractIds,
    required MultiFilePickerModel aadharCard,
    required MultiFilePickerModel panCard,
    required MultiFilePickerModel gstCertificate,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "VendorId": vendorId.toString(),
      "UniqueKey": uniquekey,
      "CompanyName": companyName,
      "CompanyType": companyType,
      "VendorType": vendorType,
      "VendorName": vendorName,
      "MobileNumberCountryCode": mobileNumberCountryCode,
      "MobileNumber": mobileNumber,
      "EmailId": emailId,
      "AadharCardNumber": aadharCardNumber,
      "RemoveAadharCardURL": aadharCard.deletedFileList,
      "PanCardNumber": panCardNumber,
      "RemovePanCardURL": panCard.deletedFileList,
      "GSTNumber": gstNumber,
      "RemoveGSTCertificateURL": gstCertificate.deletedFileList,
      "Address": address,
      "CountryMasterId": countryMasterId,
      "StateMasterId": stateMasterId,
      "DistrictMasterId": districtMasterId,
      "CityMasterId": cityMasterId,
      "AvailableMaterialList": subMaterialIds,
      "AvailableContractList": "",
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < aadharCard.fileBytesList.length; i++) {
      if (aadharCard.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "AadharCardURL",
        "value": aadharCard.fileBytesList[i],
        "fileName": aadharCard.fileNameList[i],
      });
    }

    for (int i = 0; i < panCard.fileBytesList.length; i++) {
      if (panCard.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PanCardURL",
        "value": panCard.fileBytesList[i],
        "fileName": panCard.fileNameList[i],
      });
    }

    for (int i = 0; i < gstCertificate.fileBytesList.length; i++) {
      if (gstCertificate.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "GSTCertificateURL",
        "value": gstCertificate.fileBytesList[i],
        "fileName": gstCertificate.fileNameList[i],
      });
    }
    var result = await vendorRepository.addUpdateVendor(
      payload: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        goRouter.pop();
        final updatedVendor = (response['data'] as List<VendorModel>).first;

        if (state.vendorList.isNotEmpty && index < state.vendorList.length) {
          final updatedList = List<VendorModel>.from(state.vendorList);
          updatedList[index] = updatedVendor;

          emit(state.copyWith(vendorList: updatedList, isLoading: false));
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  // <--- SORT VENDOR

  Future sortVendor({
    required BuildContext context,
    String? vendorCode,
    String? vendorName,
    String? companyType,
    String? companyName,
    String? mobileNumber,
    String? city,
    String? gstNumber,
    String? aadhaarCardNumber,
    String? panCardNumber,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByVendorCode: "",
          filterByCompanyType: "",
          filterByCompanyName: "",
          filterByMobileNumber: "",
          filterByCity: "",
          filterByGstNumber: "",
          filterByAadhaarCardNumber: "",
          filterByPanCardNumber: "",
          currentSortColumn: "Created Date",
          currentSortDirection: "DESC",
          currentPage: 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: vendorName ?? state.searchText,
          filterByVendorCode: vendorCode ?? state.filterByVendorCode,
          filterByCompanyType: companyType ?? state.filterByCompanyType,
          filterByCompanyName: companyName ?? state.filterByCompanyName,
          filterByMobileNumber: mobileNumber ?? state.filterByMobileNumber,
          filterByCity: city ?? state.filterByCity,
          filterByGstNumber: gstNumber ?? state.filterByGstNumber,
          filterByAadhaarCardNumber:
              aadhaarCardNumber ?? state.filterByAadhaarCardNumber,
          filterByPanCardNumber: panCardNumber ?? state.filterByPanCardNumber,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          currentPage: 1,
        ),
      );
    }

    await getVendors(context, 1);
  }

  // FILTER CP
  Future filterVendor({
    required BuildContext context,
    required String companyName,
    required String companyType,
  }) async {
    emit(
      state.copyWith(
        filterByCompanyName: companyName,
        filterByCompanyType: companyType,
        vendorList: [],
      ),
    );
    await getVendors(context, state.currentPage);
  }

  // EXPORT EXCEL PDF
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await vendorRepository.exportVendor(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"VendorName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "vendor_${DateTime.now()}.pdf"
              : "vendor_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(VendorState state) {
    final hasSort =
        state.currentSortColumn == "Vendor Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByVendorCode.trim().isNotEmpty,
      state.filterByCompanyName.trim().isNotEmpty,
      state.filterByCompanyType.trim().isNotEmpty,
      state.filterByMobileNumber.trim().isNotEmpty,
      state.filterByCity.trim().isNotEmpty,
      state.filterByGstNumber.trim().isNotEmpty,
      state.filterByAadhaarCardNumber.trim().isNotEmpty,
      state.filterByPanCardNumber.trim().isNotEmpty,
      hasSort,
    ]);
  }
}
