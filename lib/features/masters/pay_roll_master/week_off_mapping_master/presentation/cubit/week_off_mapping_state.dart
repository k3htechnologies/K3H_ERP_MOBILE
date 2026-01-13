import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/week_off_mapping.model.dart';

class WeekOffMappingMasterState extends BaseState {
  final List<WeekOffMappingModel> weekOffMappingList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;
  final String selectedOption;
  final List<String> options = const ['Employee', 'Department'];

  const WeekOffMappingMasterState({
    required this.weekOffMappingList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.selectedOption = 'Employee',
  });

  factory WeekOffMappingMasterState.initial() => WeekOffMappingMasterState(
    weekOffMappingList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
    selectedOption: 'Employee',
  );

  WeekOffMappingMasterState copyWith({
    List<WeekOffMappingModel>? weekOffMappingList,
    bool? isLoading = false,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    String? selectedOption,
  }) {
    return WeekOffMappingMasterState(
      weekOffMappingList: weekOffMappingList ?? this.weekOffMappingList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }


  @override
  List<Object?> get props => [
    weekOffMappingList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    selectedOption,
    options,
  ];
}

