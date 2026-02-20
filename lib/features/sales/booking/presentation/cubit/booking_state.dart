part of 'booking_cubit.dart';

class BookingState extends BaseState {
  final List<PaymentScheduleMasterModel> paymentScheduleMasterList;
  final List<ParkingModel> parkingList;
  final List<TermsAndConditionsModel> termsList;
  final int totalNumberOfRecordParking;
  final int totalNumberOfRecordTerms;
  final int currentPageParking;
  final int currentPageTerms;
  final List<OtherChargeModel> otherChargesList;
  final List<EnquiryModel> enquiryList;
  final List<EnquiryModel> enquiryListById;
  final List<BookingModel> bookingListById;
  final List<BookingModel> bookingList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final int currentTabIndex;
  final int currentTabIndexAddForm;

  const BookingState({
    super.isLoading,
    required this.paymentScheduleMasterList,
    required this.parkingList,
    required this.termsList,
    required this.totalNumberOfRecordParking,
    required this.totalNumberOfRecordTerms,
    required this.currentPageParking,
    required this.currentPageTerms,
    required this.otherChargesList,
    required this.enquiryList,
    required this.enquiryListById,
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
    paymentScheduleMasterList: [],
    parkingList: [],
    termsList: [],
    totalNumberOfRecordParking: 0,
    totalNumberOfRecordTerms: 0,
    currentPageParking: 1,
    currentPageTerms: 1,
    otherChargesList: [],
    enquiryList: [],
    enquiryListById: [],
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
    List<PaymentScheduleMasterModel>? paymentScheduleMasterList,
    List<ParkingModel>? parkingList,
    List<TermsAndConditionsModel>? termsList,
    int? totalNumberOfRecordParking,
    int? totalNumberOfRecordTerms,
    int? currentPageParking,
    int? currentPageTerms,
    List<OtherChargeModel>? otherChargesList,
    List<EnquiryModel>? enquiryList,
    List<EnquiryModel>? enquiryListById,
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
      paymentScheduleMasterList: paymentScheduleMasterList ?? this.paymentScheduleMasterList,
      parkingList: parkingList ?? this.parkingList,
      termsList: termsList ?? this.termsList,
      totalNumberOfRecordParking: totalNumberOfRecordParking ?? this.totalNumberOfRecordParking,
      totalNumberOfRecordTerms: totalNumberOfRecordTerms ?? this.totalNumberOfRecordTerms,
      currentPageParking: currentPageParking ?? this.currentPageParking,
      currentPageTerms: currentPageTerms ?? this.currentPageTerms,
      otherChargesList: otherChargesList ?? this.otherChargesList,
      enquiryList: enquiryList ?? this.enquiryList,
      enquiryListById: enquiryListById ?? this.enquiryListById,
      bookingListById: bookingListById ?? this.bookingListById,
      bookingList: bookingList ?? this.bookingList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentTabIndexAddForm: currentTabIndexAddForm ?? this.currentTabIndexAddForm,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentScheduleMasterList,
    parkingList,
    termsList,
    totalNumberOfRecordParking,
    totalNumberOfRecordTerms,
    currentPageParking,
    currentPageTerms,
    otherChargesList,
    enquiryList,
    enquiryListById,
    bookingListById,
    bookingList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentTabIndex,
    currentTabIndexAddForm,
  ];
}
