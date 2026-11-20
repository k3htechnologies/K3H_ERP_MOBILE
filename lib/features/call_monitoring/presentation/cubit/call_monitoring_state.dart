import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/model/call_monitoring.model.dart';

class CallMonitoringState extends BaseState {
  final List<CallMonitoringModel> callMonitoringList;
  final int id;
  final String pageName;
  final String filterByName;
  final String filterByCallStatus;
  final String filterByCallPurpose;
  final String filterByMobileNumber;
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;

  final int currentPage;
  final int totalNumberOfRecord;

  const CallMonitoringState({
    super.isLoading,
    required this.callMonitoringList,
    required this.filterByName,
    required this.filterByCallStatus,
    required this.filterByCallPurpose,
    required this.filterByMobileNumber,
    this.filterByFromDate,
    this.filterByToDate,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.pageName,
    required this.id,
  });

  factory CallMonitoringState.inital() => CallMonitoringState(
    callMonitoringList: [],
    filterByName: "",
    filterByCallStatus: "",
    filterByCallPurpose: "",
    filterByMobileNumber: "",
    filterByFromDate: null,
    filterByToDate: null,
    currentPage: 1,
    totalNumberOfRecord: 0,
    id: 0,
    pageName: "",
  );

  static const _noChange = Object();

  CallMonitoringState copyWith({
    bool? isLoading,
    List<CallMonitoringModel>? callMonitoringList,
    String? filterByName,
    String? filterByCallStatus,
    String? filterByCallPurpose,
    String? filterByMobileNumber,
    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,
    int? currentPage,
    int? totalNumberOfRecord,
    int? id,
    String? pageName,
  }) {
    return CallMonitoringState(
      isLoading: isLoading ?? this.isLoading,
      callMonitoringList: callMonitoringList ?? this.callMonitoringList,
      filterByName: filterByName ?? this.filterByName,
      filterByCallStatus: filterByCallStatus ?? this.filterByCallStatus,
      filterByCallPurpose: filterByCallPurpose ?? this.filterByCallPurpose,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,
      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
      id: id ?? this.id,
      pageName: pageName ?? this.pageName,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    callMonitoringList,
    filterByName,
    filterByCallStatus,
    filterByCallPurpose,
    filterByMobileNumber,
    filterByFromDate,
    filterByToDate,
    currentPage,
    totalNumberOfRecord,
    id,
    pageName,
  ];
}
