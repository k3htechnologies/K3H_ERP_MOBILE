part of 'holiday_mapping_master_cubit.dart';

class HolidayMappingMasterState extends BaseState {
  final List<HolidayMappingModel> holidayMappingList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterBranchName;
  final DateTime? filterFromHolidayDate;
  final DateTime? filterToHolidayDate;

  const HolidayMappingMasterState({
    super.isLoading,
    required this.holidayMappingList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.filterBranchName = "",
    this.filterFromHolidayDate,
    this.filterToHolidayDate,
  });

  factory HolidayMappingMasterState.initial() => HolidayMappingMasterState(
    holidayMappingList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterBranchName: "",
    filterFromHolidayDate: null,
    filterToHolidayDate: null,
  );

  HolidayMappingMasterState copyWith({
    bool? isLoading,
    List<HolidayMappingModel>? holidayMappingList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterBranchName,

    Object? filterFromHolidayDate = _noChange,
    Object? filterToHolidayDate = _noChange,
  }) {
    return HolidayMappingMasterState(
      isLoading: isLoading ?? this.isLoading,
      holidayMappingList: holidayMappingList ?? this.holidayMappingList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterBranchName: filterBranchName ?? this.filterBranchName,

      filterFromHolidayDate:
          filterFromHolidayDate == _noChange
              ? this.filterFromHolidayDate
              : filterFromHolidayDate as DateTime?,

      filterToHolidayDate:
          filterToHolidayDate == _noChange
              ? this.filterToHolidayDate
              : filterToHolidayDate as DateTime?,
    );
  }

  static const _noChange = Object();

  @override
  List<Object?> get props => [
    isLoading,
    holidayMappingList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterBranchName,
    filterFromHolidayDate,
    filterToHolidayDate,
  ];
}
