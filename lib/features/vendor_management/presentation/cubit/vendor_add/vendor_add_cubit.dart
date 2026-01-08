import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/repository/vendor.repository.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

part 'vendor_add_state.dart';

class VendorAddCubit extends Cubit<VendorAddState> {
  VendorAddCubit() : super(VendorAddState.initial());

  VendorRepository vendorRepository = serviceLocator<VendorRepository>();

  UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

  // <---- DROPDOWN FUNCTIONS ---->
  Future<Map<String, dynamic>> getMaterialSubMaterialUOMMaster(
    BuildContext context,
  ) async {
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

  // <---- ADD VENDOR  ---->
  Future addVendor({
    required BuildContext context,
    required String companyName,
    required String companyType,
    required String vendorName,
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
      "VendorName": vendorName,
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
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Vendor Added Successfully!!!');
      },
    );
  }

  // <---- UPDATE VENDOR  ---->
  Future updateVendor({
    required int index,
    required VendorModel? vendor,
    required BuildContext context,
    required String companyName,
    required String companyType,
    required String vendorName,
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
      "VendorId": vendor!.vendorId.toString(),
      "UniqueKey": vendor.uniquekey,
      "CompanyName": companyName,
      "CompanyType": companyType,
      "VendorName": vendorName,
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
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedVendor = response['data'][0] as VendorModel;

        context.read<VendorCubit>().updateVendorInList(
          updatedVendor,
          index,
        );

        showSuccessMessage(context, subTitle: 'Vendor Updated Successfully!!!');
      },
    );
  }
}
