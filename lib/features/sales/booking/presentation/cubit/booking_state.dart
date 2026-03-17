part of 'booking_cubit.dart';

class BookingState extends BaseState {
  final List<BookingPaymentScheduleData> bookingPaymentScheduleList;
  final List<ParkingModel> parkingList;
  final List<TermsAndConditionsModel> termsList;
  final int totalNumberOfRecordParking;
  final int totalNumberOfRecordTerms;
  final int currentPageParking;
  final int currentPageTerms;
  final List<OtherChargeModel> otherChargesList;
  final List<EnquiryModel> enquiryList;
  final List<BookingModel> bookingListById;
  final List<BookingModel> bookingList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final int currentTabIndex;
  final int currentTabIndexAddForm;

  const BookingState({
    super.isLoading,
    required this.bookingPaymentScheduleList,
    required this.parkingList,
    required this.termsList,
    required this.totalNumberOfRecordParking,
    required this.totalNumberOfRecordTerms,
    required this.currentPageParking,
    required this.currentPageTerms,
    required this.otherChargesList,
    required this.enquiryList,
    required this.bookingListById,
    required this.bookingList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentTabIndex,
    required this.currentTabIndexAddForm,
  });

  factory BookingState.initial() => BookingState(
    isLoading: true,
    bookingPaymentScheduleList: [],
    parkingList: [],
    termsList: [],
    totalNumberOfRecordParking: 0,
    totalNumberOfRecordTerms: 0,
    currentPageParking: 1,
    currentPageTerms: 1,
    otherChargesList: [],
    enquiryList: [],
    bookingListById: [],
    bookingList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentTabIndex: 0,
    currentTabIndexAddForm: 0,
  );

  BookingState copyWith({
    bool? isLoading,
    List<BookingPaymentScheduleData>? bookingPaymentScheduleList,
    List<ParkingModel>? parkingList,
    List<TermsAndConditionsModel>? termsList,
    int? totalNumberOfRecordParking,
    int? totalNumberOfRecordTerms,
    int? currentPageParking,
    int? currentPageTerms,
    List<OtherChargeModel>? otherChargesList,
    List<EnquiryModel>? enquiryList,
    List<BookingModel>? bookingListById,
    List<BookingModel>? bookingList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    int? currentTabIndex,
    int? currentTabIndexAddForm,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      bookingPaymentScheduleList:
          bookingPaymentScheduleList ?? this.bookingPaymentScheduleList,
      parkingList: parkingList ?? this.parkingList,
      termsList: termsList ?? this.termsList,
      totalNumberOfRecordParking:
          totalNumberOfRecordParking ?? this.totalNumberOfRecordParking,
      totalNumberOfRecordTerms:
          totalNumberOfRecordTerms ?? this.totalNumberOfRecordTerms,
      currentPageParking: currentPageParking ?? this.currentPageParking,
      currentPageTerms: currentPageTerms ?? this.currentPageTerms,
      otherChargesList: otherChargesList ?? this.otherChargesList,
     enquiryList: enquiryList ?? this.enquiryList,
      bookingListById: bookingListById ?? this.bookingListById,
      bookingList: bookingList ?? this.bookingList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentTabIndexAddForm:
          currentTabIndexAddForm ?? this.currentTabIndexAddForm,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bookingPaymentScheduleList,
    parkingList,
    termsList,
    totalNumberOfRecordParking,
    totalNumberOfRecordTerms,
    currentPageParking,
    currentPageTerms,
    otherChargesList,
    enquiryList,
    bookingListById,
    bookingList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentTabIndex,
    currentTabIndexAddForm,
  ];
}
