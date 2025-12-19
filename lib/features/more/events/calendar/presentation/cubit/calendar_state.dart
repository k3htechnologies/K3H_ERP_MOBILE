part of 'calendar_cubit.dart';

class CalendarState extends BaseState {
  final List<CalendarEventModel> eventsList;
  final int totalNumberOfRecord;
  final int currentPage;
  final bool isLoadingDateDetail;
  final List<CalendarEventModel> dateDetailEvents;

  const CalendarState({
    super.isLoading = false,
    this.eventsList = const [],
    this.totalNumberOfRecord = 0,
    this.currentPage = 1,
    this.isLoadingDateDetail = false,
    this.dateDetailEvents = const [],
  });

  factory CalendarState.initial() => const CalendarState();

  CalendarState copyWith({
    bool? isLoading,
    List<CalendarEventModel>? eventsList,
    int? totalNumberOfRecord,
    int? currentPage,
    bool? isLoadingDateDetail,
    List<CalendarEventModel>? dateDetailEvents,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      eventsList: eventsList ?? this.eventsList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      isLoadingDateDetail: isLoadingDateDetail ?? this.isLoadingDateDetail,
      dateDetailEvents: dateDetailEvents ?? this.dateDetailEvents,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    eventsList,
    totalNumberOfRecord,
    currentPage,
    isLoadingDateDetail,
    dateDetailEvents,
  ];
}
