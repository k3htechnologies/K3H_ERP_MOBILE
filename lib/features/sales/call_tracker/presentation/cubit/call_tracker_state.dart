part of 'call_tracker_cubit.dart';

class CallTrackerState extends BaseState {
  final List<CallingDataModel> callingDataList;
  final int totalNumberOfRecordCallingData;
  final int currentPageCallingData;
  final List<CallLogModel> callLogList;
  final int totalNumberOfRecordCallLog;
  final int currentPageCallLog;
  final String searchText;
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
    required this.currentTabIndex,
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
    currentTabIndex: 0,
  );

  CallTrackerState copyWith({
    bool? isLoading,
    List<CallingDataModel>? callingDataList,
    int? totalNumberOfRecordCallingData,
    int? currentPageCallingData,
    List<CallLogModel>? callLogList,
    int? totalNumberOfRecordCallLog,
    int? currentPageCallLog,
    String? searchText,
    int? currentTabIndex,
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
  ];
}
