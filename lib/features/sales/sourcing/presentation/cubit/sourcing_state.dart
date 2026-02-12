part of 'sourcing_cubit.dart';

class SourcingState extends BaseState {
  final List<ChannelPartnerModel> channelPartnerList;
  final int totalNumberOfRecordCP;
  final int currentPageCp;
  final List<SourcingModel> sourcingList;
  final String searchText;
  final int currentTabIndex;
  final bool isIBM;

  const SourcingState({
    super.isLoading,
    required this.channelPartnerList,
    required this.totalNumberOfRecordCP,
    required this.currentPageCp,
    required this.sourcingList,
    required this.searchText,
    required this.currentTabIndex,
    required this.isIBM,
  });

  factory SourcingState.initial() => SourcingState(
    channelPartnerList: [],
    totalNumberOfRecordCP: 0,
    currentPageCp: 1,
    sourcingList: [],
    searchText: "",
    isLoading: true,
    currentTabIndex: 0,
    isIBM: true,
  );

  SourcingState copyWith({
    bool? isLoading,
    List<ChannelPartnerModel>? channelPartnerList,
    int? totalNumberOfRecordCP,
    int? currentPageCp,
    List<SourcingModel>? sourcingList,
    String? searchText,
    int? currentTabIndex,
    bool? isIBM,
  }) {
    return SourcingState(
      isLoading: isLoading ?? this.isLoading,
      channelPartnerList: channelPartnerList ?? this.channelPartnerList,
      totalNumberOfRecordCP: totalNumberOfRecordCP ?? this.totalNumberOfRecordCP,
      currentPageCp: currentPageCp ?? this.currentPageCp,
      sourcingList: sourcingList ?? this.sourcingList,
      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isIBM: isIBM ?? this.isIBM,
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
    isIBM
  ];
}
