import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';

class PayTrackState extends BaseState {
  final List<PayTrackModel> payTrackList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const PayTrackState({
    super.isLoading,
    required this.payTrackList,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory PayTrackState.initial() => PayTrackState(
    payTrackList: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
  );

  PayTrackState copyWith({
    bool? isLoading,

    List<PayTrackModel>? payTrackList,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return PayTrackState(
      payTrackList: payTrackList ?? this.payTrackList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    payTrackList,
    currentPage,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
  ];
}
