import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';

class ShiftMappingMasterState extends BaseState {
  final List<ShiftMappingModel> shiftMappingList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;

  final String filterDepartmentName;
  final String filterEmployeeName;

  const ShiftMappingMasterState({
    required this.shiftMappingList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.filterDepartmentName = "",
    this.filterEmployeeName = "",
  });

  factory ShiftMappingMasterState.initial() => ShiftMappingMasterState(
    shiftMappingList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
    filterDepartmentName: "",
    filterEmployeeName: "",
  );

  ShiftMappingMasterState copyWith({
    List<ShiftMappingModel>? shiftMappingList,
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterDepartmentName,
    String? filterEmployeeName,
  }) {
    return ShiftMappingMasterState(
      shiftMappingList: shiftMappingList ?? this.shiftMappingList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterDepartmentName: filterDepartmentName ?? this.filterDepartmentName,
      filterEmployeeName: filterEmployeeName ?? this.filterEmployeeName,
    );
  }

  @override
  List<Object?> get props => [
    shiftMappingList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    filterDepartmentName,
    filterEmployeeName,
  ];
}
