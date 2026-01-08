import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';

class LeaveTypeMasterState extends BaseState {
  final List<LeaveTypeModel> leaveTypeList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  const LeaveTypeMasterState({
    super.isLoading,
    required this.leaveTypeList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = "",
  });

  factory LeaveTypeMasterState.initial() =>
      LeaveTypeMasterState(leaveTypeList: [], currentPage: 1);

  LeaveTypeMasterState copyWith({
    List<LeaveTypeModel>? leaveTypeList,
    bool? isLoading = false,

    StateType? stateType,
    String? searchText,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,
  }) {
    return LeaveTypeMasterState(
      leaveTypeList: leaveTypeList ?? this.leaveTypeList,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    leaveTypeList,
  ];
}
