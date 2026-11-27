import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/model/tax_tracker.model.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/repository/tax_tracker.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'tax_tracker_state.dart';

class TaxTrackerCubit extends Cubit<TaxTrackerState> {
  TaxTrackerCubit() : super(TaxTrackerState.initial());

  // REPOSITORY
  final TaxTrackerRepository _taxTrackerRepository =
      serviceLocator<TaxTrackerRepository>();

  Future searchTaxTracker(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, taxTrackerList: [], currentPage: 1));
    await getTaxTrackerList(context, 1);
  }

  Future applyTaxTrackerFilterAndSort({
    required BuildContext context,
    String? noticeTitle,
    String? authority,
    String? financialYear,
    int? company,
    String? governmentCompliance,
    String? sortColumn,
    String? sortDirection,
    DateTime? filterByFromDate,
    DateTime? filterByToDate,
    String? callLogStatus,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByNoticeTitle: "",
          filterByAuthority: "",
          filterByFinancialYear: "",
          filterByCompany: 0,
          filterByGovernmentCompliance: "",
          currentSortColumn: "Created Date",
          currentSortDirection: "DESC",
          filterByFromDate: null,
          filterByToDate: null,
          filterCallStatus: "",
          taxTrackerList: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: noticeTitle ?? state.searchText,
          filterByAuthority: authority ?? state.filterByAuthority,
          filterByFinancialYear: financialYear ?? state.filterByFinancialYear,
          filterByCompany: company ?? state.filterByCompany,
          filterByGovernmentCompliance:
              governmentCompliance ?? state.filterByGovernmentCompliance,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          taxTrackerList: [],
          filterByFromDate: filterByFromDate,
          filterByToDate: filterByToDate,
          filterCallStatus: callLogStatus ?? state.filterCallStatus,
        ),
      );
    }
    await getTaxTrackerList(context, 1);
  }

  int updateTaxTrackerFilterCount(TaxTrackerState state) {
    final hasSort =
        state.currentSortColumn == "Notice Title" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByNoticeTitle.trim().isNotEmpty,
      state.filterByAuthority.trim().isNotEmpty,
      state.filterByFinancialYear.trim().isNotEmpty,
      state.filterByCompany != 0,
      state.filterByGovernmentCompliance.trim().isNotEmpty,
      state.filterByFromDate != null,
      state.filterByToDate != null,
      state.filterCallStatus.trim().isNotEmpty,
      hasSort,
    ]);
  }

  Future getTaxTrackerList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    var result = await _taxTrackerRepository.getTaxTrackerList(
      pageSize: 10,
      pageNumber: pageNumber,
      queryParams: {
        "NoticeType": state.searchText,
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
        "Authority": state.filterByAuthority,
        "FinancialYear": state.filterByFinancialYear,
        "CompanyId": state.filterByCompany,
        "GovernmentCompliance": state.filterByGovernmentCompliance,
        "FromNoticeDate": state.filterByFromDate.apiDate,
        "ToNoticeDate": state.filterByToDate.apiDate,
        "NoticeStatus": state.filterCallStatus,
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<TaxTrackerModel> newList =
            response['data'] as List<TaxTrackerModel>;

        final updatedList =
            pageNumber == 1 ? newList : [...state.taxTrackerList, ...newList];

        emit(
          state.copyWith(
            taxTrackerList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future addTaxTrackerRequest({
    required BuildContext context,
    required int taxTrackerId,
    String? authorityType,
    required String requestType,
    required String noticeDescription,
    String? officerName,
    String? officerAddress,
    DateTime? amountUnderDisputeDate,
    double? amountUnderDispute,
    DateTime? dateOfAppeal,
    String? orderStatus,
    String? noticeStatus,
    required MultiFilePickerModel noticeDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "TaxTrackerId": taxTrackerId.toString(),
      "AuthorityType": authorityType.toString(),
      "RequestType": requestType,
      "NoticeDescription": noticeDescription,
      "OfficerName": officerName.toString(),
      "OfficerAddress": officerAddress.toString(),
      "AmountUnderDisputeDate": amountUnderDisputeDate.apiDate.toString(),
      "AmountUnderDispute": amountUnderDispute.toString(),
      "DateOfAppeal": dateOfAppeal.apiDate.toString(),
      "OrderStatus": orderStatus.toString(),
      "NoticeStatus": noticeStatus.toString(),
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < noticeDocument.fileBytesList.length; i++) {
      if (noticeDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "NoticeDocumentURL",
        "value": noticeDocument.fileBytesList[i],
        "fileName": noticeDocument.fileNameList[i],
      });
    }

    var addResult = await _taxTrackerRepository.addUpdateTaxTrackerDocument(
      body: requestBody,
      fileList: fileList,
    );

    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getTaxTrackerList(context, 1);
      },
    );
  }

  Future addTaxTracker({
    required BuildContext context,
    required String governmentCompliance,
    required int companyId,
    required String financialYear,
    required int responsiblePersonId,
    required String noticeType,
    required int noticeSectionMasterId,
    required String authority,
    required DateTime? noticeDate,
    required DateTime? dueDate,
    required String officerName,
    required String officerAddress,
    required String noticeDescription,
    required String requestType,
    required String noticeStatus,
    required MultiFilePickerModel noticeDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "GovernmentCompliance": governmentCompliance.toString(),
      "CompanyId": companyId.toString(),
      "FinancialYear": financialYear,
      "ResponsiblePersonId": responsiblePersonId.toString(),
      "NoticeType": noticeType,
      "NoticeSectionMasterId": noticeSectionMasterId.toString(),
      "Authority": authority.toString(),
      "NoticeDate": noticeDate.apiDate!,
      "DueDate": dueDate.apiDate!,
      "OfficerName": officerName,
      "OfficerAddress": officerAddress,
      "NoticeDescription": noticeDescription,
      "RequestType": requestType,
      "NoticeStatus": noticeStatus,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < noticeDocument.fileBytesList.length; i++) {
      if (noticeDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "NoticeDocumentURL",
        "value": noticeDocument.fileBytesList[i],
        "fileName": noticeDocument.fileNameList[i],
      });
    }

    var addResult = await _taxTrackerRepository.addUpdateTaxTracker(
      body: requestBody,
      fileList: fileList,
    );

    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getTaxTrackerList(context, 1);
      },
    );
  }

  Future updateTaxTracker({
    required BuildContext context,
    required int index,
    required int taxTrackerId,
    required String uniquekey,
    required String governmentCompliance,
    required int companyId,
    required String financialYear,
    required int responsiblePersonId,
    required String noticeType,
    required int noticeSectionMasterId,
    required String authority,
    required DateTime? noticeDate,
    required DateTime? dueDate,
    required String officerName,
    required String officerAddress,
    required String noticeDescription,
    required String requestType,
    required String noticeStatus,
    required MultiFilePickerModel noticeDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "TaxTrackerId": taxTrackerId.toString(),
      "Uniquekey": uniquekey,
      "GovernmentCompliance": governmentCompliance.toString(),
      "CompanyId": companyId.toString(),
      "FinancialYear": financialYear,
      "ResponsiblePersonId": responsiblePersonId.toString(),
      "NoticeType": noticeType,
      "NoticeSectionMasterId": noticeSectionMasterId.toString(),
      "Authority": authority.toString(),
      "NoticeDate": noticeDate.apiDate!,
      "DueDate": dueDate.apiDate!,
      "OfficerName": officerName,
      "OfficerAddress": officerAddress,
      "NoticeDescription": noticeDescription,
      "RequestType": requestType,
      "NoticeStatus": noticeStatus,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < noticeDocument.fileBytesList.length; i++) {
      if (noticeDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "NoticeDocumentURL",
        "value": noticeDocument.fileBytesList[i],
        "fileName": noticeDocument.fileNameList[i],
      });
    }

    var addResult = await _taxTrackerRepository.addUpdateTaxTracker(
      body: requestBody,
      fileList: fileList,
    );

    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedTaxTracker = response['data'][0] as TaxTrackerModel;

        if (state.taxTrackerList.isNotEmpty &&
            index < state.taxTrackerList.length) {
          final updatedList = List<TaxTrackerModel>.from(state.taxTrackerList);
          updatedList[index] = updatedTaxTracker;
          emit(state.copyWith(taxTrackerList: updatedList, isLoading: false));
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }
}
