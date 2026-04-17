import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        filterStartDate: null,
        filterEndDate: null,
        closingCurrentPagePerformanceReport: 1,
        sourcingCurrentPagePerformanceReport: 1,
      ),
    );
  }

  Map<String, DateTime> getAutoDateRange(String periodType) {
    final now = DateTime.now();
    switch (periodType) {
      case "WTD":
        final now = DateTime.now();
        final currentMonday = now.subtract(Duration(days: now.weekday - 1));

        DateTime start;
        DateTime end;

        if (now.weekday == DateTime.monday) {
          final prevMonday = currentMonday.subtract(const Duration(days: 7));

          start = prevMonday.add(const Duration(days: 1));
          end = currentMonday;
        } else {
          start = currentMonday.add(const Duration(days: 1));
          end = currentMonday.add(const Duration(days: 7));
        }

        return {
          "from": DateTime(start.year, start.month, start.day),
          "to": DateTime(end.year, end.month, end.day),
        };

      case "MTD":
        final start = DateTime(now.year, now.month, 1);

        final end = DateTime(now.year, now.month + 1, 0);

        return {"from": start, "to": DateTime(end.year, end.month, end.day)};

      case "YTD":
        final start = DateTime(now.year, 1, 1);

        final end = DateTime(now.year, now.month, now.day);

        return {"from": start, "to": end};

      default:
        return {"from": now, "to": now};
    }
  }

  Future applyFilterAndSort({
    required BuildContext context,
    required int projectId,
    required String reportType,
    required String periodType,
    DateTime? filterFromDate,
    DateTime? filterToDate,
  }) async {
    emit(
      state.copyWith(
        filterStartDate: filterFromDate,
        filterEndDate: filterToDate,
        performanceReportClosingModel: [],
        performanceReportSourcingModel: [],
        closingCurrentPagePerformanceReport: 1,
        sourcingCurrentPagePerformanceReport: 1,
      ),
    );

    await Future.wait([
      getPerformanceSourcingReportList(
        context: context,
        projectId: projectId,
        reportType: reportType,
        periodType: periodType,
        pageNumber: 1,
      ),
      getPerformanceClosingReportList(
        context: context,
        projectId: projectId,
        reportType: reportType,
        periodType: periodType,
        pageNumber: 1,
      ),
    ]);
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
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    Map<String, dynamic> queryParams = {
      "PeriodType": periodType,
      "EmployeeName": value ?? "",
    };
    DateTime? fromDate;
    DateTime? toDate;

    /// 🔥 Priority: Manual filter > Auto period
    if (state.filterStartDate != null && state.filterEndDate != null) {
      fromDate = state.filterStartDate;
      toDate = state.filterEndDate;
    } else {
      final auto = getAutoDateRange(periodType);
      fromDate = auto["from"];
      toDate = auto["to"];
    }

    queryParams["FromDate"] = DateFormat('yyyy-MM-dd').format(fromDate!);
    queryParams["ToDate"] = DateFormat('yyyy-MM-dd').format(toDate!);
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
                response['totalNumberOfRecord'],
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
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    Map<String, dynamic> queryParams = {
      "PeriodType": periodType,
      "EmployeeName": value ?? "",
    };
    DateTime? fromDate;
    DateTime? toDate;

    if (state.filterStartDate != null && state.filterEndDate != null) {
      fromDate = state.filterStartDate;
      toDate = state.filterEndDate;
    } else {
      final auto = getAutoDateRange(periodType);
      fromDate = auto["from"];
      toDate = auto["to"];
    }

    queryParams["FromDate"] = DateFormat('yyyy-MM-dd').format(fromDate!);
    queryParams["ToDate"] = DateFormat('yyyy-MM-dd').format(toDate!);

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
                response['totalNumberOfRecord'],
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
    final auto = getAutoDateRange(periodType);
    final fromDate = auto["from"];
    final toDate = auto["to"];
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
                "FromDate": DateFormat('yyyy-MM-dd').format(fromDate!),
                "ToDate": DateFormat('yyyy-MM-dd').format(toDate!),
              }
              : {
                "ExportType": exportType,
                "PeriodType": periodType,
                "FromDate": DateFormat('yyyy-MM-dd').format(fromDate!),
                "ToDate": DateFormat('yyyy-MM-dd').format(toDate!),
              },
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
