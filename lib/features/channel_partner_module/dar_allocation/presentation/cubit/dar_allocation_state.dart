part of 'dar_allocation_cubit.dart';

final class DarAllocationState extends BaseState {
  final List<DarAllocationModel> darAllocationList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;
  final String searchText;
  final String filterByEmployeeName;
  const DarAllocationState({
    super.isLoading,
    required this.darAllocationList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.searchText,
    required this.filterByEmployeeName,
  });
  factory DarAllocationState.initial() => DarAllocationState(
    darAllocationList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: '',
    currentSortDirection: '',
    searchText: '',
    filterByEmployeeName: '',
  );

  DarAllocationState copyWith({
    bool? isLoading,
    List<DarAllocationModel>? darAllocationList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    String? searchText,
    String? filterByEmployeeName,
  }) {
    return DarAllocationState(
      isLoading: isLoading ?? this.isLoading,
      darAllocationList: darAllocationList ?? this.darAllocationList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      searchText: searchText ?? this.searchText,
      filterByEmployeeName: filterByEmployeeName ?? this.filterByEmployeeName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    darAllocationList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    filterByEmployeeName,
  ];
}
