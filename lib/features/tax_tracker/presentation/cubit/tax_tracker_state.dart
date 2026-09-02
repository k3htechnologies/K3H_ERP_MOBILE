part of 'tax_tracker_cubit.dart';

class TaxTrackerState extends BaseState {
  final List<TaxTrackerModel> taxTrackerList;
  final TaxTrackerModel? taxTrackerOverview;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  const TaxTrackerState({
    super.isLoading,
    required this.taxTrackerList,
    required this.taxTrackerOverview,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
  });

  factory TaxTrackerState.initial() => TaxTrackerState(
    isLoading: true,
    taxTrackerList: [],
    taxTrackerOverview: null,
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
  );

  TaxTrackerState copywith({
    bool? isLoading,
    List<TaxTrackerModel>? taxTrackerList,
    TaxTrackerModel? taxTrackerOverview,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
  }) {
    return TaxTrackerState(
      isLoading: isLoading ?? this.isLoading,
      taxTrackerList: taxTrackerList ?? this.taxTrackerList,
      taxTrackerOverview: taxTrackerOverview ?? this.taxTrackerOverview,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    taxTrackerList,
    taxTrackerOverview,
    currentPage,
    totalNumberOfRecord,
    searchText,
  ];
}
