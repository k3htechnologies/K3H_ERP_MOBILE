part of 'branch_association_master_cubit.dart';

class BranchAssociationMasterState extends BaseState {
  final List<BranchAssociationModel> branchAssociationList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final List<Map<String, dynamic>> employeeList;
  final List<Map<String, dynamic>> branchList;
  final String? currentSortColumn;
  final String? currentSortDirection;

  const BranchAssociationMasterState({
    super.isLoading,
    required this.branchAssociationList,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.employeeList,
    required this.branchList,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory BranchAssociationMasterState.initial() =>
      BranchAssociationMasterState(
        branchAssociationList: [],
        currentPage: 1,
        employeeList: [],
        branchList: [],
        currentSortColumn: "Created Date",
        currentSortDirection: "DESC",
      );

  BranchAssociationMasterState copyWith({
    bool? isLoading = false,
    List<BranchAssociationModel>? branchAssociationList,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    List<Map<String, dynamic>>? employeeList,
    List<Map<String, dynamic>>? branchList,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return BranchAssociationMasterState(
      isLoading: isLoading ?? this.isLoading,
      branchAssociationList:
          branchAssociationList ?? this.branchAssociationList,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      employeeList: employeeList ?? this.employeeList,
      branchList: branchList ?? this.branchList,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    branchAssociationList,
    currentPage,
    searchText,
    employeeList,
    branchList,
  ];
}
