part of 'bank_list_master_cubit.dart';

class BankListMasterState extends BaseState {
  final List<BankListMasterModel> bankList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  const BankListMasterState({
    super.isLoading,
    required this.bankList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });

  factory BankListMasterState.initial() => BankListMasterState(
    bankList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
  );

  BankListMasterState copyWith({
    bool? isLoading,
    List<BankListMasterModel>? bankList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return BankListMasterState(
      isLoading: isLoading ?? this.isLoading,
      bankList: bankList ?? this.bankList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bankList,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];
}
