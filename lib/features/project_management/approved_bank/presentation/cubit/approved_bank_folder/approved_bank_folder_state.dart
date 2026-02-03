part of 'approved_bank_folder_cubit.dart';

class ApprovedBankFolderState extends BaseState {
  final List<BankListMasterModel> bankList;
  final int totalNumberOfRecordBank;
  final int currentPageBank;
  final List<ApprovedBankFolderModel> approvedBankFolderList;
  final String searchTextFolder;

  const ApprovedBankFolderState({
    super.isLoading,
    required this.bankList,
    required this.totalNumberOfRecordBank,
    required this.currentPageBank,
    required this.approvedBankFolderList,
    required this.searchTextFolder,
  });

  factory ApprovedBankFolderState.initial() => ApprovedBankFolderState(
    bankList: [],
    totalNumberOfRecordBank: 0,
    currentPageBank: 1,
    approvedBankFolderList: [],
    isLoading: true,
    searchTextFolder: "",
  );

  ApprovedBankFolderState copyWith({
    bool? isLoading,
    List<BankListMasterModel>? bankList,
    int? totalNumberOfRecordBank,
    int? currentPageBank,
    List<ApprovedBankFolderModel>? approvedBankFolderList,
    String? searchTextFolder,
  }) {
    return ApprovedBankFolderState(
      isLoading: isLoading ?? this.isLoading,
      bankList: bankList ?? this.bankList,
      totalNumberOfRecordBank: totalNumberOfRecordBank ?? this.totalNumberOfRecordBank,
      currentPageBank: currentPageBank ?? this.currentPageBank,
      approvedBankFolderList: approvedBankFolderList ?? this.approvedBankFolderList,
      searchTextFolder: searchTextFolder ?? this.searchTextFolder,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bankList,
    totalNumberOfRecordBank,
    currentPageBank,
    approvedBankFolderList,
    searchTextFolder,
  ];
}
