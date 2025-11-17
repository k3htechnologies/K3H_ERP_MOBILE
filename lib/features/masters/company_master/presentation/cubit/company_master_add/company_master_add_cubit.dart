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

part 'company_master_add_state.dart';

class CompanyMasterAddCubit extends Cubit<CompanyMasterAddState> {
  CompanyMasterAddCubit() : super(CompanyMasterAddState.initial());

  // REPOSITORY
  final CompanyMasterRepository _companyMasterRepository =
  serviceLocator<CompanyMasterRepository>();

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
    DialogHelper.showProcessingDialog(context);

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
            errorMessage: failure.message,
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
        showSuccessMessage(context);
      },
    );
  }

  // <---- RESET COMPANY PARTNER ---->
  void resetCompanyPartner({List<CompanyPartnerModel>? companyPartner}) {
    emit(
      state.copyWith(
        isLoading: false,
        stateType: StateType.companyPartnerLoading,
        companyPartner: companyPartner ?? [],
      ),
    );
  }

  // <---- ADD UPDATE COMPANY PARTNER ---->
  void addUpdateCompanyPartnerData(
      CompanyPartnerModel companyData, {
        required BuildContext context,
        int? index,
      }) {
    List<CompanyPartnerModel> updatedList = List.from(state.companyPartner);
    if (index != null) {
      updatedList[index] = companyData;
    } else {
      updatedList.add(companyData);
    }
    emit(
      state.copyWith(
        isLoading: false,
        stateType: StateType.companyPartnerLoading,
        companyPartner: updatedList,
      ),
    );
  }

  // <---- DELETE COMPANY PARTNER ---->
  void deleteCompanyPartnerData(BuildContext context, int index) {
    final currentList = List<CompanyPartnerModel>.from(state.companyPartner);
    currentList.removeAt(index);

    emit(
      state.copyWith(
        isLoading: false,
        stateType: StateType.companyPartnerLoading,
        companyPartner: currentList,
      ),
    );
    showSuccessMessage(context);
  }

  // <---- UPDATE COMPANY ---->
  Future<void> updateCompanyMaster({
    required BuildContext context,
    required int companyId,
    required String uniquekey,
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
    DialogHelper.showProcessingDialog(context);
    Map<String, String> requestBody = {
      "CompanyId": companyId.toString(),
      "Uniquekey": uniquekey,
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
      "RemoveGSTCertificateURL": gstCertificateFile.deletedFileList,
      "RemovePanCardURL": panCardFile.deletedFileList,
      "RemoveCINURL": cinFile.deletedFileList,
      "RemoveCompanyLetterheadHeaderURL":
      companyLetterheadHeaderFile.deletedFileList,
      "RemoveCompanyLetterheadFooterURL":
      companyLetterheadFooterFile.deletedFileList,
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].CompanyPartnerId':
        state.companyPartner[i].companyPartnerId.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].Uniquekey':
        state.companyPartner[i].uniquekey.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].FirstName':
        state.companyPartner[i].firstName.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].LastName':
        state.companyPartner[i].lastName.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].MiddleName':
        state.companyPartner[i].middleName.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        'AddUpdateCompanyPartner[$i].DateOfBirth':
        state.companyPartner[i].dateOfBirth.toIso8601String(),
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
        'AddUpdateCompanyPartner[$i].AadharCardNumber':
        state.companyPartner[i].aadharCardNumber.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        if (state.companyPartner[i].aadharCardFile != null)
          'AddUpdateCompanyPartner[$i].RemoveAadharCardURL':
          state.companyPartner[i].aadharCardFile!.deletedFileList
              .toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        if (state.companyPartner[i].panCardFile != null)
          'AddUpdateCompanyPartner[$i].RemovePanCardURL':
          state.companyPartner[i].panCardFile!.deletedFileList.toString(),
      for (int i = 0; i < state.companyPartner.length; i++)
        if (state.companyPartner[i].photoFile != null)
          'AddUpdateCompanyPartner[$i].RemovePhotoURL':
          state.companyPartner[i].photoFile!.deletedFileList.toString(),
    };
    List<Map<String, dynamic>> fileList = [];

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
        goRouter.pop(response['data']);
        showSuccessMessage(context);
      },
    );
  }
}
