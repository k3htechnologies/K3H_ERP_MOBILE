import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';

class WeekOffMasterState extends BaseState {
  final List<WeekOffMasterModel> weekOffMasterList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;
  final String searchText;
  const WeekOffMasterState({
    super.isLoading,
    required this.weekOffMasterList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.searchText = "",
  });
  factory WeekOffMasterState.initial() => WeekOffMasterState(
    weekOffMasterList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
  );

  WeekOffMasterState copyWith({
    List<WeekOffMasterModel>? weekOffMasterList,
    bool? isLoading = false,
    String? currentSortColumn,
    String? currentSortDirection,
    StateType? stateType,
    String? searchText,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,
  }) {
    return WeekOffMasterState(
      weekOffMasterList: weekOffMasterList ?? this.weekOffMasterList,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    weekOffMasterList,
    currentSortColumn,
    currentSortDirection,
  ];
}
