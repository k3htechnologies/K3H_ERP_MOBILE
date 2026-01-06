import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';

class LeaveEncashmentMasterState extends BaseState {
  final List<LeaveEncashmentMasterModel> leaveEncashmentList;
  final int currentPage;
  final int totalNumberOfRecord;
  const LeaveEncashmentMasterState({
    super.isLoading,
    required this.leaveEncashmentList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
  });

  factory LeaveEncashmentMasterState.initial() =>
      LeaveEncashmentMasterState(leaveEncashmentList: [], currentPage: 1);

  LeaveEncashmentMasterState copyWith({
    List<LeaveEncashmentMasterModel>? leaveEncashmentList,
    bool? isLoading = false,
    StateType? stateType,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,
  }) {
    return LeaveEncashmentMasterState(
      leaveEncashmentList: leaveEncashmentList ?? this.leaveEncashmentList,
      isLoading: isLoading ?? isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    leaveEncashmentList,
    currentPage,
    totalNumberOfRecord,
  ];
}
