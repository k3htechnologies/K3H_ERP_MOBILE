import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';

class PayTrackState extends BaseState {
  final List<PayTrackModel> payTrackList;
  final PayTrackModel? payTrackModel;
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
  final String filterByApplicantName;
  final String filterByMobileNumber;
  final String filterByWing;
  final String filterByUnit;
  final String filterByFloor;
  final bool? isFinalRegistrationCompleted;
  final String filterByConfiguration;
  final String filterByAgreementValue;
  final String filterByBookingType;
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;
  final String filterByCallLogApplicantName;
  final String filterCallStatus;
  final String filterCallPurpose;
  final String filterCallLogApplicantMobileNumber;
  final DateTime? filterCallLogFromDate;
  final DateTime? filterCallLogToDate;

  const PayTrackState({
    super.isLoading,
    required this.payTrackList,
    required this.payTrackModel,
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
    required this.filterByApplicantName,
    required this.filterByMobileNumber,
    required this.filterByWing,
    required this.filterByUnit,
    required this.filterByFloor,
    required this.isFinalRegistrationCompleted,
    required this.filterByConfiguration,
    required this.filterByAgreementValue,
    required this.filterByBookingType,
    required this.filterByFromDate,
    required this.filterByToDate,
    required this.filterByCallLogApplicantName,
    required this.filterCallStatus,
    required this.filterCallPurpose,
    required this.filterCallLogApplicantMobileNumber,
    this.filterCallLogFromDate,
    this.filterCallLogToDate,
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
    filterByApplicantName: "",
    filterByMobileNumber: "",
    filterByWing: "",
    filterByUnit: "",
    filterByFloor: "",
    isFinalRegistrationCompleted: null,
    filterByConfiguration: "",
    filterByAgreementValue: "",
    filterByBookingType: "",
    filterByFromDate: null,
    filterByToDate: null,
    payTrackModel: null,
    filterByCallLogApplicantName: "",
    filterCallStatus: "",
    filterCallPurpose: "",
    filterCallLogApplicantMobileNumber: "",
    filterCallLogFromDate: null,
    filterCallLogToDate: null,
  );
  static const _noChange = Object();
  PayTrackState copyWith({
    bool? isLoading,

    List<PayTrackModel>? payTrackList,
    PayTrackModel? payTrackModel,
    List<PayTrackCallLogModel>? payTrackCallLogList,
    int? currentPage,
    int? totalNumberOfRecord,
    String? searchText,

    String? filterByApplicantName,
    String? filterByMobileNumber,
    String? filterByWing,
    String? filterByUnit,
    String? filterByFloor,
    bool? isFinalRegistrationCompleted,
    String? filterByConfiguration,
    String? filterByAgreementValue,
    String? filterByBookingType,
    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,
    String? currentSortColumn,
    String? currentSortDirection,
    PayTrackModel? payTrackOverview,
    BookingModel? bookingData,
    EnquiryModel? currentEnquiryDetails,
    bool? isFetchingEnquiryDetails,
    String? filterByCallLogApplicantName,
    String? filterCallStatus,
    String? filterCallPurpose,
    String? filterCallLogApplicantMobileNumber,
    Object? filterCallLogFromDate = _noChange,
    Object? filterCallLogToDate = _noChange,
  }) {
    return PayTrackState(
      isLoading: isLoading ?? this.isLoading,
      payTrackList: payTrackList ?? this.payTrackList,
      payTrackModel: payTrackModel ?? this.payTrackModel,
      payTrackCallLogList: payTrackCallLogList ?? this.payTrackCallLogList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,

      filterByApplicantName:
          filterByApplicantName ?? this.filterByApplicantName,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByWing: filterByWing ?? this.filterByWing,
      filterByUnit: filterByUnit ?? this.filterByUnit,
      filterByFloor: filterByFloor ?? this.filterByFloor,
      isFinalRegistrationCompleted:
          isFinalRegistrationCompleted ?? this.isFinalRegistrationCompleted,
      filterByConfiguration:
          filterByConfiguration ?? this.filterByConfiguration,
      filterByAgreementValue:
          filterByAgreementValue ?? this.filterByAgreementValue,
      filterByBookingType: filterByBookingType ?? this.filterByBookingType,
      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,

      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      payTrackOverview: payTrackOverview ?? this.payTrackOverview,
      bookingData: bookingData ?? this.bookingData,
      currentEnquiryDetails:
          currentEnquiryDetails ?? this.currentEnquiryDetails,

      isFetchingEnquiryDetails:
          isFetchingEnquiryDetails ?? this.isFetchingEnquiryDetails,
      filterByCallLogApplicantName:
          filterByCallLogApplicantName ?? this.filterByCallLogApplicantName,
      filterCallStatus: filterCallStatus ?? this.filterCallStatus,
      filterCallPurpose: filterCallPurpose ?? this.filterCallPurpose,
      filterCallLogApplicantMobileNumber:
          filterCallLogApplicantMobileNumber ??
          this.filterCallLogApplicantMobileNumber,

      filterCallLogFromDate:
          filterCallLogFromDate == _noChange
              ? this.filterCallLogFromDate
              : filterCallLogFromDate as DateTime?,

      filterCallLogToDate:
          filterCallLogToDate == _noChange
              ? this.filterCallLogToDate
              : filterCallLogToDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    payTrackList,
    payTrackModel,
    payTrackCallLogList,
    currentPage,
    totalNumberOfRecord,
    searchText,

    filterByApplicantName,
    filterByMobileNumber,
    filterByWing,
    filterByUnit,
    filterByFloor,
    isFinalRegistrationCompleted,
    filterByConfiguration,
    filterByAgreementValue,
    filterByBookingType,
    filterByFromDate,
    filterByToDate,
    currentSortColumn,
    currentSortDirection,
    payTrackOverview,
    bookingData,
    currentEnquiryDetails,
    isFetchingEnquiryDetails,
    filterByCallLogApplicantName,
    filterCallStatus,
    filterCallPurpose,
    filterCallLogApplicantMobileNumber,
    filterCallLogFromDate,
    filterCallLogToDate,
  ];
}
