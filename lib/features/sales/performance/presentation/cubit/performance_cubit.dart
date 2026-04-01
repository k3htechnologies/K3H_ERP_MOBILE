import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_closing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/repository/performance_report.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'performance_state.dart';

class PerformanceCubit extends Cubit<PerformanceState> {
  PerformanceCubit() : super(PerformanceState.initial());
  // REPOSITORY
  final PerformanceReportRepository _performanceReportRepository =
      serviceLocator<PerformanceReportRepository>();

  // <---- SEARCH SALES TARGET ---->
  Future<void> searchPerformanceReport(
    BuildContext context,
    int projectId,
    int tabIndex,
    String value,
    String reportType,
    String periodType,
  ) async {
    final searchText = value.trim();

    emit(
      state.copyWith(
        searchText: searchText,
        performanceReportClosingModel: [],
        performanceReportSourcingModel: [],
        closingCurrentPagePerformanceReport: 1,
        sourcingCurrentPagePerformanceReport: 1,
      ),
    );

    if (tabIndex == 0) {
      await getPerformanceSourcingReportList(
        context: context,
        projectId: projectId,
        reportType: reportType,
        periodType: periodType,
        pageNumber: 1,
        value: searchText,
      );
    } else {
      await getPerformanceClosingReportList(
        context: context,
        projectId: projectId,
        reportType: reportType,
        periodType: periodType,
        pageNumber: 1,
        value: searchText,
      );
    }
  }

  // RESET SEARCH
  void resetSearch() {
    emit(
      state.copyWith(
        searchText: "",
        performanceReportClosingModel: [],
        performanceReportSourcingModel: [],
        closingCurrentPagePerformanceReport: 1,
        sourcingCurrentPagePerformanceReport: 1,
      ),
    );
  }

  // ON TAB CHANGES METHOD
  void onTabChangedViewScreen(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndexForView: index));
  }

  // <---- GET SOURCING TARGET LIST ---->
  Future getPerformanceSourcingReportList({
    required BuildContext context,
    required int projectId,
    required String reportType,
    required String periodType,
    int pageNumber = 1,
    String? value,
  }) async {
    Map<String, dynamic> queryParams = {
      "PeriodType": periodType,
      "EmployeeName": value ?? "",
    };
    emit(state.copyWith(isLoading: true));

    var result = await _performanceReportRepository
        .getPerformanceSourcingReport(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          reportType: reportType,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PerformanceReportSourcingModel> newData =
            List<PerformanceReportSourcingModel>.from(response['data'] ?? []);

        final List<PerformanceReportSourcingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.performanceReportSourcingModel, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            performanceReportSourcingModel: updatedList,
            sourcingTotalNumberOfRecordPerformanceReport:
                response['totalNumberOfRecord'] == 0 &&
                        state.sourcingTotalNumberOfRecordPerformanceReport != 1
                    ? state.sourcingTotalNumberOfRecordPerformanceReport - 1
                    : response['totalNumberOfRecord'],
            sourcingCurrentPagePerformanceReport: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET CLOSING TARGET LIST ---->
  Future getPerformanceClosingReportList({
    required BuildContext context,
    required int projectId,
    required String reportType,
    required String periodType,
    int pageNumber = 1,
    String? value,
  }) async {
    Map<String, dynamic> queryParams = {
      "PeriodType": periodType,
      "EmployeeName": value ?? "",
    };

    emit(state.copyWith(isLoading: true));

    var result = await _performanceReportRepository.getPerformanceClosingReport(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      reportType: reportType,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PerformanceReportClosingModel> newData =
            List<PerformanceReportClosingModel>.from(response['data'] ?? []);

        final List<PerformanceReportClosingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.performanceReportClosingModel, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            performanceReportClosingModel: updatedList,
            closingTotalNumberOfRecordPerformanceReport:
                response['totalNumberOfRecord'] == 0 &&
                        state.closingTotalNumberOfRecordPerformanceReport != 1
                    ? state.closingTotalNumberOfRecordPerformanceReport - 1
                    : response['totalNumberOfRecord'],
            closingCurrentPagePerformanceReport: pageNumber,
          ),
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    String reportType,
    String periodType,
    int projectId,
    int totalNumberOfRecord,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _performanceReportRepository.exportPerformanceReport(
      projectId: projectId,
      pageNumber: 1,
      pageSize: totalNumberOfRecord,
      reportType: reportType,
      queryParams:
          state.searchText != ""
              ? {
                "EmployeeName": state.searchText,
                "ExportType": exportType,
                "PeriodType": periodType,
              }
              : {"ExportType": exportType, "PeriodType": periodType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final fileName =
            "${reportType == "closing" ? "Closing Performance Report" : "Sourcing Performance Report"} ${DateTime.now()}";
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "$fileName.pdf"
              : "$fileName.xlsx",
        );
      },
    );
  }
}
