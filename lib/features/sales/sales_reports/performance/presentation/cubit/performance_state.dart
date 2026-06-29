part of 'performance_cubit.dart';

final class PerformanceState extends BaseState {
  final List<PerformanceReportClosingModel> performanceReportClosingModel;
  final int closingTotalNumberOfRecordPerformanceReport;
  final int closingCurrentPagePerformanceReport;
  final List<PerformanceReportSourcingModel> performanceReportSourcingModel;
  final int sourcingTotalNumberOfRecordPerformanceReport;
  final int sourcingCurrentPagePerformanceReport;
  final int currentTabIndexFirst;
  final int currentTabIndexSecond;
  final int currentTabIndexForView;
  final String searchText;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  const PerformanceState({
    super.isLoading,
    required this.performanceReportClosingModel,
    required this.closingTotalNumberOfRecordPerformanceReport,
    required this.closingCurrentPagePerformanceReport,
    required this.performanceReportSourcingModel,
    required this.sourcingTotalNumberOfRecordPerformanceReport,
    required this.sourcingCurrentPagePerformanceReport,
    required this.currentTabIndexFirst,
    required this.currentTabIndexSecond,
    required this.currentTabIndexForView,
    required this.searchText,
    this.filterStartDate,
    this.filterEndDate,
  });
  factory PerformanceState.initial() => PerformanceState(
    isLoading: false,
    performanceReportClosingModel: [],
    closingTotalNumberOfRecordPerformanceReport: 0,
    closingCurrentPagePerformanceReport: 1,
    performanceReportSourcingModel: [],
    sourcingTotalNumberOfRecordPerformanceReport: 0,
    sourcingCurrentPagePerformanceReport: 1,
    currentTabIndexFirst: 0,
    currentTabIndexSecond: 0,
    currentTabIndexForView: 0,
    searchText: "",
    filterStartDate: null,
    filterEndDate: null,
  );
  static const _noChange = Object();
  PerformanceState copyWith({
    String? errorMessage,
    bool? isLoading,
    List<PerformanceReportClosingModel>? performanceReportClosingModel,
    int? closingTotalNumberOfRecordPerformanceReport,
    int? closingCurrentPagePerformanceReport,
    List<PerformanceReportSourcingModel>? performanceReportSourcingModel,
    int? sourcingTotalNumberOfRecordPerformanceReport,
    int? sourcingCurrentPagePerformanceReport,
    int? currentTabIndexFirst,
    int? currentTabIndexSecond,
    int? currentTabIndexForView,
    String? searchText,
    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
    bool clearFilters = false,
  }) {
    return PerformanceState(
      isLoading: isLoading ?? this.isLoading,
      performanceReportClosingModel:
          performanceReportClosingModel ?? this.performanceReportClosingModel,
      closingTotalNumberOfRecordPerformanceReport:
          closingTotalNumberOfRecordPerformanceReport ??
          this.closingTotalNumberOfRecordPerformanceReport,
      closingCurrentPagePerformanceReport:
          closingCurrentPagePerformanceReport ??
          this.closingCurrentPagePerformanceReport,
      performanceReportSourcingModel:
          performanceReportSourcingModel ?? this.performanceReportSourcingModel,
      sourcingTotalNumberOfRecordPerformanceReport:
          sourcingTotalNumberOfRecordPerformanceReport ??
          this.sourcingTotalNumberOfRecordPerformanceReport,
      sourcingCurrentPagePerformanceReport:
          sourcingCurrentPagePerformanceReport ??
          this.sourcingCurrentPagePerformanceReport,
      currentTabIndexFirst: currentTabIndexFirst ?? this.currentTabIndexFirst,
      currentTabIndexSecond:
          currentTabIndexSecond ?? this.currentTabIndexSecond,
      currentTabIndexForView:
          currentTabIndexForView ?? this.currentTabIndexForView,
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
    closingTotalNumberOfRecordPerformanceReport,
    closingCurrentPagePerformanceReport,
    performanceReportSourcingModel,
    sourcingTotalNumberOfRecordPerformanceReport,
    sourcingCurrentPagePerformanceReport,
    currentTabIndexFirst,
    currentTabIndexSecond,
    currentTabIndexForView,
    searchText,
    filterStartDate,
    filterEndDate,
  ];
}
