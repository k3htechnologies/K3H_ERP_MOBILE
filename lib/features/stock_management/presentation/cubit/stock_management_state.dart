part of 'stock_management_cubit.dart';

class StockManagementState extends BaseState {
  final List<StockManagementModel> stockList;
  final List<StockManagementHistoryModel> stockHistoryList;
  final List<StockManagementSummaryModel> stockSummaryList;
  final String searchText;
  final int totalNumberOfRecord;
  final int currentPage;
  final int selectedHistoryTab;
  const StockManagementState({
    super.isLoading,
    required this.stockList,
    required this.stockHistoryList,
    required this.stockSummaryList,
    required this.searchText,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.selectedHistoryTab,
  });
  factory StockManagementState.initial() => StockManagementState(
    stockList: [],
    stockHistoryList: [],
    stockSummaryList: [],
    isLoading: true,
    searchText: "",
    totalNumberOfRecord: 0,
    currentPage: 1,
    selectedHistoryTab: 0,
  );

  StockManagementState copyWith({
    bool? isLoading,
    List<StockManagementModel>? stockList,

    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    List<StockManagementHistoryModel>? stockHistoryList,
    List<StockManagementSummaryModel>? stockSummaryList,
    int? selectedHistoryTab,
  }) {
    return StockManagementState(
      stockList: stockList ?? this.stockList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      stockHistoryList: stockHistoryList ?? this.stockHistoryList,
      stockSummaryList: stockSummaryList ?? this.stockSummaryList,
      selectedHistoryTab: selectedHistoryTab ?? this.selectedHistoryTab,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stockList,
    searchText,
    totalNumberOfRecord,
    currentPage,
    stockHistoryList,
    stockSummaryList,
    selectedHistoryTab,
  ];
}
