part of 'request_management_cubit.dart';

class RequestManagementState extends BaseState {
  final BookingModel? bookingData;
  final EnquiryModel? currentEnquiryDetails;
  final bool isFetchingEnquiryDetails;
  final List<ParkingModificationRequestModel> parkingModificationRequestList;
  final List<BookingApplicantModificationRequestModel>
  bookingApplicantModificationRequestModel;
  final List<FlatAlterationRequestsModel> flatAlterationRequestsModel;
  final List<BookingModel> refundRequestList;
  final bool showRefundPaymentLedgerTab;
  final List<RefundedAmountLedgerModel> refundAmountLedgerList;
  final int totalNumberOfRecord;
  final bool isActivityLoading;
  final int currentPage;
  const RequestManagementState({
    super.isLoading,
    required this.bookingData,
    required this.currentEnquiryDetails,
    required this.isFetchingEnquiryDetails,
    required this.parkingModificationRequestList,
    required this.bookingApplicantModificationRequestModel,
    required this.flatAlterationRequestsModel,
    required this.refundRequestList,
    required this.showRefundPaymentLedgerTab,
    required this.refundAmountLedgerList,
    required this.totalNumberOfRecord,
    required this.isActivityLoading,
    required this.currentPage,
  });

  factory RequestManagementState.initial() => RequestManagementState(
    isLoading: true,
    bookingData: null,
    currentEnquiryDetails: null,
    isFetchingEnquiryDetails: false,
    parkingModificationRequestList: [],
    bookingApplicantModificationRequestModel: [],
    flatAlterationRequestsModel: [],
    refundRequestList: [],
    showRefundPaymentLedgerTab: false,
    refundAmountLedgerList: [],
    totalNumberOfRecord: 0,
    isActivityLoading: false,
    currentPage: 1,
  );

  RequestManagementState copyWith({
    bool? isLoading,
    BookingModel? bookingData,
    EnquiryModel? currentEnquiryDetails,
    bool? isFetchingEnquiryDetails,
    List<ParkingModificationRequestModel>? parkingModificationRequestList,
    List<BookingApplicantModificationRequestModel>?
    bookingApplicantModificationRequestModel,
    List<FlatAlterationRequestsModel>? flatAlterationRequestsModel,
    List<BookingModel>? refundRequestList,
    bool? showRefundPaymentLedgerTab,
    List<RefundedAmountLedgerModel>? refundAmountLedgerList,
    int? totalNumberOfRecord,
    bool? isActivityLoading,
    int? currentPage,
  }) {
    return RequestManagementState(
      isLoading: isLoading ?? this.isLoading,
      bookingData: bookingData ?? this.bookingData,
      currentEnquiryDetails:
          currentEnquiryDetails ?? this.currentEnquiryDetails,
      isFetchingEnquiryDetails:
          isFetchingEnquiryDetails ?? this.isFetchingEnquiryDetails,
      parkingModificationRequestList:
          parkingModificationRequestList ?? this.parkingModificationRequestList,
      bookingApplicantModificationRequestModel:
          bookingApplicantModificationRequestModel ??
          this.bookingApplicantModificationRequestModel,
      flatAlterationRequestsModel:
          flatAlterationRequestsModel ?? this.flatAlterationRequestsModel,
      refundRequestList: refundRequestList ?? this.refundRequestList,
      showRefundPaymentLedgerTab:
          showRefundPaymentLedgerTab ?? this.showRefundPaymentLedgerTab,
      refundAmountLedgerList:
          refundAmountLedgerList ?? this.refundAmountLedgerList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      isActivityLoading: isActivityLoading ?? this.isActivityLoading,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bookingData,
    currentEnquiryDetails,
    isFetchingEnquiryDetails,
    parkingModificationRequestList,
    bookingApplicantModificationRequestModel,
    flatAlterationRequestsModel,
    refundRequestList,
    showRefundPaymentLedgerTab,
    refundAmountLedgerList,
    totalNumberOfRecord,
    isActivityLoading,
    currentPage,
  ];
}
