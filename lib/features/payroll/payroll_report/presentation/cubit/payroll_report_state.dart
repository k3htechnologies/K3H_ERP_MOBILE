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
  final int currentPageRegurization;
  final int totalNumberOfRecordRegurization;

  final int currentTabIndex;
  final String searchText;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final Set<int> selectedLeaveIds;
  final bool isAllLeaveSelected;

  final Set<int> selectedOutdoorIds;
  final bool isAllOutdoorSelected;

  final Set<int> selectedResignationIds;
  final bool isAllResignationSelected;

  final Set<int> selectedCompOffIds;
  final bool isAllCompOffSelected;
  final int leaveInnerTabIndex;
  final int compOffInnerTabIndex;
  final int outdoorInnerTabIndex;
  final int resignationInnerTabIndex;

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
    required this.currentPageRegurization,
    required this.totalNumberOfRecordRegurization,
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
    required this.leaveInnerTabIndex,
    required this.compOffInnerTabIndex,
    required this.outdoorInnerTabIndex,
    required this.resignationInnerTabIndex,
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
    currentPageRegurization: 1,
    totalNumberOfRecordRegurization: 0,
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
    leaveInnerTabIndex: 0,
    compOffInnerTabIndex: 0,
    outdoorInnerTabIndex: 0,
    resignationInnerTabIndex: 0,
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
    int? currentPageRegurization,
    int? totalNumberOfRecordRegurization,
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
    int? leaveInnerTabIndex,
    int? compOffInnerTabIndex,
    int? outdoorInnerTabIndex,
    int? resignationInnerTabIndex,
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
      currentPageRegurization:
          currentPageRegurization ?? this.currentPageRegurization,
      totalNumberOfRecordRegurization:
          totalNumberOfRecordRegurization ??
          this.totalNumberOfRecordRegurization,
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
      leaveInnerTabIndex: leaveInnerTabIndex ?? this.leaveInnerTabIndex,
      compOffInnerTabIndex: compOffInnerTabIndex ?? this.compOffInnerTabIndex,
      outdoorInnerTabIndex: outdoorInnerTabIndex ?? this.outdoorInnerTabIndex,
      resignationInnerTabIndex:
          resignationInnerTabIndex ?? this.resignationInnerTabIndex,
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
    currentPageRegurization,
    totalNumberOfRecordRegurization,
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
    leaveInnerTabIndex,
    compOffInnerTabIndex,
    outdoorInnerTabIndex,
    resignationInnerTabIndex,
  ];
}
