import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_closing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/repository/performance_report.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'performance_without_access_state.dart';

class PerformanceCubitWithoutAccess extends Cubit<PerformanceState> {
  PerformanceCubitWithoutAccess() : super(PerformanceState.initial());
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

  Map<String, DateTime> getAutoDateRange(String periodType) {
    final now = DateTime.now();

    switch (periodType) {
      case "MTD":
        final start = DateTime(now.year, now.month, 1);

        final end = DateTime(now.year, now.month + 1, 0);

        return {"from": start, "to": DateTime(end.year, end.month, end.day)};

      default:
        return {"from": now, "to": now};
    }
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
      "isMobile": true,
    };
    DateTime? fromDate;
    DateTime? toDate;

    final auto = getAutoDateRange(periodType);
    fromDate = auto["from"];
    toDate = auto["to"];

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
    Map<String, dynamic> queryParams = {
      "PeriodType": periodType,
      "EmployeeName": value ?? "",
      "isMobile": true,
    };
    DateTime? fromDate;
    DateTime? toDate;

    final auto = getAutoDateRange(periodType);
    fromDate = auto["from"];
    toDate = auto["to"];

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
}
