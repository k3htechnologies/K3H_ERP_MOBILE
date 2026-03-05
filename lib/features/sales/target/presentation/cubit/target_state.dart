part of 'target_cubit.dart';

class TargetState extends BaseState {
  final List<SaleTargetClosingModel> salesTargetClosing;
  final List<SalesTargetSourcingModel> salesTargetSourcing;
  final int closingTotalNumberOfRecordSalesTarget;
  final int sourcingTotalNumberOfRecordSalesTarget;
  final int totalNumberOfRecords;
  final int currentPage;
  final String searchText;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const TargetState({
    super.isLoading,
    required this.salesTargetClosing,
    required this.salesTargetSourcing,
    required this.closingTotalNumberOfRecordSalesTarget,
    required this.sourcingTotalNumberOfRecordSalesTarget,
    required this.totalNumberOfRecords,
    required this.currentPage,
    required this.searchText,
    this.filterStartDate,
    this.filterEndDate,
  });

  factory TargetState.initial() => TargetState(
    isLoading: false,
    salesTargetClosing: [],
    salesTargetSourcing: [],
    closingTotalNumberOfRecordSalesTarget: 0,
    sourcingTotalNumberOfRecordSalesTarget: 0,
    totalNumberOfRecords: 0,
    currentPage: 1,
    searchText: "",
    filterStartDate: null,
    filterEndDate: null,
  );

  static const _noChange = Object();

  TargetState copyWith({
    String? errorMessage,
    bool? isLoading,
    List<SaleTargetClosingModel>? salesTargetClosing,
    List<SalesTargetSourcingModel>? salesTargetSourcing,
    int? closingTotalNumberOfRecordSalesTarget,
    int? sourcingTotalNumberOfRecordSalesTarget,
    int? totalNumberOfRecords,
    int? currentPage,
    String? searchText,
    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
    bool clearFilters = false,
  }) {
    return TargetState(
      isLoading: isLoading ?? this.isLoading,
      salesTargetClosing: salesTargetClosing ?? this.salesTargetClosing,
      salesTargetSourcing: salesTargetSourcing ?? this.salesTargetSourcing,
      closingTotalNumberOfRecordSalesTarget:
          closingTotalNumberOfRecordSalesTarget ??
          this.closingTotalNumberOfRecordSalesTarget,
      sourcingTotalNumberOfRecordSalesTarget:
          sourcingTotalNumberOfRecordSalesTarget ??
          this.sourcingTotalNumberOfRecordSalesTarget,
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
    salesTargetClosing,
    salesTargetSourcing,
    closingTotalNumberOfRecordSalesTarget,
    sourcingTotalNumberOfRecordSalesTarget,
    totalNumberOfRecords,
    currentPage,
    searchText,
    filterStartDate,
    filterEndDate,
  ];
}
