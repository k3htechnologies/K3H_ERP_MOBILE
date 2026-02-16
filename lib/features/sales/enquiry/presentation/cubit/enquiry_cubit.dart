import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/models/village.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'enquiry_state.dart';

class EnquiryCubit extends Cubit<EnquiryState> {
  EnquiryCubit() : super(EnquiryState.initial());

  // REPOSITORIES
  final EnquiryRepository _enquiryRepository =
      serviceLocator<EnquiryRepository>();

  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // <---- GET ENQUIRY LIST ---->
  Future getEnquiryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"Name": state.searchText};
    var result = await _enquiryRepository.getEnquiryList(
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
        final List<EnquiryModel> newData = List<EnquiryModel>.from(
          response['data'] ?? [],
        );

        final List<EnquiryModel> updatedList =
            pageNumber == 1 ? newData : [...state.enquiryList, ...newData];
        emit(
          state.copyWith(
            enquiryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addUpdateEnquiry({
    required BuildContext context,

    int? index,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _enquiryRepository.addUpdateEnquiry(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final newItem = response['data'][0] as EnquiryModel;

        List<EnquiryModel> updatedList = List.from(state.enquiryList);

        if (index != null) {
          updatedList[index] = newItem;
        }

        emit(
          state.copyWith(
            enquiryList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );

        showSuccessMessage(
          context,
          subTitle:
              index != null
                  ? 'Enquiry Updated Successfully'
                  : 'Enquiry Added Successfully',
        );
      },
    );
  }

  // FETCH CHANNEL PARTNER LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchChannelPartners(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _channelPartnerRepository.getChannelPartnerList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "ChannelPartnerName": value ?? "",
        "SortBy": "ChannelPartnerName ASC",
      },
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final partners = response['data'] as List<ChannelPartnerModel>;

        return {
          "itemList":
              partners.map((partner) {
                return {
                  "zAttributesId": partner.channelPartnerId,
                  "DisplayName": partner.name,
                  "ChannelPartnerMobileNumber": partner.mobileNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH EMPLOYEES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "DepartmentName": "Sale"}
              : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future<Map<String, dynamic>> fetchVillages(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _enquiryRepository.getVillageList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"VillageName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final villages = response['data'] as List<VillageModel>;

        return {
          "itemList":
              villages.map((village) {
                return {
                  "zAttributesId": village.villageMasterId,
                  "DisplayName": village.villageName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void search(BuildContext context, String searchText) {
    emit(state.copyWith(searchText: searchText.trim()));
    getEnquiryList(context, 1, getProject().projectId);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _enquiryRepository.exportEnquiry(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: getProject().projectId,
      queryParams:
          state.searchText != ""
              ? {"Name": state.searchText, "ExportType": exportType}
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
              ? "enquiry_${DateTime.now().millisecondsSinceEpoch}.pdf"
              : "enquiry_${DateTime.now().millisecondsSinceEpoch}.xlsx",
        );
      },
    );
  }
}
