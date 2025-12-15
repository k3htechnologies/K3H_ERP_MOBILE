part of 'approved_bank_folder_cubit.dart';

class ApprovedBankFolderState extends BaseState {
  final List<ApprovedBankFolderModel> approvedBankFolderList;
  final String searchTextFolder;

  const ApprovedBankFolderState({
    super.isLoading,
    required this.approvedBankFolderList,
    required this.searchTextFolder,
  });

  factory ApprovedBankFolderState.initial() => ApprovedBankFolderState(
    approvedBankFolderList: [],
    isLoading: true,
    searchTextFolder: "",
  );

  ApprovedBankFolderState copyWith({
    bool? isLoading,
    List<ApprovedBankFolderModel>? approvedBankFolderList,
    String? searchTextFolder,
  }) {
    return ApprovedBankFolderState(
      isLoading: isLoading ?? this.isLoading,
      approvedBankFolderList: approvedBankFolderList ?? this.approvedBankFolderList,
      searchTextFolder: searchTextFolder ?? this.searchTextFolder,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    approvedBankFolderList,
    searchTextFolder,
  ];
}
