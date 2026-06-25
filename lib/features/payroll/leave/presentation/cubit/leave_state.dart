part of 'leave_cubit.dart';

class LeaveState extends BaseState {
  final List<LeaveTypeModel> leaveTypeList;
  final List<LeaveModel> leaveList; // final int leaveTypeTotalCount;

  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final int currentTabIndex;
  final int currentTabIndexViewScreen;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const LeaveState({
    super.isLoading,
    required this.leaveTypeList,
    required this.leaveList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentTabIndex,
    required this.currentTabIndexViewScreen,
    this.filterStartDate,
    this.filterEndDate,
  });

  factory LeaveState.initial() => LeaveState(
    leaveTypeList: [],
    // leaveTypeTotalCount: 0,
    leaveList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
    currentTabIndex: 0,
    currentTabIndexViewScreen: 0,
    filterStartDate: null,
    filterEndDate: null,
  );

  LeaveState copyWith({
    bool? isLoading,
    List<LeaveTypeModel>? leaveTypeList,
    List<LeaveModel>? leaveList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    int? currentTabIndex,
    int? currentTabIndexViewScreen,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearFilters = false,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      leaveTypeList: leaveTypeList ?? this.leaveTypeList,
      // leaveTypeTotalCount: leaveTypeTotalCount ?? this.leaveTypeTotalCount,
      leaveList: leaveList ?? this.leaveList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentTabIndexViewScreen:
          currentTabIndexViewScreen ?? this.currentTabIndexViewScreen,
      filterStartDate:
          clearFilters ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearFilters ? null : (filterEndDate ?? this.filterEndDate),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    leaveTypeList,
    leaveList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    currentTabIndex,
    currentTabIndexViewScreen,
    filterStartDate,
    filterEndDate,
  ];
}
