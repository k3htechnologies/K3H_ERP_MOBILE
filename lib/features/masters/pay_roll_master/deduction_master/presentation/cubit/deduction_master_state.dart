part of 'deduction_master_cubit.dart';

class DeductionMasterState extends BaseState {
  final List<DeductionMasterModel> deductionList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final List<Map<String, dynamic>> stateList;
  final List<Map<String, dynamic>> branchList;
  final String currentSortColumn;
  final String currentSortDirection;

  const DeductionMasterState({
    required this.deductionList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    this.stateList = const [],
    this.branchList = const [],
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory DeductionMasterState.initial() => DeductionMasterState(
    deductionList: [],
    currentPage: 1,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  DeductionMasterState copyWith({
    List<DeductionMasterModel>? deductionList,
    bool? isLoading = false,
    StateType? stateType,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    List<Map<String, dynamic>>? stateList,
    List<Map<String, dynamic>>? branchList,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return DeductionMasterState(
        deductionList: deductionList ?? this.deductionList,
        isLoading: isLoading ?? this.isLoading,
        searchText: searchText ?? this.searchText,
        totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
        currentPage: currentPage ?? this.currentPage,
        stateList: stateList ?? this.stateList,
        branchList: branchList ?? this.branchList,
        currentSortColumn: currentSortColumn ?? this.currentSortColumn,
        currentSortDirection: currentSortDirection ?? this.currentSortDirection
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    searchText,
    branchList,
    deductionList,
    stateList,
  ];
}
