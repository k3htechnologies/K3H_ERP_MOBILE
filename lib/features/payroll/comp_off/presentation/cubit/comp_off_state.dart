part of 'comp_off_cubit.dart';

class CompOffState extends BaseState {
  final List<CompOffDatesModel> compOffDatesList;
  final List<CompOffModel> compOffList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int currentTabIndex;
  final DateTime? workedDate;
  final DateTime? compOffDate;
  final String reason;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const CompOffState({
    super.isLoading,
    required this.compOffDatesList,
    required this.compOffList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentTabIndex,
    this.workedDate,
    this.compOffDate,
    this.reason = '',
    this.filterStartDate,
    this.filterEndDate,
  });

  factory CompOffState.initial() => CompOffState(
    compOffDatesList: [],
    compOffList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    isLoading: true,
    currentTabIndex: 0,
    workedDate: null,
    compOffDate: null,
    reason: '',
    filterStartDate: null,
    filterEndDate: null,
  );

  CompOffState copyWith({
    bool? isLoading,
    List<CompOffDatesModel>? compOffDatesList,
    List<CompOffModel>? compOffList,
    int? totalNumberOfRecord,
    int? currentPage,
    int? currentTabIndex,
    DateTime? workedDate,
    DateTime? compOffDate,
    String? reason,
    bool clearWorkedDate = false,
    bool clearCompOffDate = false,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearFilters = false,
  }) {
    return CompOffState(
      isLoading: isLoading ?? this.isLoading,
      compOffDatesList: compOffDatesList ?? this.compOffDatesList,
      compOffList: compOffList ?? this.compOffList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      workedDate: clearWorkedDate ? null : (workedDate ?? this.workedDate),
      compOffDate: clearCompOffDate ? null : (compOffDate ?? this.compOffDate),
      reason: reason ?? this.reason,
      filterStartDate:
          clearFilters ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearFilters ? null : (filterEndDate ?? this.filterEndDate),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    compOffDatesList,
    compOffList,
    totalNumberOfRecord,
    currentPage,
    currentTabIndex,
    workedDate,
    compOffDate,
    reason,
    filterStartDate,
    filterEndDate,
  ];
}
