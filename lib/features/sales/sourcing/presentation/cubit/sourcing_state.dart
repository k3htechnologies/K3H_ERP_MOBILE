part of 'sourcing_cubit.dart';

class SourcingState extends BaseState {
  final List<ChannelPartnerModel> channelPartnerList;
  final int totalNumberOfRecordCP;
  final int currentPageCp;
  final List<SourcingModel> sourcingList;
  final String searchText;
  final int currentTabIndex;
  final String selectedFilter;

  const SourcingState({
    super.isLoading,
    required this.channelPartnerList,
    required this.totalNumberOfRecordCP,
    required this.currentPageCp,
    required this.sourcingList,
    required this.searchText,
    required this.currentTabIndex,
    required this.selectedFilter,
  });

  factory SourcingState.initial() => SourcingState(
    channelPartnerList: [],
    totalNumberOfRecordCP: 0,
    currentPageCp: 1,
    sourcingList: [],
    searchText: "",
    isLoading: true,
    currentTabIndex: 0,
    selectedFilter: "ALL",
  );

  SourcingState copyWith({
    bool? isLoading,
    List<ChannelPartnerModel>? channelPartnerList,
    int? totalNumberOfRecordCP,
    int? currentPageCp,
    List<SourcingModel>? sourcingList,
    String? searchText,
    int? currentTabIndex,
    String? selectedFilter,
  }) {
    return SourcingState(
      isLoading: isLoading ?? this.isLoading,
      channelPartnerList: channelPartnerList ?? this.channelPartnerList,
      totalNumberOfRecordCP: totalNumberOfRecordCP ?? this.totalNumberOfRecordCP,
      currentPageCp: currentPageCp ?? this.currentPageCp,
      sourcingList: sourcingList ?? this.sourcingList,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    channelPartnerList,
    totalNumberOfRecordCP,
    currentPageCp,
    sourcingList,
    searchText,
    currentTabIndex,
    selectedFilter
  ];
}
