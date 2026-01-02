part of 'earning_master_cubit.dart';

class EarningMasterState extends BaseState {
  final List<EarningMasterModel> earningList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const EarningMasterState({
    required super.isLoading,
    required this.earningList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory EarningMasterState.initial() => EarningMasterState(
    isLoading: true,
    earningList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: '',
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  EarningMasterState copyWith({
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    List<EarningMasterModel>? earningList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return EarningMasterState(
      isLoading: isLoading ?? this.isLoading,
      earningList: earningList ?? this.earningList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    earningList,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];
}
