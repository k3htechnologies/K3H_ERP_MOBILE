part of 'leave_credit_configuration_master_cubit.dart';

class LeaveCreditConfigurationMasterState extends BaseState {
  final List<LeaveCreditConfigurationMasterModel>
  leaveCreditConfigurationMasterList;
  final int totalNumberOfRecord;
  final int currentPage;
  final List<DepartmentModel> departmentList;
  final int departmentTotalCount;
  final List<DesignationMasterModel> designationList;
  final int designationTotalCount;
  final List<LeaveTypeModel> leaveTypeList;
  final int leaveTotalCount;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  final String filterDesignationName;

  // IMPORTANT → must be DateTime?
  final DateTime? filterFromLeaveCreditDate;
  final DateTime? filterToLeaveCreditDate;
  const LeaveCreditConfigurationMasterState({
    super.isLoading,
    required this.leaveCreditConfigurationMasterList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.departmentList,
    required this.departmentTotalCount,
    required this.designationList,
    required this.designationTotalCount,
    required this.leaveTypeList,
    required this.leaveTotalCount,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.filterDesignationName = "",
    this.filterFromLeaveCreditDate,
    this.filterToLeaveCreditDate,
  });

  factory LeaveCreditConfigurationMasterState.initial() =>
      LeaveCreditConfigurationMasterState(
        isLoading: true,
        leaveCreditConfigurationMasterList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        departmentList: [],
        departmentTotalCount: 0,
        designationList: [],
        designationTotalCount: 0,
        leaveTypeList: [],
        leaveTotalCount: 0,
        currentSortColumn: "Created Date",
        currentSortDirection: "DESC",
        searchText: "",
        filterDesignationName: "",
        filterFromLeaveCreditDate: null,
        filterToLeaveCreditDate: null,
      );

  LeaveCreditConfigurationMasterState copyWith({
    bool? isLoading,
    List<LeaveCreditConfigurationMasterModel>?
    leaveCreditConfigurationMasterList,
    int? totalNumberOfRecord,
    int? currentPage,
    List<DepartmentModel>? departmentList,
    int? departmentTotalCount,
    List<DesignationMasterModel>? designationList,
    int? designationTotalCount,
    List<LeaveTypeModel>? leaveTypeList,
    int? leaveTotalCount,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterDesignationName,

    Object? filterFromLeaveCreditDate = _noChange,
    Object? filterToLeaveCreditDate = _noChange,
  }) {
    return LeaveCreditConfigurationMasterState(
      isLoading: isLoading ?? this.isLoading,
      leaveCreditConfigurationMasterList:
          leaveCreditConfigurationMasterList ??
          this.leaveCreditConfigurationMasterList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      departmentList: departmentList ?? this.departmentList,
      departmentTotalCount: departmentTotalCount ?? this.departmentTotalCount,
      designationList: designationList ?? this.designationList,
      designationTotalCount:
          designationTotalCount ?? this.designationTotalCount,
      leaveTypeList: leaveTypeList ?? this.leaveTypeList,
      leaveTotalCount: leaveTotalCount ?? this.leaveTotalCount,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterDesignationName: filterDesignationName ?? this.filterDesignationName,

      filterFromLeaveCreditDate:
          filterFromLeaveCreditDate == _noChange
              ? this.filterFromLeaveCreditDate
              : filterFromLeaveCreditDate as DateTime?,

      filterToLeaveCreditDate:
          filterToLeaveCreditDate == _noChange
              ? this.filterToLeaveCreditDate
              : filterToLeaveCreditDate as DateTime?,
    );
  }

  static const _noChange = Object();

  @override
  List<Object?> get props => [
    isLoading,
    leaveCreditConfigurationMasterList,
    totalNumberOfRecord,
    currentPage,
    departmentList,
    departmentTotalCount,
    designationList,
    designationTotalCount,
    leaveTypeList,
    leaveTotalCount,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterDesignationName,
    filterFromLeaveCreditDate,
    filterToLeaveCreditDate,
  ];
}
