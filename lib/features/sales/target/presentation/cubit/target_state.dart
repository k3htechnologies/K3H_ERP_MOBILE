part of 'target_cubit.dart';

class TargetState extends BaseState {
  final List<SaleTargetClosingModel> salesTargetClosing;
  final List<SalesTargetSourcingModel> salesTargetSourcing;
  final int closingTotalNumberOfRecordSalesTarget;
  final int sourcingTotalNumberOfRecordSalesTarget;
  final int sourcingPage;
  final int closingPage;
  final String searchText;
  final bool isSourcingLoading;
  final bool isClosingLoading;
  final String? selectedMonth;

  const TargetState({
    required this.salesTargetClosing,
    required this.salesTargetSourcing,
    required this.closingTotalNumberOfRecordSalesTarget,
    required this.sourcingTotalNumberOfRecordSalesTarget,
    required this.sourcingPage,
    required this.closingPage,
    required this.searchText,
    this.isSourcingLoading = false,
    this.isClosingLoading = false,
    this.selectedMonth,
  });

  factory TargetState.initial() => TargetState(
    salesTargetClosing: [],
    salesTargetSourcing: [],
    closingTotalNumberOfRecordSalesTarget: 0,
    sourcingTotalNumberOfRecordSalesTarget: 0,
    sourcingPage: 1,
    closingPage: 1,
    searchText: "",
    isSourcingLoading: false,
    isClosingLoading: false,
    selectedMonth: null,
  );

  static const _noChange = Object();

  TargetState copyWith({
    List<SaleTargetClosingModel>? salesTargetClosing,
    List<SalesTargetSourcingModel>? salesTargetSourcing,
    int? closingTotalNumberOfRecordSalesTarget,
    int? sourcingTotalNumberOfRecordSalesTarget,
    int? sourcingPage,
    int? closingPage,
    String? searchText,
    bool? isSourcingLoading,
    bool? isClosingLoading,
    Object? selectedMonth = _noChange,
  }) {
    return TargetState(
      salesTargetClosing: salesTargetClosing ?? this.salesTargetClosing,
      salesTargetSourcing: salesTargetSourcing ?? this.salesTargetSourcing,
      closingTotalNumberOfRecordSalesTarget:
      closingTotalNumberOfRecordSalesTarget ??
          this.closingTotalNumberOfRecordSalesTarget,
      sourcingTotalNumberOfRecordSalesTarget:
      sourcingTotalNumberOfRecordSalesTarget ??
          this.sourcingTotalNumberOfRecordSalesTarget,
      sourcingPage: sourcingPage ?? this.sourcingPage,
      closingPage: closingPage ?? this.closingPage,
      searchText: searchText ?? this.searchText,
      isSourcingLoading: isSourcingLoading ?? this.isSourcingLoading,
      isClosingLoading: isClosingLoading ?? this.isClosingLoading,

      selectedMonth:
      selectedMonth == _noChange
          ? this.selectedMonth
          : selectedMonth as String?,
    );
  }

  @override
  List<Object?> get props => [
    salesTargetClosing,
    salesTargetSourcing,
    closingTotalNumberOfRecordSalesTarget,
    sourcingTotalNumberOfRecordSalesTarget,
    sourcingPage,
    closingPage,
    searchText,
    isSourcingLoading,
    isClosingLoading,
    selectedMonth,
  ];
}
