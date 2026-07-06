import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/model/sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/repository/sourcing.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'sourcing_state.dart';

class SourcingCubit extends Cubit<SourcingState> {
  SourcingCubit() : super(SourcingState.initial());

  // REPOSITORIES
  final SourcingRepository _sourcingRepository =
      serviceLocator<SourcingRepository>();

  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();

  // ON TAB CHANGE
  void onTabChanged(
    int index,
    BuildContext context, {
    required int channelPartnerId,
    required int projectId,
  }) {
    emit(state.copyWith(currentTabIndex: index));
    if (index == 1) {
      getSourcingList(context, 1, channelPartnerId, projectId);
    }
  }

  void onFilterChanged(String value) {
    emit(state.copyWith(selectedFilter: value));
  }

  // SEARCH CHANNEL PARTNER
  Future searchChannelPartner(
    BuildContext context,
    String value, {
    required int projectId,
  }) async {
    emit(state.copyWith(searchText: value, channelPartnerList: []));
    await getChannelPartnerList(context, 1, projectId);
  }

  Future clearSourcingList() async {
    emit(state.copyWith(sourcingList: []));
  }

  // FILTER CP SOURCING
  Future applyChannelPartnerSourcingFilterAndSort({
    required BuildContext context,
    required int projectId,
    String? companyName,
    String? designation,
    String? firmType,
    String? type,
    String? cpCode,
    String? mobileNumber,
    String? officeAddress,
    String? gstNumber,
    String? reraNumber,
    String? panNumber,
    String? aadhaarNumber,
    String? speciality,
    String? city,
    String? village,
    String? name,
    String? noOfIBM,
    String? noOfOBM,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          filterByCompanyName: "",
          filterByDesignation: "",
          filterByFirmType: "",
          filterByType: "",
          filterCPCode: "",
          filterByCPName: "",
          filterByOfficeAddress: "",
          filterByGSTNumber: "",
          filterByRERANumber: "",
          filterByPANNumber: "",
          filterByAadhaarNumber: "",
          filterBySpeciality: "",
          filterByCity: "",
          filterByVillage: "",
          searchText: "",
          currentSortColumn: "",
          currentSortDirection: "",
          filterByNoOfIBM: "",
          filterByNoOfOBM: "",
          currentPageCp: 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: mobileNumber ?? state.searchText,

          filterByCompanyName: companyName ?? state.filterByCompanyName,
          filterByDesignation: designation ?? state.filterByDesignation,
          filterByFirmType: firmType ?? state.filterByFirmType,
          filterByType: type ?? state.filterByType,
          filterCPCode: cpCode ?? state.filterCPCode,
          filterByCPName: name ?? state.filterByCPName,
          filterByOfficeAddress: officeAddress ?? state.filterByOfficeAddress,
          filterByGSTNumber: gstNumber ?? state.filterByGSTNumber,
          filterByRERANumber: reraNumber ?? state.filterByRERANumber,
          filterByPANNumber: panNumber ?? state.filterByPANNumber,
          filterByAadhaarNumber: aadhaarNumber ?? state.filterByAadhaarNumber,
          filterBySpeciality: speciality ?? state.filterBySpeciality,
          filterByCity: city ?? state.filterByCity,
          filterByVillage: village ?? state.filterByVillage,
          filterByNoOfIBM: noOfIBM ?? state.filterByNoOfIBM,
          filterByNoOfOBM: noOfOBM ?? state.filterByNoOfOBM,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,

          currentPageCp: 1,
        ),
      );
    }

    await getChannelPartnerList(context, 1, projectId);
  }

  // GET SOURCING LIST
  Future getSourcingList(
    BuildContext context,
    int pageNumber,
    int channelPartnerId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true, sourcingList: []));
    Map<String, dynamic> queryParams = {
      "ChannelPartnerId": channelPartnerId,
      "ProjectId": projectId,
    };
    var result = await _sourcingRepository.getSourcingList(
      pageNumber: pageNumber,
      pageSize: 500,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SourcingModel> newData = List<SourcingModel>.from(
          response['data'] ?? [],
        );

        final List<SourcingModel> updatedList =
            pageNumber == 1 ? newData : [...state.sourcingList, ...newData];
        emit(state.copyWith(sourcingList: updatedList, isLoading: false));
      },
    );
  }

  // GET CHANNEL PARTNER LIST
  Future getChannelPartnerList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "IsCheckPermission": false,
      "MobileNumber": state.searchText,
      "CompanyName": state.filterByCompanyName,
      "Designation": state.filterByDesignation,
      "FirmsType": state.filterByFirmType,
      "SystemGeneratedCode": state.filterCPCode,
      "Type": state.filterByType,
      "ChannelPartnerName": state.filterByCPName,
      "OfficeAddress": state.filterByOfficeAddress,
      "GSTNumber": state.filterByGSTNumber,
      "RERANumber": state.filterByRERANumber,
      "PanNumber": state.filterByPANNumber,
      "AadharCardNumber": state.filterByAadhaarNumber,
      "Speciality": state.filterBySpeciality,
      "CityName": state.filterByCity,
      "VillageName": state.filterByVillage,
      "NoOfIBM": state.filterByNoOfIBM,
      "NoOfOBM": state.filterByNoOfOBM,
      "ProjectId": projectId,
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
            totalNumberOfRecordCP: response["totalNumberOfRecord"],
            currentPageCp: pageNumber,
          ),
        );
      },
    );
  }

  // ADD REMARK
  Future addRemark({
    required BuildContext context,
    required int channelPartnerId,
    required String type,
    required int projectId,
    required String remark,
    required String support,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ChannelPartnerId": channelPartnerId,
      "ChannelPartnerSourcingId": 0,
      "IBM_OBM": type,
      "Support": support,
      "ProjectId": projectId,
      "SourcingRemark": remark,
      "SourcingLatitude": 0,
      "SourcingLongitude": 0,
      "SourcingLocation": "string",
    };
    var addResult = await _sourcingRepository.addUpdateSourcing(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Remark Added Successfully!!!');
        getSourcingList(context, 1, channelPartnerId, projectId);
      },
    );
  }

  // UPDATE REMARK
  Future updateRemark({
    required BuildContext context,
    required int channelPartnerSourcingId,
    required String uniqueKey,
    required int channelPartnerId,
    required String type,
    required int projectId,
    required String remark,
    required String support,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ChannelPartnerId": channelPartnerId,
      "ChannelPartnerSourcingId": channelPartnerSourcingId,
      "Uniquekey": uniqueKey,
      "IBM_OBM": type,
      "Support": support,
      "ProjectId": projectId,
      "SourcingRemark": remark,
      "SourcingLatitude": 0,
      "SourcingLongitude": 0,
      "SourcingLocation": "string",
    };
    var updateResult = await _sourcingRepository.addUpdateSourcing(
      body: requestBody,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(context, subTitle: 'Remark Updated Successfully!!!');

        getSourcingList(context, 1, channelPartnerId, projectId);
      },
    );
  }

  // DELETE REMARK
  Future deleteDepartmentMaster({
    required BuildContext context,
    required int channelPartnerSourcingId,
    required int channelPartnerId,
    required int projectId,
    required String uniqueKey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _sourcingRepository.deleteSourcing(
      channelPartnerSourcingId: channelPartnerSourcingId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Department Deleted Successfully!!!',
        );
        getSourcingList(context, 1, channelPartnerId, projectId);
      },
    );
  }

  int updateFilterCount() {
    final hasSort =
        (state.currentSortColumn == "Full Name") &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByCompanyName.trim().isNotEmpty,
      state.filterByDesignation.trim().isNotEmpty,
      state.filterByFirmType.trim().isNotEmpty,
      state.filterByType.trim().isNotEmpty,
      state.filterCPCode.trim().isNotEmpty,
      state.filterByCPName.trim().isNotEmpty,
      state.filterByOfficeAddress.trim().isNotEmpty,
      state.filterByGSTNumber.trim().isNotEmpty,
      state.filterByRERANumber.trim().isNotEmpty,
      state.filterByPANNumber.trim().isNotEmpty,
      state.filterByAadhaarNumber.trim().isNotEmpty,
      state.filterBySpeciality.trim().isNotEmpty,
      state.filterByCity.trim().isNotEmpty,
      state.filterByVillage.trim().isNotEmpty,
      state.filterByNoOfIBM.trim().isNotEmpty,
      state.filterByNoOfOBM.trim().isNotEmpty,
      hasSort,
    ]);
  }
}
