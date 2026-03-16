import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'channel_partner_state.dart';

class ChannelPartnerCubit extends Cubit<ChannelPartnerState> {
  ChannelPartnerCubit() : super(ChannelPartnerState.initial());

  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();

  void resetSearch() {
    emit(state.copyWith(searchText: ""));
  }

  // <---- SEARCH CHANNEL PARTNER ---->
  Future searchChannelPartner(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, channelPartnerList: []));
    await getChannelPartnerList(context, 1);
  }

  // <---- GET CHANNEL PARTNER LIST ---->
  Future getChannelPartnerList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ChannelPartnerName": state.searchText,
      "CompanyName": state.filterByCompanyName,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _channelPartnerRepository.getChannelPartnerList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ChannelPartnerModel> newData =
            List<ChannelPartnerModel>.from(response['data'] ?? []);

        final List<ChannelPartnerModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.channelPartnerList, ...newData];
        emit(
          state.copyWith(
            channelPartnerList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD CHANNEL PARTNER ---->
  Future addChannelPartner({
    required BuildContext context,
    required int channelPartnerId,
    required String name,
    required String companyName,
    required String firmsType,
    required String type,
    required String designation,
    required String emailId,
    required String mobileNumber,
    required String alternativeMobileNumber,
    required String panCardNumber,
    required MultiFilePickerModel panCardURL,
    required String aadhaarCardNumber,
    required MultiFilePickerModel aadhaarCardURL,
    required String gstNumber,
    required MultiFilePickerModel gstCertificateURL,
    required String speciality,
    required String officeAddress,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required int selectedVillageId,
    required String reraNumber,
    required String otp,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "ChannelPartnerId": channelPartnerId.toString(),
      "Name": name,
      "CompanyName": companyName,
      "FirmsType": firmsType,
      "Type": type,
      "Designation": designation,
      "EmailId": emailId,
      "MobileNumber": mobileNumber,
      "AlternativeMobileNumber": alternativeMobileNumber,
      "PanNumber": panCardNumber,
      "AadharCardNumber": aadhaarCardNumber,
      "GSTNumber": gstNumber,
      "Speciality": speciality,
      "OfficeAddress": officeAddress,
      "CountryMasterId": selectedCountryNameId.toString(),
      "StateMasterId": selectedStateId.toString(),
      "DistrictMasterId": selectedDistrictId.toString(),
      "CityMasterId": selectedCityId.toString(),
      "VillageMasterId": selectedVillageId.toString(),
      "RERANumber": reraNumber,
      "OTP": otp,
    };

    List<Map<String, dynamic>> fileList = [];

    // PAN
    for (int i = 0; i < panCardURL.fileNameList.length; i++) {
      if (panCardURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "PanCardURL",
        "value": panCardURL.fileBytesList[i],
        "fileName": panCardURL.fileNameList[i],
      });
    }

    // AADHAR
    for (int i = 0; i < aadhaarCardURL.fileNameList.length; i++) {
      if (aadhaarCardURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AadharCardURL",
        "value": aadhaarCardURL.fileBytesList[i],
        "fileName": aadhaarCardURL.fileNameList[i],
      });
    }

    // GST Certificate
    for (int i = 0; i < gstCertificateURL.fileNameList.length; i++) {
      if (gstCertificateURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "GSTCertificateURL",
        "value": gstCertificateURL.fileBytesList[i],
        "fileName": gstCertificateURL.fileNameList[i],
      });
    }

    final result = await _channelPartnerRepository.addUpdateChannelPartner(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        getChannelPartnerList(context, 1);
        //close verfication popup
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Channel Partner Added Successfully',
        );
        goRouter.pop();
      },
    );
  }

  // <---- ADD CHANNEL PARTNER ---->
  Future updateChannelPartner({
    required BuildContext context,
    required int channelPartnerId,
    required int index,
    required String uniqueKey,
    required String name,
    required String emailId,
    required String mobileNumber,
    required String panCardNumber,
    required MultiFilePickerModel panCardURL,
    required String aadhaarCardNumber,
    required MultiFilePickerModel aadhaarCardURL,
    required String speciality,
    required String officeAddress,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required int selectedVillageId,
    required String reraNumber,
    required String companyName,
    required String firmsType,
    required String type,
    required String designation,
    required String alternativeMobileNumber,
    required String gstNumber,
    required MultiFilePickerModel gstCertificateURL,
    required String otp,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> body = {
      "ChannelPartnerId": channelPartnerId.toString(),
      "Uniquekey": uniqueKey,
      "Name": name,
      "EmailId": emailId,
      "MobileNumber": mobileNumber,
      "PanNumber": panCardNumber,
      "AadharCardNumber": aadhaarCardNumber,
      "Speciality": speciality.toString(),
      "OfficeAddress": officeAddress,
      "CountryMasterId": selectedCountryNameId.toString(),
      "StateMasterId": selectedStateId.toString(),
      "DistrictMasterId": selectedDistrictId.toString(),
      "CityMasterId": selectedCityId.toString(),
      "RERANumber": reraNumber,
      "CompanyName": companyName,
      'VillageMasterId': selectedVillageId.toString(),
      "FirmsType": firmsType,
      "Type": type,
      "Designation": designation,
      "AlternativeMobileNumber": alternativeMobileNumber,
      "GSTNumber": gstNumber,
      "OTP": otp,
    };
    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < panCardURL.fileNameList.length; i++) {
      if (panCardURL.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PanCardURL",
        "value": panCardURL.fileBytesList[i],
        "fileName": panCardURL.fileNameList[i],
      });
    }
    for (int i = 0; i < aadhaarCardURL.fileNameList.length; i++) {
      if (aadhaarCardURL.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "AadharCardURL",
        "value": aadhaarCardURL.fileBytesList[i],
        "fileName": aadhaarCardURL.fileNameList[i],
      });
    }
    final result = await _channelPartnerRepository.addUpdateChannelPartner(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        final updatedChannelPartner =
            (response['data'] as List<ChannelPartnerModel>).first;

        if (state.channelPartnerList.isNotEmpty &&
            index < state.channelPartnerList.length) {
          final updatedList = List<ChannelPartnerModel>.from(
            state.channelPartnerList,
          );

          updatedList[index] = updatedChannelPartner;

          emit(
            state.copyWith(isLoading: false, channelPartnerList: updatedList),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Channel Partner Updated Successfully',
        );
      },
    );
  }

  // <---- DELETE CHANNEL PARTNER ---->
  Future deleteChannelPartner(
    int index,
    ChannelPartnerModel channelPartnerModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _channelPartnerRepository.deleteChannelPartner(
      channelPartnerId: channelPartnerModel.channelPartnerId,
      uniqueKey: channelPartnerModel.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<ChannelPartnerModel>.from(
          state.channelPartnerList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            channelPartnerList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Channel Partner Deleted Successfully",
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _channelPartnerRepository.exportChannelPartner(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {
                "ChannelPartnerName": state.searchText,
                "ExportType": exportType,
              }
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
              ? "channel_partner_${DateTime.now()}.pdf"
              : "channel_partner_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
