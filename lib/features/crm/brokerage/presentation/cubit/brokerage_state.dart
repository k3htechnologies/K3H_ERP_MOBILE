part of 'brokerage_cubit.dart';

class BrokerageState extends BaseState {
  final List<BrokerageModel> brokerageList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  const BrokerageState({
    super.isLoading,
    required this.brokerageList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });

  factory BrokerageState.initial() => BrokerageState(
    isLoading: true,
    brokerageList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
  );

  BrokerageState copyWith({
    bool? isLoading,
    List<BrokerageModel>? brokerageList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return BrokerageState(
      isLoading: isLoading ?? this.isLoading,
      brokerageList: brokerageList ?? this.brokerageList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    brokerageList,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];

}

