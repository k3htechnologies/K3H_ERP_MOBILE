import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';

class ShiftMasterState extends BaseState {
  final List<ShiftMasterModel> shiftMasterList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  const ShiftMasterState({
    super.isLoading,
    required this.shiftMasterList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = "",
  });
  factory ShiftMasterState.initial() =>
      ShiftMasterState(shiftMasterList: [], currentPage: 1);

  ShiftMasterState copyWith({
    List<ShiftMasterModel>? shiftMasterList,
    bool? isLoading = false,

    StateType? stateType,
    String? searchText,
    String? errorMessage,
    int? currentPage,
    int? totalNumberOfRecord,
  }) {
    return ShiftMasterState(
      shiftMasterList: shiftMasterList ?? this.shiftMasterList,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    shiftMasterList,
  ];
}
