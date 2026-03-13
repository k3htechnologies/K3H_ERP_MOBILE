import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';

class LeaveEncashmentMasterState extends BaseState {
  final List<LeaveEncashmentMasterModel> leaveEncashmentList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  const LeaveEncashmentMasterState({
    super.isLoading,
    required this.leaveEncashmentList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    required this.searchText,
  });

  factory LeaveEncashmentMasterState.initial() => LeaveEncashmentMasterState(
    leaveEncashmentList: [],
    currentPage: 1,
    searchText: "",
  );

  LeaveEncashmentMasterState copyWith({
    List<LeaveEncashmentMasterModel>? leaveEncashmentList,
    bool? isLoading = false,
    StateType? stateType,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
  }) {
    return LeaveEncashmentMasterState(
      leaveEncashmentList: leaveEncashmentList ?? this.leaveEncashmentList,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    leaveEncashmentList,
    currentPage,
    totalNumberOfRecord,
    searchText,
  ];
}
