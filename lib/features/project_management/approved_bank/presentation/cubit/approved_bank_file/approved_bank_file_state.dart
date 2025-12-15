part of 'approved_bank_file_cubit.dart';

class ApprovedBankFileState extends BaseState {
  final List<ApprovedBankFileModel> approvedBankFileList;
  final String searchTextFile;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;

  const ApprovedBankFileState({
    super.isLoading,
    required this.approvedBankFileList,
    required this.searchTextFile,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory ApprovedBankFileState.initial() => ApprovedBankFileState(
    approvedBankFileList: [],
    isLoading: true,
    searchTextFile: "",
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  ApprovedBankFileState copyWith({
    bool? isLoading,
    List<ApprovedBankFileModel>? approvedBankFileList,
    String? searchTextFile,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ApprovedBankFileState(
      isLoading: isLoading ?? this.isLoading,
      approvedBankFileList: approvedBankFileList ?? this.approvedBankFileList,
      searchTextFile: searchTextFile ?? this.searchTextFile,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    approvedBankFileList,
    searchTextFile,
    totalNumberOfRecord,
    currentPage,
    currentSortColumn,
    currentSortDirection,
  ];
}
