part of 'tax_tracker_cubit.dart';

class TaxTrackerState extends BaseState {
  final List<TaxTrackerModel> taxTrackerList;
  final TaxTrackerModel? taxTrackerOverview;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByNoticeTitle;
  final String filterByAuthority;
  final String filterByFinancialYear;
  final int filterByCompany;
  final String filterByGovernmentCompliance;
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;
  final String filterCallStatus;
  const TaxTrackerState({
    super.isLoading,
    required this.taxTrackerList,
    required this.taxTrackerOverview,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByNoticeTitle,
    required this.filterByAuthority,
    required this.filterByFinancialYear,
    required this.filterByCompany,
    required this.filterByGovernmentCompliance,
    required this.filterByFromDate,
    required this.filterByToDate,
    required this.filterCallStatus,
  });

  factory TaxTrackerState.initial() => TaxTrackerState(
    isLoading: true,
    taxTrackerList: [],
    taxTrackerOverview: null,
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    currentSortColumn: '',
    currentSortDirection: '',
    filterByNoticeTitle: '',
    filterByAuthority: '',
    filterByFinancialYear: '',
    filterByCompany: 0,
    filterByGovernmentCompliance: '',
    filterByFromDate: null,
    filterByToDate: null,
    filterCallStatus: '',
  );
  static const _noChange = Object();
  TaxTrackerState copyWith({
    bool? isLoading,
    List<TaxTrackerModel>? taxTrackerList,
    TaxTrackerModel? taxTrackerOverview,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByNoticeTitle,
    String? filterByAuthority,
    String? filterByFinancialYear,
    int? filterByCompany,
    String? filterByGovernmentCompliance,
    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,
    String? filterCallStatus,
  }) {
    return TaxTrackerState(
      isLoading: isLoading ?? this.isLoading,
      taxTrackerList: taxTrackerList ?? this.taxTrackerList,
      taxTrackerOverview: taxTrackerOverview ?? this.taxTrackerOverview,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByNoticeTitle: filterByNoticeTitle ?? this.filterByNoticeTitle,
      filterByAuthority: filterByAuthority ?? this.filterByAuthority,
      filterByFinancialYear:
          filterByFinancialYear ?? this.filterByFinancialYear,
      filterByCompany: filterByCompany ?? this.filterByCompany,
      filterByGovernmentCompliance:
          filterByGovernmentCompliance ?? this.filterByGovernmentCompliance,
      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,

      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
      filterCallStatus: filterCallStatus ?? this.filterCallStatus,
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
    currentSortColumn,
    currentSortDirection,
    filterByNoticeTitle,
    filterByAuthority,
    filterByFinancialYear,
    filterByCompany,
    filterByGovernmentCompliance,
    filterByFromDate,
    filterByToDate,
    filterCallStatus,
  ];
}
