part of 'call_logs_cubit.dart';

class CallLogsState extends BaseState {
  final List<PayTrackCallLogModel> payTrackCallLogList;
  final PayTrackCallLogModel? payTrackCallLog;
  final String filterByCallLogApplicantName;
  final String filterCallStatus;
  final String filterCallPurpose;
  final String filterCallLogApplicantMobileNumber;
  final DateTime? filterCallLogFromDate;
  final DateTime? filterCallLogToDate;
  final int callLogsCurrentPage;
  final int callLogsTotalNumberOfRecord;
  const CallLogsState({
    super.isLoading,
    required this.payTrackCallLogList,
    this.payTrackCallLog,
    required this.filterByCallLogApplicantName,
    required this.filterCallStatus,
    required this.filterCallPurpose,
    required this.filterCallLogApplicantMobileNumber,
    this.filterCallLogFromDate,
    this.filterCallLogToDate,
    required this.callLogsCurrentPage,
    required this.callLogsTotalNumberOfRecord,
  });
  factory CallLogsState.inital() => CallLogsState(
    payTrackCallLogList: [],
    payTrackCallLog: null,
    filterByCallLogApplicantName: "",
    filterCallStatus: "",
    filterCallPurpose: "",
    filterCallLogApplicantMobileNumber: "",
    filterCallLogFromDate: null,
    filterCallLogToDate: null,
    callLogsCurrentPage: 1,
    callLogsTotalNumberOfRecord: 0,
  );
  static const _noChange = Object();
  CallLogsState copyWith({
    bool? isLoading,
    List<PayTrackCallLogModel>? payTrackCallLogList,
    PayTrackCallLogModel? payTrackCallLog,
    String? filterByCallLogApplicantName,
    String? filterCallStatus,
    String? filterCallPurpose,
    String? filterCallLogApplicantMobileNumber,
    Object? filterCallLogFromDate = _noChange,
    Object? filterCallLogToDate = _noChange,
    int? callLogsCurrentPage,
    int? callLogsTotalNumberOfRecord,
  }) {
    return CallLogsState(
      isLoading: isLoading ?? this.isLoading,
      payTrackCallLogList: payTrackCallLogList ?? this.payTrackCallLogList,
      payTrackCallLog: payTrackCallLog ?? this.payTrackCallLog,
      filterByCallLogApplicantName:
          filterByCallLogApplicantName ?? this.filterByCallLogApplicantName,
      filterCallStatus: filterCallStatus ?? this.filterCallStatus,
      filterCallPurpose: filterCallPurpose ?? this.filterCallPurpose,
      filterCallLogApplicantMobileNumber:
          filterCallLogApplicantMobileNumber ??
          this.filterCallLogApplicantMobileNumber,

      filterCallLogFromDate:
          filterCallLogFromDate == _noChange
              ? this.filterCallLogFromDate
              : filterCallLogFromDate as DateTime?,

      filterCallLogToDate:
          filterCallLogToDate == _noChange
              ? this.filterCallLogToDate
              : filterCallLogToDate as DateTime?,
      callLogsCurrentPage: callLogsCurrentPage ?? this.callLogsCurrentPage,
      callLogsTotalNumberOfRecord:
          callLogsTotalNumberOfRecord ?? this.callLogsTotalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    payTrackCallLogList,
    payTrackCallLog,
    filterByCallLogApplicantName,
    filterCallStatus,
    filterCallPurpose,
    filterCallLogApplicantMobileNumber,
    filterCallLogFromDate,
    filterCallLogToDate,
    callLogsCurrentPage,
    callLogsTotalNumberOfRecord,
  ];
}
