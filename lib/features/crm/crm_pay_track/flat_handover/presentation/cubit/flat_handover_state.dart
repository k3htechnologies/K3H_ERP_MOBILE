import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';

class FlatHandoverState extends BaseState {
  final List<PayTrackBookingFilesModel> flatHandoverFileList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;

  const FlatHandoverState({
    super.isLoading,
    required this.flatHandoverFileList,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
  });

  factory FlatHandoverState.initial() => FlatHandoverState(
    flatHandoverFileList: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    isLoading: true,
  );

  FlatHandoverState copyWith({
    bool? isLoading,

    List<PayTrackBookingFilesModel>? flatHandoverFileList,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
  }) {
    return FlatHandoverState(
      flatHandoverFileList: flatHandoverFileList ?? this.flatHandoverFileList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    flatHandoverFileList,
    currentPage,
    totalNumberOfRecord,
    searchText,
  ];
}
