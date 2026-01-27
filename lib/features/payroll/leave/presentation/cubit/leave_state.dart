part of 'leave_cubit.dart';

class LeaveState extends BaseState {
  final List<LeaveTypeModel> leaveTypeList;
  final int leaveTypeTotalCount;
  final List<LeaveModel> leaveList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final int currentTabIndex;

  const LeaveState({
    super.isLoading,
    required this.leaveTypeList,
    required this.leaveTypeTotalCount,
    required this.leaveList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentTabIndex,
  });

  factory LeaveState.initial() => LeaveState(
    leaveTypeList: [],
    leaveTypeTotalCount: 0,
    leaveList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
    currentTabIndex: 0,
  );

  LeaveState copyWith({
    bool? isLoading,
    List<LeaveTypeModel>? leaveTypeList,
    int? leaveTypeTotalCount,
    List<LeaveModel>? leaveList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    int? currentTabIndex,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      leaveTypeList: leaveTypeList ?? this.leaveTypeList,
      leaveTypeTotalCount: leaveTypeTotalCount ?? this.leaveTypeTotalCount,
      leaveList: leaveList ?? this.leaveList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    leaveTypeList,
    leaveTypeTotalCount,
    leaveList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    currentTabIndex,
  ];
}
