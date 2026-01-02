part of 'holiday_master_cubit.dart';

class HolidayMasterState extends BaseState {
  final List<HolidayMasterModel> holidays;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const HolidayMasterState({
    super.isLoading,
    super.stateType,
    required this.holidays,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = '',
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory HolidayMasterState.initial() => HolidayMasterState(
    searchText: '',
    isLoading: true,
    holidays: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  HolidayMasterState copyWith({
    List<HolidayMasterModel>? holidays,
    bool? isLoading,
    String? errorMessage,
    StateType? stateType,
    String? searchText,
    int? currentPage,
    int? totalNumberOfRecord,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return HolidayMasterState(
      holidays: holidays ?? this.holidays,
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stateType,
    holidays,
    searchText,
    currentPage,
    totalNumberOfRecord,
  ];
}
