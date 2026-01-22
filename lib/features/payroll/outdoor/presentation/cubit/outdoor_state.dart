part of 'outdoor_cubit.dart';

class OutdoorState extends BaseState {
  final List<OutdoorModel> outdoorList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final int currentTabIndex;

  const OutdoorState({
    super.isLoading,
    required this.outdoorList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentTabIndex,
  });

  factory OutdoorState.initial() => OutdoorState(
    isLoading: true,
    outdoorList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentTabIndex: 0,
  );

  OutdoorState copyWith({
    bool? isLoading,
    List<OutdoorModel>? outdoorList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    int? currentTabIndex,
  }) {
    return OutdoorState(
      isLoading: isLoading ?? this.isLoading,
      outdoorList: outdoorList ?? this.outdoorList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    outdoorList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentTabIndex,
  ];
}

