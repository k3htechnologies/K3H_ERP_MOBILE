import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/data/model/ibm_obm_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/ibm_obm/presentation/cubit/ibm_obm_report_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

import '../../data/repository/ibm_obm_report.repository.dart';

class IbmObmReportCubit extends Cubit<IbmObmReportState> {
  IbmObmReportCubit() : super(IbmObmReportState.initial());
  final IbmObmReportRepository ibmObmReportRepository =
      serviceLocator<IbmObmReportRepository>();

  void initializeViewFilters() {
    emit(
      state.copyWith(
        viewFilterByFromDate: state.filterByFromDate,
        viewFilterByToDate: state.filterByToDate,
        viewFilterByYear: state.filterByYear,
        viewFilterByReportType: state.filterByReportType,
        viewReportList: [],
      ),
    );
  }

  Future<void> getIbmObmReport({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    final bool shouldCallApi =
        state.filterByYear.isNotEmpty ||
        (state.filterByFromDate != null && state.filterByToDate != null);

    if (!shouldCallApi) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    var queryParams = {
      "EmployeeName": state.searchText.trim(),
      "Year": state.filterByYear,
      "ProjectId": state.filterByProjectId,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    if (state.filterByFromDate != null) {
      queryParams["FromDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterByFromDate!);
    }
    if (state.filterByToDate != null) {
      queryParams["ToDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterByToDate!);
    }
    final result = await ibmObmReportRepository.getIbmObmReport(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        final List<IbmObmReportModel> newData = List<IbmObmReportModel>.from(
          response['data'] ?? [],
        );

        final List<IbmObmReportModel> updatedList =
            pageNumber == 1 ? newData : [...state.ibmObmReportList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            ibmObmReportList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
            currentPageNumber: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> getIbmObmReportForView({
    required BuildContext context,
    required int pageNumber,
    required int employeeId,
  }) async {
    emit(state.copyWith(isLoading: true));
    final bool shouldCallApi =
        state.viewFilterByYear.isNotEmpty ||
        (state.viewFilterByFromDate != null &&
            state.viewFilterByToDate != null);

    if (!shouldCallApi) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    var queryParams = {
      "EmployeeId": employeeId,
      "Year": state.viewFilterByYear,
    };
    if (state.viewFilterByFromDate != null) {
      queryParams["FromDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.viewFilterByFromDate!);
    }
    if (state.viewFilterByToDate != null) {
      queryParams["ToDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.viewFilterByToDate!);
    }
    final result = await ibmObmReportRepository.getIbmObmReport(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        final List<IbmObmReportModel> newData = List<IbmObmReportModel>.from(
          response['data'] ?? [],
        );

        final updatedList =
            pageNumber == 1 ? newData : [...state.viewReportList, ...newData];

        emit(state.copyWith(isLoading: false, viewReportList: updatedList));
      },
    );
  }

  Future<void> getIbmObmReportForExport(
    BuildContext context,
    String exportType, {
    required int pageNumber,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var queryParams = {
      "ExportType": exportType,
      "EmployeeName": state.searchText.trim(),
      "Year": state.filterByYear,
      "ProjectId": state.filterByProjectId,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    if (state.filterByFromDate != null) {
      queryParams["FromDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterByFromDate!);
    }
    if (state.filterByToDate != null) {
      queryParams["ToDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterByToDate!);
    }

    final result = await ibmObmReportRepository.getIbmObmReportForExport(
      pageNumber: pageNumber,
      pageSize: state.totalNumberOfRecord,
      queryParams: queryParams,
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
              ? "IBM OBM Report ${DateTime.now()}.pdf"
              : "IBM OBM Report ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void search({required BuildContext context, required String value}) {
    emit(state.copyWith(searchText: value));
    getIbmObmReport(context: context, pageNumber: 1);
  }

  void applyIbmObmFilterAndSort({
    required BuildContext context,
    required String column,
    required String direction,
    String? reportType,
    String? employeeName,
    DateTime? fromDate,
    DateTime? toDate,
    String? year,
    int? projectId,
  }) {
    emit(
      state.copyWith(
        ibmObmReportList: [],
        totalNumberOfRecord: 0,
        currentSortColumn: column,
        currentSortDirection: direction,
        filterByReportType: reportType,
        filterByFromDate: fromDate,
        filterByToDate: toDate,
        filterByYear: year,
        searchText: employeeName,
        filterByProjectId: projectId,
        currentPageNumber: 1,
      ),
    );

    getIbmObmReport(context: context, pageNumber: 1);
  }

  void applyIbmObmFilterForView({
    required BuildContext context,
    required int employeeId,
    String? reportType,
    DateTime? fromDate,
    DateTime? toDate,
    String? year,
  }) {
    emit(
      state.copyWith(
        viewReportList: [],
        viewFilterByReportType: reportType,
        viewFilterByFromDate: fromDate,
        viewFilterByToDate: toDate,
        viewFilterByYear: year,
      ),
    );

    getIbmObmReportForView(
      context: context,
      pageNumber: 1,
      employeeId: employeeId,
    );
  }

  int updateFilterCount(IbmObmReportState state) {
    final hasSort =
        (state.currentSortColumn == "EmployeeName") &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByProjectId != null,
      state.filterByYear.trim().isNotEmpty ||
          (state.filterByFromDate != null && state.filterByToDate != null),
      hasSort,
    ]);
  }
}
