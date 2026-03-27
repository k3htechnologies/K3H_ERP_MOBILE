part of 'payroll_report_cubit.dart';

class PayrollReportState extends BaseState {
  final int totalNumberOfRecord;
  final int currentPage;
  final List<AttendanceModel> attendanceList;
  final int totalNumberOfRecordAttendance;
  final int currentPageAttendance;

  final List<OutdoorModel> outdoorList;
  final int currentPageOutdoor;
  final int totalNumberOfRecordOutdoor;

  final List<LeaveModel> leaveList;
  final int currentPageLeave;
  final int totalNumberOfRecordLeave;

  final List<ResignationModel> resignationList;
  final int currentPageResignation;
  final int totalNumberOfRecordResignation;

  final List<CompOffModel> compOffList;
  final int currentPageCompOff;
  final int totalNumberOfRecordCompOff;

  final List<AttendanceRegularizationModel> regularizationList;
  final int currentPageRegularization;
  final int totalNumberOfRecordRegularization;

  // LEAVE APPROVAL
  final List<LeaveModel> approvalLeaveList;
  final int currentPageApprovalLeave;
  final int totalNumberOfRecordApprovalLeave;

  // REGULARIZATION APPROVAL
  final List<AttendanceRegularizationModel> approvalRegularizationList;
  final int currentPageApprovalRegularization;
  final int totalNumberOfRecordApprovalRegularization;

  // COMPOFF APPROVAL
  final List<CompOffModel> approvalCompOffList;
  final int currentPageApprovalCompOff;
  final int totalNumberOfRecordApprovalCompOff;

  // OUTDOOR APPROVAL
  final List<OutdoorModel> approvalOutdoorList;
  final int currentPageApprovalOutdoor;
  final int totalNumberOfRecordApprovalOutdoor;

  // RESIGNATION APPROVAL
  final List<ResignationModel> approvalResignationList;
  final int currentPageApprovalResignation;
  final int totalNumberOfRecordApprovalResignation;

  final int currentTabIndex;
  final String searchText;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  // Selection tracking
  final Set<int> selectedLeaveIds;
  final bool isAllLeaveSelected;

  final Set<int> selectedOutdoorIds;
  final bool isAllOutdoorSelected;

  final Set<int> selectedResignationIds;
  final bool isAllResignationSelected;

  final Set<int> selectedCompOffIds;
  final bool isAllCompOffSelected;

  final Set<int> selectedRegularizationIds;
  final bool isAllRegularizationSelected;

  // Inner tab indexes
  final int leaveInnerTabIndex;
  final int compOffInnerTabIndex;
  final int outdoorInnerTabIndex;
  final int resignationInnerTabIndex;
  final int regularizationInnerTabIndex;

  const PayrollReportState({
    super.isLoading,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.attendanceList,
    required this.currentPageAttendance,
    required this.totalNumberOfRecordAttendance,
    required this.outdoorList,
    required this.currentPageOutdoor,
    required this.totalNumberOfRecordOutdoor,
    required this.leaveList,
    required this.currentPageLeave,
    required this.totalNumberOfRecordLeave,
    required this.resignationList,
    required this.currentPageResignation,
    required this.totalNumberOfRecordResignation,
    required this.compOffList,
    required this.currentPageCompOff,
    required this.totalNumberOfRecordCompOff,
    required this.regularizationList,
    required this.currentPageRegularization,
    required this.totalNumberOfRecordRegularization,

    // APPROVAL
    required this.approvalLeaveList,
    required this.currentPageApprovalLeave,
    required this.totalNumberOfRecordApprovalLeave,

    required this.approvalRegularizationList,
    required this.currentPageApprovalRegularization,
    required this.totalNumberOfRecordApprovalRegularization,

    required this.approvalCompOffList,
    required this.currentPageApprovalCompOff,
    required this.totalNumberOfRecordApprovalCompOff,

    required this.approvalOutdoorList,
    required this.currentPageApprovalOutdoor,
    required this.totalNumberOfRecordApprovalOutdoor,

    required this.approvalResignationList,
    required this.currentPageApprovalResignation,
    required this.totalNumberOfRecordApprovalResignation,

    required this.currentTabIndex,
    required this.searchText,
    this.filterStartDate,
    this.filterEndDate,
    required this.selectedLeaveIds,
    required this.isAllLeaveSelected,
    required this.selectedOutdoorIds,
    required this.isAllOutdoorSelected,
    required this.selectedResignationIds,
    required this.isAllResignationSelected,
    required this.selectedCompOffIds,
    required this.isAllCompOffSelected,
    required this.selectedRegularizationIds,
    required this.isAllRegularizationSelected,
    required this.leaveInnerTabIndex,
    required this.compOffInnerTabIndex,
    required this.outdoorInnerTabIndex,
    required this.resignationInnerTabIndex,
    required this.regularizationInnerTabIndex,
  });

