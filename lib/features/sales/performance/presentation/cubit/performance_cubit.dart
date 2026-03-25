import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/model/performance_report_closing.model.dart';
import 'package:k3h_erp_app/features/sales/performance/data/repository/performance_report.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'performance_state.dart';

class PerformanceCubit extends Cubit<PerformanceState> {
  PerformanceCubit() : super(PerformanceState.initial());
  // REPOSITORY
  final PerformanceReportRepository _performanceReportRepository =
      serviceLocator<PerformanceReportRepository>();

  // <---- SEARCH SALES TARGET ---->
  Future<void> searchSalesTarget(
    BuildContext context,
    int projectId,
    int tabIndex,
    String value,
  ) async {
    emit(
      state.copyWith(
        searchText: value.trim(),
        performanceReportClosingModel: [],
        performanceReportSourcingModel: [],
        currentPage: 1,
      ),
    );

    if (tabIndex == 0) {
      await getPerformanceSourcingReportList(
        context: context,
        projectId: projectId,
        pageNumber: 1,
        reportType: "Sourcing",
      );
    } else {
      await getPerformanceClosingReportList(
        context: context,
        projectId: projectId,
        pageNumber: 1,
        reportType: "Closing",
      );
    }
  }

  // <---- CLEAR FILTER ON SALES TARGET ---->
  void clearFilterOnSalesTarget(
    BuildContext context,
    int projectId,
    int tabIndex,
  ) {
    emit(
      state.copyWith(
        clearFilters: true,
        performanceReportSourcingModel: [],
        performanceReportClosingModel: [],
        filterStartDate: null,
        filterEndDate: null,
      ),
    );
    if (tabIndex == 0) {
      getPerformanceSourcingReportList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        reportType: "Sourcing",
      );
    } else {
      getPerformanceClosingReportList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        reportType: "Closing",
      );
    }
  }

  // <---- APPLY FILTER ON SALES TARGET ---->
  void applyFilterOnSalesTarget({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    required int projectId,
    required int tabIndex,
  }) {
    emit(
      state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
        performanceReportSourcingModel: [],
        performanceReportClosingModel: [],
      ),
    );
    if (tabIndex == 0) {
      getPerformanceSourcingReportList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        reportType: "Sourcing",
      );
    } else {
      getPerformanceClosingReportList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        reportType: "Closing",
      );
    }
  }

  // ON TAB CHANGE
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        isLoading: true,
        performanceReportClosingModel: [],
        performanceReportSourcingModel: [],
        closingTotalNumberOfRecordPerformanceReport: 1,
        sourcingTotalNumberOfRecordPerformanceReport: 1,
        currentPage: 1,
      ),
    );
  }

  // <---- GET SOURCING TARGET LIST ---->
  Future getPerformanceSourcingReportList({
    required BuildContext context,
    required int projectId,
    int pageNumber = 1,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _performanceReportRepository
        .getPerformanceSourcingReport(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          reportType: reportType,
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
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET CLOSING TARGET LIST ---->
  Future getPerformanceClosingReportList({
    required BuildContext context,
    required int projectId,
    int pageNumber = 1,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _performanceReportRepository.getPerformanceClosingReport(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      reportType: reportType,
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
            currentPage: pageNumber,
          ),
        );
      },
    );
  }
}
