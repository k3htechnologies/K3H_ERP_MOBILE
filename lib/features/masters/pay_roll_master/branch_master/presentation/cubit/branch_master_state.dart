part of 'branch_master_cubit.dart';

class BranchMasterState extends BaseState {
  final List<BranchMasterModel> branchList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterBranchCode;
  final String filterBranchLocation;

  const BranchMasterState({
    super.isLoading,
    required this.branchList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.filterBranchCode = "",
    this.filterBranchLocation = "",
  });

  factory BranchMasterState.initial() => BranchMasterState(
    branchList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterBranchCode: "",
    filterBranchLocation: "",
  );

  BranchMasterState copyWith({
    bool? isLoading,
    List<BranchMasterModel>? branchList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterBranchCode,
    String? filterBranchLocation,
  }) {
    return BranchMasterState(
      isLoading: isLoading ?? this.isLoading,
      branchList: branchList ?? this.branchList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterBranchCode: filterBranchCode ?? this.filterBranchCode,
      filterBranchLocation: filterBranchLocation ?? this.filterBranchLocation,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    branchList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterBranchCode,
    filterBranchLocation,
  ];
}
