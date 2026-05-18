import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';

class PayTrackState extends BaseState {
  final List<PayTrackModel> payTrackList;
  final List<PayTrackCallLogModel> payTrackCallLogList;
  final int currentPage;
  final int totalNumberOfRecord;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final PayTrackModel? payTrackOverview;
  final BookingModel? bookingData;
  final EnquiryModel? currentEnquiryDetails;
  final bool isFetchingEnquiryDetails;

  const PayTrackState({
    super.isLoading,
    required this.payTrackList,
    required this.payTrackCallLogList,
    required this.currentPage,
    required this.totalNumberOfRecord,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.payTrackOverview,
    required this.bookingData,
    required this.currentEnquiryDetails,
    required this.isFetchingEnquiryDetails,
  });

  factory PayTrackState.initial() => PayTrackState(
    payTrackList: [],
    payTrackCallLogList: [],
    currentPage: 1,
    totalNumberOfRecord: 0,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
    payTrackOverview: null,
    bookingData: null,
    currentEnquiryDetails: null,
    isFetchingEnquiryDetails: false,
  );

  PayTrackState copyWith({
    bool? isLoading,

    List<PayTrackModel>? payTrackList,
    List<PayTrackCallLogModel>? payTrackCallLogList,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    PayTrackModel? payTrackOverview,
    BookingModel? bookingData,
    EnquiryModel? currentEnquiryDetails,
    bool? isFetchingEnquiryDetails,
  }) {
    return PayTrackState(
      payTrackList: payTrackList ?? this.payTrackList,
      payTrackCallLogList: payTrackCallLogList ?? this.payTrackCallLogList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      payTrackOverview: payTrackOverview ?? this.payTrackOverview,
      bookingData: bookingData ?? this.bookingData,
      currentEnquiryDetails:
          currentEnquiryDetails ?? this.currentEnquiryDetails,

      isFetchingEnquiryDetails:
          isFetchingEnquiryDetails ?? this.isFetchingEnquiryDetails,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    payTrackList,
    payTrackCallLogList,
    currentPage,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    payTrackOverview,
    bookingData,
    currentEnquiryDetails,
    isFetchingEnquiryDetails,
  ];
}
