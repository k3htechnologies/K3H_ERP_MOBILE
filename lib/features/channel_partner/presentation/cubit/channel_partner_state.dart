part of 'channel_partner_cubit.dart';

class ChannelPartnerState extends BaseState {
  final List<ChannelPartnerModel> channelPartnerList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String filterByCompanyName;
  final String currentSortColumn;
  final String currentSortDirection;

  const ChannelPartnerState({
    super.isLoading,
    super.stateType,
    required this.channelPartnerList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.filterByCompanyName,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory ChannelPartnerState.initial() => ChannelPartnerState(
    channelPartnerList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    filterByCompanyName: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  ChannelPartnerState copyWith({
    bool? isLoading,
    StateType? stateType,
    List<ChannelPartnerModel>? channelPartnerList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? filterByCompanyName,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ChannelPartnerState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      channelPartnerList: channelPartnerList ?? this.channelPartnerList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stateType,
    channelPartnerList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    filterByCompanyName,
    currentSortColumn,
    currentSortDirection,
  ];
}
