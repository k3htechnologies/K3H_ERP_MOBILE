part of 'performance_cubit.dart';

final class PerformanceState extends BaseState {
  final List<PerformanceReportClosingModel> performanceReportClosingModel;
  final List<PerformanceReportSourcingModel> performanceReportSourcingModel;
  final int closingTotalNumberOfRecordPerformanceReport;
  final int sourcingTotalNumberOfRecordPerformanceReport;
  final int totalNumberOfRecords;
  final int currentPage;
  final String searchText;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  const PerformanceState({
    super.isLoading,
    required this.performanceReportClosingModel,
    required this.performanceReportSourcingModel,
    required this.closingTotalNumberOfRecordPerformanceReport,
    required this.sourcingTotalNumberOfRecordPerformanceReport,
    required this.totalNumberOfRecords,
    required this.currentPage,
    required this.searchText,
    this.filterStartDate,
    this.filterEndDate,
  });
  factory PerformanceState.initial() => PerformanceState(
    isLoading: false,
    performanceReportClosingModel: [],
    performanceReportSourcingModel: [],
    closingTotalNumberOfRecordPerformanceReport: 0,
    sourcingTotalNumberOfRecordPerformanceReport: 0,
    totalNumberOfRecords: 0,
    currentPage: 1,
    searchText: "",
    filterStartDate: null,
    filterEndDate: null,
  );
  static const _noChange = Object();
  PerformanceState copyWith({
    String? errorMessage,
    bool? isLoading,
    List<PerformanceReportClosingModel>? performanceReportClosingModel,
    List<PerformanceReportSourcingModel>? performanceReportSourcingModel,
    int? closingTotalNumberOfRecordPerformanceReport,
    int? sourcingTotalNumberOfRecordPerformanceReport,
    int? totalNumberOfRecords,
    int? currentPage,
    String? searchText,
    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
    bool clearFilters = false,
  }) {
    return PerformanceState(
      isLoading: isLoading ?? this.isLoading,
      performanceReportClosingModel:
          performanceReportClosingModel ?? this.performanceReportClosingModel,
      performanceReportSourcingModel:
          performanceReportSourcingModel ?? this.performanceReportSourcingModel,
      closingTotalNumberOfRecordPerformanceReport:
          closingTotalNumberOfRecordPerformanceReport ??
          this.closingTotalNumberOfRecordPerformanceReport,
      sourcingTotalNumberOfRecordPerformanceReport:
          sourcingTotalNumberOfRecordPerformanceReport ??
          this.sourcingTotalNumberOfRecordPerformanceReport,
      totalNumberOfRecords: totalNumberOfRecords ?? this.totalNumberOfRecords,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterStartDate:
          filterStartDate == _noChange
              ? this.filterStartDate
              : filterStartDate as DateTime?,

      filterEndDate:
          filterEndDate == _noChange
              ? this.filterEndDate
              : filterEndDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    performanceReportClosingModel,
    performanceReportSourcingModel,
    closingTotalNumberOfRecordPerformanceReport,
    sourcingTotalNumberOfRecordPerformanceReport,
    totalNumberOfRecords,
    currentPage,
    searchText,
    filterStartDate,
    filterEndDate,
  ];
}
