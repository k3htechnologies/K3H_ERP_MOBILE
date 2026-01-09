import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';

class WeekOffMasterState extends BaseState {
  final List<WeekOffMasterModel> weekOffMasterList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  const WeekOffMasterState({
    super.isLoading,
    required this.weekOffMasterList,
    this.currentPage = 1,
    this.totalNumberOfRecord = 0,
    this.searchText = "",
  });
  factory WeekOffMasterState.initial() =>
      WeekOffMasterState(weekOffMasterList: [], currentPage: 1);

  WeekOffMasterState copyWith({
    List<WeekOffMasterModel>? weekOffMasterList,
    bool? isLoading = false,

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
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    weekOffMasterList,
  ];
}
