part of 'approved_bank_folder_cubit.dart';

class ApprovedBankFolderState extends BaseState {
  final List<BankListMasterModel> bankList;
  final int totalNumberOfRecordBank;
  final int currentPageBank;
  final List<ApprovedBankFolderModel> approvedBankFolderList;
  final int totalNumberOfRecordBankFolder;
  final int currentPageBankFolder;
  final String searchTextFolder;
  final String searchTextBank;
  final List<ApprovedBankFileModel> approvedBankFileList;
  final String searchTextFile;
  final int totalNumberOfRecordBankFile;
  final int currentPageBankFile;
  final String currentSortColumnBankFolder;
  final String currentSortDirectionBankFolder;
  final String currentSortColumnBankFile;
  final String currentSortDirectionBankFile;

  const ApprovedBankFolderState({
    super.isLoading,
    required this.bankList,
    required this.totalNumberOfRecordBank,
    required this.currentPageBank,
    required this.approvedBankFolderList,
    required this.totalNumberOfRecordBankFolder,
    required this.currentPageBankFolder,
    required this.searchTextFolder,
    required this.searchTextBank,
    required this.approvedBankFileList,
    required this.searchTextFile,
    required this.totalNumberOfRecordBankFile,
    required this.currentPageBankFile,
    required this.currentSortColumnBankFolder,
    required this.currentSortDirectionBankFolder,
    required this.currentSortColumnBankFile,
    required this.currentSortDirectionBankFile,
  });

  factory ApprovedBankFolderState.initial() => ApprovedBankFolderState(
    bankList: [],
    totalNumberOfRecordBank: 0,
    currentPageBank: 1,
    approvedBankFolderList: [],
    totalNumberOfRecordBankFolder: 0,
    currentPageBankFolder: 1,
    isLoading: true,
    searchTextFolder: "",
    searchTextBank: "",
    approvedBankFileList: [],
    searchTextFile: "",
    totalNumberOfRecordBankFile: 0,
    currentPageBankFile: 1,
    currentSortColumnBankFolder: "Created Date",
    currentSortDirectionBankFolder: "DESC",
    currentSortColumnBankFile: "Created Date",
    currentSortDirectionBankFile: "DESC",
  );

  ApprovedBankFolderState copyWith({
    bool? isLoading,
    List<BankListMasterModel>? bankList,
    int? totalNumberOfRecordBank,
    int? currentPageBank,
    List<ApprovedBankFolderModel>? approvedBankFolderList,
    int? totalNumberOfRecordBankFolder,
    int? currentPageBankFolder,
    String? searchTextFolder,
    String? searchTextBank,
    List<ApprovedBankFileModel>? approvedBankFileList,
    String? searchTextFile,
    int? totalNumberOfRecordBankFile,
    int? currentPageBankFile,
    String? currentSortColumnBankFolder,
    String? currentSortDirectionBankFolder,
    String? currentSortColumnBankFile,
    String? currentSortDirectionBankFile,
  }) {
    return ApprovedBankFolderState(
      isLoading: isLoading ?? this.isLoading,
      bankList: bankList ?? this.bankList,
      totalNumberOfRecordBank:
          totalNumberOfRecordBank ?? this.totalNumberOfRecordBank,
      currentPageBank: currentPageBank ?? this.currentPageBank,
      approvedBankFolderList:
          approvedBankFolderList ?? this.approvedBankFolderList,
      totalNumberOfRecordBankFolder:
          totalNumberOfRecordBankFolder ?? this.totalNumberOfRecordBankFolder,
      currentPageBankFolder:
          currentPageBankFolder ?? this.currentPageBankFolder,
      searchTextFolder: searchTextFolder ?? this.searchTextFolder,
      searchTextBank: searchTextBank ?? this.searchTextBank,
      approvedBankFileList: approvedBankFileList ?? this.approvedBankFileList,
      searchTextFile: searchTextFile ?? this.searchTextFile,
      totalNumberOfRecordBankFile:
          totalNumberOfRecordBankFile ?? this.totalNumberOfRecordBankFile,
      currentPageBankFile: currentPageBankFile ?? this.currentPageBankFile,
      currentSortColumnBankFolder:
          currentSortColumnBankFolder ?? this.currentSortColumnBankFolder,
      currentSortDirectionBankFolder:
          currentSortDirectionBankFolder ?? this.currentSortDirectionBankFolder,
      currentSortColumnBankFile:
          currentSortColumnBankFile ?? this.currentSortColumnBankFile,
      currentSortDirectionBankFile:
          currentSortDirectionBankFile ?? this.currentSortDirectionBankFile,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    bankList,
    totalNumberOfRecordBank,
    currentPageBank,
    approvedBankFolderList,
    totalNumberOfRecordBankFolder,
    currentPageBankFolder,
    searchTextFolder,
    searchTextBank,
    approvedBankFileList,
    searchTextFile,
    totalNumberOfRecordBankFile,
    currentPageBankFile,
    currentSortColumnBankFolder,
    currentSortDirectionBankFolder,
    currentSortColumnBankFile,
    currentSortDirectionBankFile,
  ];
}
