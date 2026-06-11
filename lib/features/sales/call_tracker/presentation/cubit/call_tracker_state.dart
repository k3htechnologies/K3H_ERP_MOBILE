part of 'call_tracker_cubit.dart';

class CallTrackerState extends BaseState {
  final List<CallingDataModel> callingDataList;
  final int totalNumberOfRecordCallingData;
  final int currentPageCallingData;
  final List<CallLogModel> callLogList;
  final int totalNumberOfRecordCallLog;
  final int currentPageCallLog;
  final String searchText;
  final String filterMobileNo;
  final DateTime? filterRescheduleFromDate;
  final DateTime? filterRescheduleToDate;
  final String? filterSource;
  final int currentTabIndex;

  const CallTrackerState({
    super.isLoading,
    required this.callingDataList,
    required this.totalNumberOfRecordCallingData,
    required this.currentPageCallingData,
    required this.callLogList,
    required this.totalNumberOfRecordCallLog,
    required this.currentPageCallLog,
    required this.searchText,
    required this.filterMobileNo,
    required this.currentTabIndex,
    required this.filterRescheduleFromDate,
    required this.filterRescheduleToDate,
    required this.filterSource,
  });

  factory CallTrackerState.initial() => CallTrackerState(
    isLoading: true,
    callingDataList: [],
    totalNumberOfRecordCallingData: 0,
    currentPageCallingData: 1,
    callLogList: [],
    totalNumberOfRecordCallLog: 0,
    currentPageCallLog: 1,
    searchText: "",
    filterMobileNo: "",
    currentTabIndex: 0,
    filterRescheduleFromDate: null,
    filterRescheduleToDate: null,
    filterSource: "",
  );

  static const _noChange = Object();

  CallTrackerState copyWith({
    bool? isLoading,
    List<CallingDataModel>? callingDataList,
    int? totalNumberOfRecordCallingData,
    int? currentPageCallingData,
    List<CallLogModel>? callLogList,
    int? totalNumberOfRecordCallLog,
    int? currentPageCallLog,
    String? searchText,
    String? filterMobileNo,
    String? filterSource,
    int? currentTabIndex,
    Object? filterRescheduleFromDate = _noChange,
    Object? filterRescheduleToDate = _noChange,
  }) {
    return CallTrackerState(
      isLoading: isLoading ?? this.isLoading,
      callingDataList: callingDataList ?? this.callingDataList,
      totalNumberOfRecordCallingData:
          totalNumberOfRecordCallingData ?? this.totalNumberOfRecordCallingData,
      currentPageCallingData:
          currentPageCallingData ?? this.currentPageCallingData,
      callLogList: callLogList ?? this.callLogList,
      totalNumberOfRecordCallLog:
          totalNumberOfRecordCallLog ?? this.totalNumberOfRecordCallLog,
      currentPageCallLog: currentPageCallLog ?? this.currentPageCallLog,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      filterMobileNo: filterMobileNo ?? this.filterMobileNo,
      filterSource: filterSource ?? this.filterSource,

      filterRescheduleFromDate:
          filterRescheduleFromDate == _noChange
              ? this.filterRescheduleFromDate
              : filterRescheduleFromDate as DateTime?,

      filterRescheduleToDate:
          filterRescheduleToDate == _noChange
              ? this.filterRescheduleToDate
              : filterRescheduleToDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    callingDataList,
    totalNumberOfRecordCallingData,
    currentPageCallingData,
    callLogList,
    totalNumberOfRecordCallLog,
    currentPageCallLog,
    searchText,
    currentTabIndex,
    filterMobileNo,
    filterRescheduleFromDate,
    filterRescheduleToDate,
    filterSource,
  ];
}
