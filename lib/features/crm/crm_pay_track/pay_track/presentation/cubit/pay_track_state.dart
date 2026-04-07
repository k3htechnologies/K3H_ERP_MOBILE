import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';

class PayTrackState extends BaseState {
  final List<PayTrackModel> payTrackList;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const PayTrackState({
    super.isLoading,
    required this.payTrackList,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory PayTrackState.initial() => PayTrackState(
    payTrackList: [],
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
  );
  @override
  List<Object?> get props => [
    isLoading,
    payTrackList,
    currentPage,
    currentSortColumn,
    currentSortDirection,
  ];
}
