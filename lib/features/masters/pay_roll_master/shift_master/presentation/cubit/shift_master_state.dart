import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';

class ShiftMasterState extends BaseState {
  final List<ShiftMasterModel> shiftMasterList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const ShiftMasterState({
    super.isLoading,
    required this.shiftMasterList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = "",
    this.currentSortColumn = "Created Date",
    this.currentSortDirection = "DESC",
  });

  factory ShiftMasterState.initial() => ShiftMasterState(
    shiftMasterList: [],
    currentPage: 1,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  ShiftMasterState copyWith({
    List<ShiftMasterModel>? shiftMasterList,
    bool? isLoading,
    StateType? stateType,
    String? searchText,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ShiftMasterState(
      shiftMasterList: shiftMasterList ?? this.shiftMasterList,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? this.isLoading,
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
    shiftMasterList,
    currentSortColumn,
    currentSortDirection,
  ];
}
