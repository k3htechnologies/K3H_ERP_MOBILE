import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/model/notice_section.model.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/repository/notice_section.repository.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/presentation/cubit/notice_section_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class NoticeSectionMasterCubit extends Cubit<NoticeSectionMasterState> {
  NoticeSectionMasterCubit() : super(NoticeSectionMasterState.initial());
  // REPOSITORIES
  final NoticeSectionMasterRepository _noticeSectionRepository =
      serviceLocator<NoticeSectionMasterRepository>();
  Future searchNoticeSection(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, noticeSectionList: []));
    await getNoticeSectionList(context, 1);
  }

  Future getNoticeSectionList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "NoticeSection": state.searchText,
      "GovernmentCompliance": state.filterByGovernmentCompliance,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _noticeSectionRepository.pullNoticeSection(
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
        final List<NoticeSectionModel> newData = List<NoticeSectionModel>.from(
          response['data'] ?? [],
        );
        final List<NoticeSectionModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.noticeSectionList, ...newData];
        emit(
          state.copyWith(
            noticeSectionList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addNoticeSectionMaster({
    required BuildContext context,
    required String noticeSection,
    required String governmentCompliance,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "NoticeSectionMasterId": 0,
      "GovernmentCompliance": governmentCompliance,
      "NoticeSection": noticeSection,
    };
    var addResult = await _noticeSectionRepository.addUpdateNoticeSection(
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
        showSuccessMessage(context, subTitle: response['message']);
        getNoticeSectionList(context, 1);
      },
    );
  }

  Future updateNoticeSectionMaster({
    required BuildContext context,
    required int noticeSectionMasterId,
    required String uniqueKey,
    required String noticeSection,
    required String governmentCompliance,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "NoticeSectionMasterId": noticeSectionMasterId,
      "Uniquekey": uniqueKey,
      "GovernmentCompliance": governmentCompliance,
      "NoticeSection": noticeSection,
    };
    var addResult = await _noticeSectionRepository.addUpdateNoticeSection(
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
        final updatedDepartment = response['data'][0] as NoticeSectionModel;

        if (state.noticeSectionList.isNotEmpty &&
            index < state.noticeSectionList.length) {
          final updatedList = List<NoticeSectionModel>.from(
            state.noticeSectionList,
          );
          updatedList[index] = updatedDepartment;
          emit(
            state.copyWith(noticeSectionList: updatedList, isLoading: false),
          );
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future<void> deleteNoticeSection({
    required BuildContext context,
    required int noticeSectionMasterId,
    required String uniqueKey,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _noticeSectionRepository.deleteNoticeSection(
      noticeSectionMasterId: noticeSectionMasterId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedList = List<NoticeSectionModel>.from(
          state.noticeSectionList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            noticeSectionList: updatedList,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: response["message"]);
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, 'Error', 'No Data Found');
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _noticeSectionRepository.pullNoticeSectionForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {
        "NoticeSection": state.searchText,
        "GovernmentCompliance": state.filterByGovernmentCompliance,
        "ExportType": exportType,
      },
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
              ? "Notice Section Master ${DateTime.now()}.pdf"
              : "Notice Section Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future applyFilterAndSortDepartment({
    required BuildContext context,
    required String column,
    required String direction,
    required String noticeSection,
    required String governmentCompliance,
  }) async {
    emit(
      state.copyWith(
        searchText: noticeSection,
        currentSortColumn: column,
        currentSortDirection: direction,
        filterByGovernmentCompliance: governmentCompliance,
        noticeSectionList: [],
      ),
    );
    await getNoticeSectionList(context, 1);
  }

  int updateFilterCount(NoticeSectionMasterState state) {
    final hasSort =
        state.currentSortColumn == "Notice Section" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      hasSort,
      state.searchText.trim().isNotEmpty,
      state.filterByGovernmentCompliance.isNotEmpty,
    ]);
  }
}
