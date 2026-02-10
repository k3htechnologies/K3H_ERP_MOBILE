import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';

class LeaveTypeMasterState extends BaseState {
  final List<LeaveTypeModel> leaveTypeList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const LeaveTypeMasterState({
    super.isLoading,
    required this.leaveTypeList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = "",
    this.currentSortColumn = "Created Date",
    this.currentSortDirection = "DESC",
  });

  factory LeaveTypeMasterState.initial() => LeaveTypeMasterState(
    leaveTypeList: [],
    currentPage: 1,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  LeaveTypeMasterState copyWith({
    List<LeaveTypeModel>? leaveTypeList,
    bool? isLoading,
    StateType? stateType,
    String? searchText,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,

    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return LeaveTypeMasterState(
      leaveTypeList: leaveTypeList ?? this.leaveTypeList,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? this.isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    leaveTypeList,
    currentSortColumn,
    currentSortDirection,
  ];
}
