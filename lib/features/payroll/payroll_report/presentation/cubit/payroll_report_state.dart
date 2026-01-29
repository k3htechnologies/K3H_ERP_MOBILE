part of 'payroll_report_cubit.dart';

class PayrollReportState extends BaseState {
  final List<OutdoorModel> outdoorList;
  final int currentPageOutdoor;
  final int totalNumberOfRecordOutdoor;
  final int currentTabIndex;

  const PayrollReportState({
    super.isLoading,
    required this.outdoorList,
    required this.currentPageOutdoor,
    required this.totalNumberOfRecordOutdoor,
    required this.currentTabIndex,
  });

  factory PayrollReportState.initial() => PayrollReportState(
    isLoading: true,
    outdoorList: [],
    currentPageOutdoor: 1,
    totalNumberOfRecordOutdoor: 0,
    currentTabIndex: 0,
  );

  PayrollReportState copyWith({
    bool? isLoading,
    List<OutdoorModel>? outdoorList,
    int? currentPageOutdoor,
    int? totalNumberOfRecordOutdoor,
    int? currentTabIndex,
  }) {
    return PayrollReportState(
      isLoading: isLoading ?? this.isLoading,
      outdoorList: outdoorList ?? this.outdoorList,
      currentPageOutdoor: currentPageOutdoor ?? this.currentPageOutdoor,
      totalNumberOfRecordOutdoor: totalNumberOfRecordOutdoor ?? this.totalNumberOfRecordOutdoor,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    outdoorList,
    currentPageOutdoor,
    totalNumberOfRecordOutdoor,
    currentTabIndex,
  ];
}

