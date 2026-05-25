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
  const RequestManagementState({
    super.isLoading,
    required this.bookingData,
    required this.currentEnquiryDetails,
    required this.isFetchingEnquiryDetails,
    required this.parkingModificationRequestList,
    required this.bookingApplicantModificationRequestModel,
    required this.flatAlterationRequestsModel,
    required this.refundRequestList,
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
  ];
}
