import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/models/village.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry_followup.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/repository/enquiry.repository.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class EnquiryCubit extends Cubit<EnquiryState> {
  // INITIAL STATE
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
    Map<String, dynamic> queryParams = {
      "Name": state.searchText.trim(),
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
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

  // <---- ADD / UPDATE ENQUIRY ---->

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
        final newItem = response['data'][0] as EnquiryModel;

        List<EnquiryModel> updatedList = List.from(state.enquiryList);

        if (index != null) {
          updatedList[index] = newItem;
        } else {
          getEnquiryList(context, 1, getProject().projectId);
        }

        emit(state.copyWith(enquiryList: updatedList));
        goRouter.pop();
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

  // <---- CLEAR CHANNEL PARTNER MODEL ---->
  void clearChannelPartner() {
    emit(state.copyWith(clearChannelPartner: true, selectedNationality: null));
  }

  // <---- CLEAR ENQUIRY FOLLOWUP ---->
  void clearEnquiryFollowUp() {
    emit(state.copyWith(enquiryFollowUpList: [], isLoading: true));
  }

  // FETCH CHANNEL PARTNER LIST FOR DROPDOWN
  Future<List<ChannelPartnerModel>> fetchChannelPartners(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _channelPartnerRepository.getChannelPartnerList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {"MobileNumber": value ?? "", "SortBy": "MobileNumber ASC"},
    );

    return result.fold((failure) => [], (response) {
      final partners = response['data'] as List<ChannelPartnerModel>;

      ///  Auto store first partner when searching by mobile
      if (partners.isNotEmpty && value != null && value.isNotEmpty) {
        emit(state.copyWith(channelPartnerModel: partners.first));
      }

      return partners;
    });
  }

  // FETCH EMPLOYEES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchEmployees(
    int pageNumber, {
    String? value,
    int? employeeId,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (employeeId != null && employeeId != 0) {
      // FETCH BY
      queryParams["EmployeeId"] = employeeId;
    } else if (value != null && value.isNotEmpty) {
      // FETCH BY NAME (SEARCH)
      queryParams["EmployeeName"] = value;
      queryParams["DepartmentName"] = "Sale";
    }

    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams: queryParams,
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
                  "MobileNo": employee.personalMobileNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH VILLAGES LIST FOR DROPDOWN
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

  // SEARCH
  void search(BuildContext context, String searchText) {
    emit(state.copyWith(searchText: searchText.trim()));
    getEnquiryList(context, 1, getProject().projectId);
  }

  // NATIONALITY SELECTION FOR RADIO BUTTONS
  void onSelectedOptionChanged(String value) {
    emit(state.copyWith(selectedNationality: value));
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

  // <---- GET ENQUIRY FOLLOWUPS ---->
  Future<void> fetchEnquiryFollowUps({
    required int enquiryId,

    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _enquiryRepository.getEnquiryFollowUpList(
      pageNumber: 1,
      pageSize: 100,
      enquiryId: enquiryId,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, enquiryFollowUpList: []));
      },
      (response) {
        final followUps = response['data'] as List<EnquiryFollowUpModel>;
        emit(state.copyWith(isLoading: false, enquiryFollowUpList: followUps));
      },
    );
  }

  // <---- ADD / UPDATE ENQUIRY FOLLOWUPS ---->
  Future addUpdateEnquiryFollowUp({
    required BuildContext context,
    int? index,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _enquiryRepository.addUpdateEnquiryFollowUp(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final newItem = response['data'][0] as EnquiryFollowUpModel;

        List<EnquiryFollowUpModel> updatedList = List.from(
          state.enquiryFollowUpList,
        );

        if (index != null) {
          updatedList[index] = newItem;
        } else {
          fetchEnquiryFollowUps(
            enquiryId: newItem.enquiryId,
            projectId: getProject().projectId,
          );
        }

        emit(state.copyWith(enquiryFollowUpList: updatedList));

        showSuccessMessage(
          context,
          subTitle:
              index != null
                  ? 'Enquiry FollowUp Updated Successfully'
                  : 'Enquiry FollowUp Added Successfully',
        );
      },
    );
  }

  // <---- DELETE ENQUIRY FOLLOWUP ---->
  Future<void> deleteFollowUp({
    required int index,
    required EnquiryFollowUpModel followUpModel,
    required int enquiryId,

    required BuildContext context,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _enquiryRepository.deleteEnquiryFollowUp(
      followUpId: followUpModel.enquiryFollowUpId,
      uniqueKey: followUpModel.uniquekey,
      enquiryId: enquiryId,
      projectId: getProject().projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        final updatedList = List<EnquiryFollowUpModel>.from(
          state.enquiryFollowUpList,
        );
        updatedList.removeAt(index);

        emit(
          state.copyWith(enquiryFollowUpList: updatedList, isLoading: false),
        );

        showSuccessMessage(context, subTitle: "Follow-Up Deleted Successfully");
      },
    );
  }
}