  factory PayrollReportState.initial() => PayrollReportState(
    isLoading: true,
    totalNumberOfRecord: 0,
    currentPage: 1,
    attendanceList: [],
    currentPageAttendance: 1,
    totalNumberOfRecordAttendance: 0,
    outdoorList: [],
    currentPageOutdoor: 1,
    totalNumberOfRecordOutdoor: 0,
    leaveList: [],
    currentPageLeave: 1,
    totalNumberOfRecordLeave: 0,
    resignationList: [],
    currentPageResignation: 1,
    totalNumberOfRecordResignation: 0,
    compOffList: [],
    currentPageCompOff: 1,
    totalNumberOfRecordCompOff: 0,
    regularizationList: [],
    currentPageRegularization: 1,
    totalNumberOfRecordRegularization: 0,

    // APPROVAL LISTS
    approvalLeaveList: [],
    currentPageApprovalLeave: 1,
    totalNumberOfRecordApprovalLeave: 0,

    approvalRegularizationList: [],
    currentPageApprovalRegularization: 1,
    totalNumberOfRecordApprovalRegularization: 0,

    approvalCompOffList: [],
    currentPageApprovalCompOff: 1,
    totalNumberOfRecordApprovalCompOff: 0,

    approvalOutdoorList: [],
    currentPageApprovalOutdoor: 1,
    totalNumberOfRecordApprovalOutdoor: 0,

    approvalResignationList: [],
    currentPageApprovalResignation: 1,
    totalNumberOfRecordApprovalResignation: 0,

    currentTabIndex: 0,
    searchText: '',
    filterStartDate: null,
    filterEndDate: null,
    selectedLeaveIds: {},
    isAllLeaveSelected: false,
    selectedOutdoorIds: {},
    isAllOutdoorSelected: false,
    selectedResignationIds: {},
    isAllResignationSelected: false,
    selectedCompOffIds: {},
    isAllCompOffSelected: false,
    selectedRegularizationIds: {},
    isAllRegularizationSelected: false,
    leaveInnerTabIndex: 0,
    compOffInnerTabIndex: 0,
    outdoorInnerTabIndex: 0,
    resignationInnerTabIndex: 0,
    regularizationInnerTabIndex: 0,
  );

  PayrollReportState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    List<AttendanceModel>? attendanceList,
    int? currentPageAttendance,
    int? totalNumberOfRecordAttendance,
    List<OutdoorModel>? outdoorList,
    int? currentPageOutdoor,
    int? totalNumberOfRecordOutdoor,
    List<LeaveModel>? leaveList,
    int? currentPageLeave,
    int? totalNumberOfRecordLeave,
    List<ResignationModel>? resignationList,
    int? currentPageResignation,
    int? totalNumberOfRecordResignation,
    List<CompOffModel>? compOffList,
    int? currentPageCompOff,
    int? totalNumberOfRecordCompOff,
    List<AttendanceRegularizationModel>? regularizationList,
    int? currentPageRegularization,
    int? totalNumberOfRecordRegularization,
    int? currentTabIndex,
    String? searchText,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearFilters = false,
    Set<int>? selectedLeaveIds,
    bool? isAllLeaveSelected,
    Set<int>? selectedOutdoorIds,
    bool? isAllOutdoorSelected,
    Set<int>? selectedResignationIds,
    bool? isAllResignationSelected,
    Set<int>? selectedCompOffIds,
    bool? isAllCompOffSelected,
    Set<int>? selectedRegularizationIds,
    bool? isAllRegularizationSelected,
    int? leaveInnerTabIndex,
    int? compOffInnerTabIndex,
    int? outdoorInnerTabIndex,
    int? resignationInnerTabIndex,
    int? regularizationInnerTabIndex,
    // Approval lists
    List<LeaveModel>? approvalLeaveList,
    int? currentPageApprovalLeave,
    int? totalNumberOfRecordApprovalLeave,

