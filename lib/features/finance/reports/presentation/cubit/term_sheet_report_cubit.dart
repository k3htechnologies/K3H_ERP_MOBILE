import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/reports/data/model/term_sheet_report.model.dart';
import 'package:k3h_erp_app/features/finance/reports/data/repository/term_sheet_report.repository.dart';
import 'package:k3h_erp_app/features/finance/reports/presentation/cubit/term_sheet_report_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TermSheetReportCubit extends Cubit<TermSheetReportState> {
  TermSheetReportCubit() : super(TermSheetReportState.initial());
  // REPOSITORIES
  final TermSheetReportRepository _termSheetReportRepository =
      serviceLocator<TermSheetReportRepository>();
  Future searchTermSheetReport(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, termSheetReportList: []));
    await getTermSheetReportList(context, 1);
  }

  Future getTermSheetReportList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ProjectName": state.searchText,
      "CompanyName": state.filterByCompanyName,
      "ApprovalStatus": state.filterByStatus,
      "NameOfInstitutionBankNBFC": state.filterByInstitutionName,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _termSheetReportRepository.pullTermSheetReport(
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
        final List<TermSheetReportModel> newData =
            List<TermSheetReportModel>.from(response['data'] ?? []);
        final List<TermSheetReportModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.termSheetReportList, ...newData];
        emit(
          state.copyWith(
            termSheetReportList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, 'Error', 'No Data Found');
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _termSheetReportRepository.pullTermSheetReportForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {
        "ProjectName": state.searchText,
        "CompanyName": state.filterByCompanyName,
        "ApprovalStatus": state.filterByStatus,
        "NameOfInstitutionBankNBFC": state.filterByInstitutionName,
        "ExportType": exportType,
        "IsCheckPermission": true,
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
              ? "TermSheetReport Master ${DateTime.now()}.pdf"
              : "TermSheetReport Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future<void> applyTermSheetReportFilter({
    required BuildContext context,
    String? projectName,
    String? companyName,
    String? status,
    String? institutionName,
    bool? isClear,
    String? sortColumn,
    String? sortDirection,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByCompanyName: "",
          filterByStatus: "",
          filterByInstitutionName: "",
          currentSortColumn: "",
          currentSortDirection: "",
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: projectName ?? state.searchText,
          filterByCompanyName: companyName ?? state.filterByCompanyName,
          filterByStatus: status ?? state.filterByStatus,
          filterByInstitutionName:
              institutionName ?? state.filterByInstitutionName,
          termSheetReportList: [],
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
        ),
      );
    }
    await getTermSheetReportList(context, 1);
  }

  int updateFilterCount(TermSheetReportState state) {
    final hasSort =
        state.currentSortColumn == "Name Of Institution / Bank / NBFC" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByCompanyName.trim().isNotEmpty,
      state.filterByInstitutionName.trim().isNotEmpty,
      state.filterByStatus.trim().isNotEmpty,
      hasSort,
    ]);
  }
}
