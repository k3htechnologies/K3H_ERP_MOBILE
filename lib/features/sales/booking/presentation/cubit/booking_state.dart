part of 'booking_cubit.dart';

class BookingState extends BaseState {
  final List<BookingModel> bookingList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final int currentTabIndex;

  const BookingState({
    super.isLoading,
    required this.bookingList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentTabIndex,
  });

  factory BookingState.initial() => BookingState(
    isLoading: true,
    bookingList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentTabIndex: 0,
  );

  BookingState copyWith({
    bool? isLoading,
    List<BookingModel>? bookingList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    int? currentTabIndex,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      bookingList: bookingList ?? this.bookingList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bookingList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentTabIndex,
  ];
}
