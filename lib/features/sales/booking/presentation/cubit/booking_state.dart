part of 'booking_cubit.dart';

class BookingState extends BaseState {
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
      enquiryList: enquiryList ?? this.enquiryList,
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
