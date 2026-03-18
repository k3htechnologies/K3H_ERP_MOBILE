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
  final String currentSortColumn;
  final String currentSortDirection;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String filterWing;
  final String filterMobileNumber;
  final String filterFlat;
  final String filterFloor;
  final String filterSource;
  final String filterSubSource;
  final int filterAgreementValue;
  final String filterBookingType;

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
    this.currentSortColumn = "Created Date",
    this.currentSortDirection = "DESC",
    this.filterStartDate,
    this.filterEndDate,
    this.filterWing = "",
    this.filterMobileNumber = "",
    this.filterFlat = "",
    this.filterFloor = "",
    this.filterSource = "",
    this.filterSubSource = "",
    this.filterAgreementValue = 0,
    this.filterBookingType = "",
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
    filterStartDate: null,
    filterEndDate: null,
    filterWing: "",
    filterMobileNumber: "",
    filterFlat: "",
    filterFloor: "",
    filterSource: "",
    filterSubSource: "",
    filterAgreementValue: 0,
    filterBookingType: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );
  static const _noChange = Object();

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
    String? currentSortColumn,
    String? currentSortDirection,
    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
    String? filterWing,
    String? filterMobileNumber,
    String? filterFlat,
    String? filterFloor,
    String? filterSource,
    String? filterSubSource,
    int? filterAgreementValue,
    String? filterBookingType,
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
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,

      filterStartDate:
          filterStartDate == _noChange
              ? this.filterStartDate
              : filterStartDate as DateTime?,

      filterEndDate:
          filterEndDate == _noChange
              ? this.filterEndDate
              : filterEndDate as DateTime?,

      filterWing: filterWing ?? this.filterWing,
      filterMobileNumber: filterMobileNumber ?? this.filterMobileNumber,
      filterFlat: filterFlat ?? this.filterFlat,
      filterFloor: filterFloor ?? this.filterFloor,
      filterSource: filterSource ?? this.filterSource,
      filterSubSource: filterSubSource ?? this.filterSubSource,
      filterAgreementValue: filterAgreementValue ?? this.filterAgreementValue,
      filterBookingType: filterBookingType ?? this.filterBookingType,
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
    currentSortColumn,
    currentSortDirection,
    filterStartDate,
    filterEndDate,
    filterWing,
    filterMobileNumber,
    filterFlat,
    filterFloor,
    filterSource,
    filterSubSource,
    filterAgreementValue,
    filterBookingType,
  ];
}