    List<AttendanceRegularizationModel>? approvalRegularizationList,
    int? currentPageApprovalRegularization,
    int? totalNumberOfRecordApprovalRegularization,

    List<CompOffModel>? approvalCompOffList,
    int? currentPageApprovalCompOff,
    int? totalNumberOfRecordApprovalCompOff,

    List<OutdoorModel>? approvalOutdoorList,
    int? currentPageApprovalOutdoor,
    int? totalNumberOfRecordApprovalOutdoor,

    List<ResignationModel>? approvalResignationList,
    int? currentPageApprovalResignation,
    int? totalNumberOfRecordApprovalResignation,
  }) {
    return PayrollReportState(
      isLoading: isLoading ?? this.isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      attendanceList: attendanceList ?? this.attendanceList,
      currentPageAttendance:
          currentPageAttendance ?? this.currentPageAttendance,
      totalNumberOfRecordAttendance:
          totalNumberOfRecordAttendance ?? this.totalNumberOfRecordAttendance,
      outdoorList: outdoorList ?? this.outdoorList,
      currentPageOutdoor: currentPageOutdoor ?? this.currentPageOutdoor,
      totalNumberOfRecordOutdoor:
          totalNumberOfRecordOutdoor ?? this.totalNumberOfRecordOutdoor,
      leaveList: leaveList ?? this.leaveList,
      currentPageLeave: currentPageLeave ?? this.currentPageLeave,
      totalNumberOfRecordLeave:
          totalNumberOfRecordLeave ?? this.totalNumberOfRecordLeave,
      resignationList: resignationList ?? this.resignationList,
      currentPageResignation:
          currentPageResignation ?? this.currentPageResignation,
      totalNumberOfRecordResignation:
          totalNumberOfRecordResignation ?? this.totalNumberOfRecordResignation,
      compOffList: compOffList ?? this.compOffList,
      currentPageCompOff: currentPageCompOff ?? this.currentPageCompOff,
      totalNumberOfRecordCompOff:
          totalNumberOfRecordCompOff ?? this.totalNumberOfRecordCompOff,
      regularizationList: regularizationList ?? this.regularizationList,
      currentPageRegularization:
          currentPageRegularization ?? this.currentPageRegularization,
      totalNumberOfRecordRegularization:
          totalNumberOfRecordRegularization ??
          this.totalNumberOfRecordRegularization,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchText: searchText ?? this.searchText,
      filterStartDate:
          clearFilters ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearFilters ? null : (filterEndDate ?? this.filterEndDate),
      selectedLeaveIds: selectedLeaveIds ?? this.selectedLeaveIds,
      isAllLeaveSelected: isAllLeaveSelected ?? this.isAllLeaveSelected,
      selectedOutdoorIds: selectedOutdoorIds ?? this.selectedOutdoorIds,
      isAllOutdoorSelected: isAllOutdoorSelected ?? this.isAllOutdoorSelected,
      selectedResignationIds:
          selectedResignationIds ?? this.selectedResignationIds,
      isAllResignationSelected:
          isAllResignationSelected ?? this.isAllResignationSelected,
      selectedCompOffIds: selectedCompOffIds ?? this.selectedCompOffIds,
      isAllCompOffSelected: isAllCompOffSelected ?? this.isAllCompOffSelected,
      selectedRegularizationIds:
          selectedRegularizationIds ?? this.selectedRegularizationIds,
      isAllRegularizationSelected:
          isAllRegularizationSelected ?? this.isAllRegularizationSelected,
      leaveInnerTabIndex: leaveInnerTabIndex ?? this.leaveInnerTabIndex,
      compOffInnerTabIndex: compOffInnerTabIndex ?? this.compOffInnerTabIndex,
      outdoorInnerTabIndex: outdoorInnerTabIndex ?? this.outdoorInnerTabIndex,
      resignationInnerTabIndex:
          resignationInnerTabIndex ?? this.resignationInnerTabIndex,
      regularizationInnerTabIndex:
          regularizationInnerTabIndex ?? this.regularizationInnerTabIndex,
      approvalLeaveList: approvalLeaveList ?? this.approvalLeaveList,
      currentPageApprovalLeave:
          currentPageApprovalLeave ?? this.currentPageApprovalLeave,
      totalNumberOfRecordApprovalLeave:
          totalNumberOfRecordApprovalLeave ??
          this.totalNumberOfRecordApprovalLeave,

      approvalRegularizationList:
          approvalRegularizationList ?? this.approvalRegularizationList,
      currentPageApprovalRegularization:
          currentPageApprovalRegularization ??
          this.currentPageApprovalRegularization,
      totalNumberOfRecordApprovalRegularization:
          totalNumberOfRecordApprovalRegularization ??
          this.totalNumberOfRecordApprovalRegularization,

      approvalCompOffList: approvalCompOffList ?? this.approvalCompOffList,
      currentPageApprovalCompOff:
          currentPageApprovalCompOff ?? this.currentPageApprovalCompOff,
      totalNumberOfRecordApprovalCompOff:
          totalNumberOfRecordApprovalCompOff ??
          this.totalNumberOfRecordApprovalCompOff,

      approvalOutdoorList: approvalOutdoorList ?? this.approvalOutdoorList,
      currentPageApprovalOutdoor:
          currentPageApprovalOutdoor ?? this.currentPageApprovalOutdoor,
      totalNumberOfRecordApprovalOutdoor:
          totalNumberOfRecordApprovalOutdoor ??
          this.totalNumberOfRecordApprovalOutdoor,

      approvalResignationList:
          approvalResignationList ?? this.approvalResignationList,
      currentPageApprovalResignation:
          currentPageApprovalResignation ?? this.currentPageApprovalResignation,
      totalNumberOfRecordApprovalResignation:
          totalNumberOfRecordApprovalResignation ??
          this.totalNumberOfRecordApprovalResignation,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    totalNumberOfRecord,
    currentPage,
    attendanceList,
    currentPageAttendance,
    totalNumberOfRecordAttendance,
    outdoorList,
    currentPageOutdoor,
    totalNumberOfRecordOutdoor,
    leaveList,
    currentPageLeave,
    totalNumberOfRecordLeave,
    resignationList,
    currentPageResignation,
    totalNumberOfRecordResignation,
    compOffList,
    currentPageCompOff,
    totalNumberOfRecordCompOff,
    regularizationList,
    currentPageRegularization,
    totalNumberOfRecordRegularization,
    currentTabIndex,
    searchText,
    filterStartDate,
    filterEndDate,
    selectedLeaveIds,
    isAllLeaveSelected,
    selectedOutdoorIds,
    isAllOutdoorSelected,
    selectedResignationIds,
    isAllResignationSelected,
    selectedCompOffIds,
    isAllCompOffSelected,
    selectedRegularizationIds,
    isAllRegularizationSelected,
    leaveInnerTabIndex,
    compOffInnerTabIndex,
    outdoorInnerTabIndex,
    resignationInnerTabIndex,
    regularizationInnerTabIndex,
    approvalLeaveList,
    currentPageApprovalLeave,
    totalNumberOfRecordApprovalLeave,
    approvalRegularizationList,
    currentPageApprovalRegularization,
    totalNumberOfRecordApprovalRegularization,
    approvalCompOffList,
    currentPageApprovalCompOff,
    totalNumberOfRecordApprovalCompOff,
    approvalOutdoorList,
    currentPageApprovalOutdoor,
    totalNumberOfRecordApprovalOutdoor,
    approvalResignationList,
    currentPageApprovalResignation,
    totalNumberOfRecordApprovalResignation,
  ];
}
