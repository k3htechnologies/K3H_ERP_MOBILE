part of 'leave_credit_debit_master_cubit.dart';

class LeaveCreditDebitMasterState extends BaseState {
  final List<DepartmentModel> departmentList;
  final int departmentTotalCount;
  final List<DesignationMasterModel> designationList;
  final int designationTotalCount;
  final String searchText;

  const LeaveCreditDebitMasterState({
    super.isLoading,
    required this.departmentList,
    required this.departmentTotalCount,
    required this.designationList,
    required this.designationTotalCount,
    required this.searchText,
  });

  factory LeaveCreditDebitMasterState.initial() => LeaveCreditDebitMasterState(
    isLoading: true,
    departmentList: [],
    departmentTotalCount: 0,
    designationList: [],
    designationTotalCount: 0,
    searchText: "",
  );

  LeaveCreditDebitMasterState copyWith({
    bool? isLoading,
    List<DepartmentModel>? departmentList,
    int? departmentTotalCount,
    List<DesignationMasterModel>? designationList,
    int? designationTotalCount,
    String? searchText,
  }) {
    return LeaveCreditDebitMasterState(
      isLoading: isLoading ?? this.isLoading,
      departmentList: departmentList ?? this.departmentList,
      departmentTotalCount: departmentTotalCount ?? this.departmentTotalCount,
      designationList: designationList ?? this.designationList,
      designationTotalCount:
          designationTotalCount ?? this.designationTotalCount,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    departmentList,
    departmentTotalCount,
    designationList,
    designationTotalCount,
    searchText,
  ];
}
