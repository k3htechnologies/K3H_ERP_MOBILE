import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'company_master_state.dart';

class CompanyMasterCubit extends Cubit<CompanyMasterState> {
  CompanyMasterCubit() : super(CompanyMasterState.initial());

  // REPOSITORY
  final CompanyMasterRepository _companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();

  // <---- FILTER COMPANY ---->
  Future filterCompany({
    required BuildContext context,
    required String companyType,
  }) async {
    emit(state.copyWith(filterByCompanyType: companyType, companyList: []));
    await getCompanyMaster(context, 1);
  }

  // <---- GET COMPANIES ---->
  Future<void> getCompanyMaster(BuildContext context, int pageNumber) async {
    // Clear list on fresh load to avoid duplicates (e.g., after add)
    emit(
      state.copyWith(
        isLoading: true,
        companyList: pageNumber == 1 ? [] : state.companyList,
        currentPage: pageNumber == 1 ? 1 : state.currentPage,
      ),
    );
    Map<String, dynamic> queryParams = {
      "CompanyName": state.searchText,
      "CompanyType": state.filterByCompanyType,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await _companyMasterRepository.getCompanyList(
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
        final fetched = response['data'] as List<CompanyModel>;

        Map<String, CompanyModel> map = {};
        if (pageNumber > 1) {
          for (final c in state.companyList) {
            map[c.uniquekey] = c;
          }
        }
        for (final c in fetched) {
          map[c.uniquekey] = c;
        }
        final updatedList = map.values.toList();
        emit(
          state.copyWith(
            isLoading: false,
            companyList: updatedList,
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

  // <---- DELETE COMPANY ---->
  Future<void> deleteCompanyMaster({
    required BuildContext context,
    required int companyMasterId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _companyMasterRepository.deleteCompanyList(
      companyId: companyMasterId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: "Company deleted successfully");
        if (index != null) {
          final updatedList = List<CompanyModel>.from(state.companyList);
          updatedList.removeAt(index);
          emit(state.copyWith(companyList: updatedList));
        } else {
          getCompanyMaster(context, pageNumber);
        }
      },
    );
  }

  // <---- ADD COMPANY ---->
  Future<void> addCompanyMaster({
    required BuildContext context,
    required String companyName,
    required String companyType,
    required String contactPerson,
    required String mobileNumber,
    required String emailId,
    required String landLineNumber,
    required String gstNumber,
    required MultiFilePickerModel gstCertificateFile,
    required MultiFilePickerModel panCardFile,
    required String cinNumber,
    required MultiFilePickerModel cinFile,
    required String panNumber,
    required String reraNumber,
    required MultiFilePickerModel companyLetterheadHeaderFile,
    required MultiFilePickerModel companyLetterheadFooterFile,
    required int countryId,
    required int stateId,
    required int districtId,
    required int cityId,
    required int pageNumber,
    required int pageSize,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "CompanyId": "0",
      "CompanyName": companyName,
      "CompanyType": companyType,
      "ContactPerson": contactPerson,
      "MobileNumber": mobileNumber,
      "EmailId": emailId,
      "LandLineNumber": landLineNumber,
      "GSTNumber": gstNumber,
      "CINNumber": cinNumber,
      "PanNumber": panNumber,
      "RERANumber": reraNumber,
      "CountryMasterId": countryId.toString(),
      "StateMasterId": stateId.toString(),
      "DistrictMasterId": districtId.toString(),
      "CityMasterId": cityId.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].FirstName':
            state.companyPartner[i].firstName.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].LastName':
            state.companyPartner[i].lastName.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].MiddleName':
            state.companyPartner[i].middleName,
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].DateOfBirth':
            state.companyPartner[i].dateOfBirth.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].Gender': state.companyPartner[i].gender,
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].MobileNumber':
            state.companyPartner[i].mobileNumber.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].EmailId':
            state.companyPartner[i].emailId.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].PartnerPercentage':
            state.companyPartner[i].partnerPercentage.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].PanNumber':
            state.companyPartner[i].panNumber.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].PanCardURL':
            state.companyPartner[i].panCardURL.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].AadharCardNumber':
            state.companyPartner[i].aadharCardNumber.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].AadharCardURL':
            state.companyPartner[i].aadharCardURL.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].PhotoURL':
            state.companyPartner[i].photoURL.toString(),
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < state.companyPartner.length; i++) {
      if (state.companyPartner[i].aadharCardFile != null) {
        for (
          int j = 0;
          j < state.companyPartner[i].aadharCardFile!.fileNameList.length;
          j++
        ) {
          if (state.companyPartner[i].aadharCardFile!.fileNameList[j].contains(
            "http",
          )) {
            continue;
          }
          fileList.add({
            "key": 'AddUpdateCompanyPartner[$i].AadharCardURL',
            "value": state.companyPartner[i].aadharCardFile!.fileBytesList[j],
            "fileName": state.companyPartner[i].aadharCardFile!.fileNameList[j],
          });
        }
      }

      if (state.companyPartner[i].panCardFile != null) {
        for (
          int j = 0;
          j < state.companyPartner[i].panCardFile!.fileNameList.length;
          j++
        ) {
          if (state.companyPartner[i].panCardFile!.fileNameList[j].contains(
            "http",
          )) {
            continue;
          }
          fileList.add({
            "key": 'AddUpdateCompanyPartner[$i].PanCardURL',
            "value": state.companyPartner[i].panCardFile!.fileBytesList[j],
            "fileName": state.companyPartner[i].panCardFile!.fileNameList[j],
          });
        }
      }
      if (state.companyPartner[i].photoFile != null) {
        for (
          int j = 0;
          j < state.companyPartner[i].photoFile!.fileNameList.length;
          j++
        ) {
          if (state.companyPartner[i].photoFile!.fileNameList[j].contains(
            "http",
          )) {
            continue;
          }
          fileList.add({
            "key": 'AddUpdateCompanyPartner[$i].PhotoURL',
            "value": state.companyPartner[i].photoFile!.fileBytesList[j],
            "fileName": state.companyPartner[i].photoFile!.fileNameList[j],
          });
        }
      }
    }

    for (int i = 0; i < gstCertificateFile.fileNameList.length; i++) {
      if (gstCertificateFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "GSTCertificateURL",
        "value": gstCertificateFile.fileBytesList[i],
        "fileName": gstCertificateFile.fileNameList[i],
      });
    }

    for (int i = 0; i < panCardFile.fileNameList.length; i++) {
      if (panCardFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PanCardURL",
        "value": panCardFile.fileBytesList[i],
        "fileName": panCardFile.fileNameList[i],
      });
    }

    for (int i = 0; i < cinFile.fileNameList.length; i++) {
      if (cinFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "CINURL",
        "value": cinFile.fileBytesList[i],
        "fileName": cinFile.fileNameList[i],
      });
    }

    for (int i = 0; i < companyLetterheadHeaderFile.fileNameList.length; i++) {
      if (companyLetterheadHeaderFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "CompanyLetterheadHeaderURL",
        "value": companyLetterheadHeaderFile.fileBytesList[i],
        "fileName": companyLetterheadHeaderFile.fileNameList[i],
      });
    }

    for (int i = 0; i < companyLetterheadFooterFile.fileNameList.length; i++) {
      if (companyLetterheadFooterFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "CompanyLetterheadFooterURL",
        "value": companyLetterheadFooterFile.fileBytesList[i],
        "fileName": companyLetterheadFooterFile.fileNameList[i],
      });
    }
    var addResult = await _companyMasterRepository.addUpdateCompanyList(
      body: requestBody,
      fileList: fileList,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            stateType: StateType.companyPartnerLoading,
          ),
        );
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            stateType: StateType.companyPartnerLoading,
            companyPartner: [],
          ),
        );
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Company added successfully");
      },
    );
  }

  // <---- UPDATE COMPANY AFTER EDIT ---->
  void updateCompany(CompanyModel company, int index) {
    final updatedList = List<CompanyModel>.from(state.companyList);
    updatedList[index] = company;
    emit(state.copyWith(companyList: updatedList));
  }

  // <---- PREFILL COMPANY DATA ---->
  void prefillData(CompanyModel data) {
    emit(
      state.copyWith(
        isLoading: true,
        stateType: StateType.companyPartnerLoading,
      ),
    );
    emit(
      state.copyWith(
        isLoading: false,
        stateType: StateType.companyPartnerLoading,
        companyPartner: data.companyPartnerData,
      ),
    );
  }

  // <---- SEARCH COMPANY ---->
  Future searchCompany(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, companyList: []));
    await getCompanyMaster(context, 1);
  }

  // <---- SORT COMPANY ---->
  Future sortCompany(
    BuildContext context,
    String value,
    String direction,
  ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        companyList: [],
      ),
    );
    await getCompanyMaster(context, 1);
  }

  // <---- EXPORT EXCEL OR PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _companyMasterRepository.exportCompany(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"CompanyName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "company_${DateTime.now()}.pdf"
              : "company_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
