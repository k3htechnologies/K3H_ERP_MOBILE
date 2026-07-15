import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';

class FilesState extends BaseState {
  final List<PayTrackBookingFilesModel> payTrackBookingFileList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;

  const FilesState({
    super.isLoading,
    required this.payTrackBookingFileList,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
  });

  factory FilesState.initial() => FilesState(
    payTrackBookingFileList: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    isLoading: true,
  );

  FilesState copyWith({
    bool? isLoading,
    List<PayTrackBookingFilesModel>? payTrackBookingFileList,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
  }) {
    return FilesState(
      isLoading: isLoading ?? this.isLoading,
      payTrackBookingFileList:
          payTrackBookingFileList ?? this.payTrackBookingFileList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    payTrackBookingFileList,
    currentPage,
    totalNumberOfRecord,
  ];
}
