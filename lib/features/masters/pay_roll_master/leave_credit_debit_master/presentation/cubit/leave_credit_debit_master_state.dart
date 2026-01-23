part of 'leave_credit_debit_master_cubit.dart';

class LeaveCreditDebitMasterState extends BaseState {
  final List<LeaveCreditDebitMasterModel> leaveCreditDebitMasterList;
  final int totalNumberOfRecord;
  final int currentPage;
  final List<DepartmentModel> departmentList;
  final int departmentTotalCount;
  final List<DesignationMasterModel> designationList;
  final int designationTotalCount;
  final List<LeaveTypeModel> leaveTypeList;
  final int leaveTotalCount;
  final String searchText;

  const LeaveCreditDebitMasterState({
    super.isLoading,
    required this.leaveCreditDebitMasterList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.departmentList,
    required this.departmentTotalCount,
    required this.designationList,
    required this.designationTotalCount,
    required this.leaveTypeList,
    required this.leaveTotalCount,
    required this.searchText,
  });

  factory LeaveCreditDebitMasterState.initial() => LeaveCreditDebitMasterState(
    isLoading: true,
    leaveCreditDebitMasterList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    departmentList: [],
    departmentTotalCount: 0,
    designationList: [],
    designationTotalCount: 0,
    leaveTypeList: [],
    leaveTotalCount: 0,
    searchText: "",
  );

  LeaveCreditDebitMasterState copyWith({
    bool? isLoading,
    List<LeaveCreditDebitMasterModel>? leaveCreditDebitMasterList,
    int? totalNumberOfRecord,
    int? currentPage,
    List<DepartmentModel>? departmentList,
    int? departmentTotalCount,
    List<DesignationMasterModel>? designationList,
    int? designationTotalCount,
    List<LeaveTypeModel>? leaveTypeList,
    int? leaveTotalCount,
    String? searchText,
  }) {
    return LeaveCreditDebitMasterState(
      isLoading: isLoading ?? this.isLoading,
      leaveCreditDebitMasterList:
          leaveCreditDebitMasterList ?? this.leaveCreditDebitMasterList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      departmentList: departmentList ?? this.departmentList,
      departmentTotalCount: departmentTotalCount ?? this.departmentTotalCount,
      designationList: designationList ?? this.designationList,
      designationTotalCount:
          designationTotalCount ?? this.designationTotalCount,
      leaveTypeList: leaveTypeList?? this.leaveTypeList,
      leaveTotalCount: leaveTotalCount ?? this.leaveTotalCount,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    leaveCreditDebitMasterList,
    totalNumberOfRecord,
    currentPage,
    departmentList,
    departmentTotalCount,
    designationList,
    designationTotalCount,
    leaveTypeList,
    leaveTotalCount,
    searchText,
  ];
}
