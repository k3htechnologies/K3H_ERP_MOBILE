part of 'content_folder_cubit.dart';

class ContentFolderState extends BaseState {
  final List<ContentFolderModel> marketingContentFolderList;
  final String searchText;

  const ContentFolderState({
    super.isLoading,
    required this.marketingContentFolderList,
    required this.searchText,
  });

  factory ContentFolderState.initial() => ContentFolderState(
    marketingContentFolderList: [],
    searchText: "",
    isLoading: true,
  );

  ContentFolderState copyWith({
    bool? isLoading,
    List<ContentFolderModel>? marketingContentFolderList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    int? selectedFolderCount,
  }) {
    return ContentFolderState(
      isLoading: isLoading ?? this.isLoading,
      marketingContentFolderList:
          marketingContentFolderList ?? this.marketingContentFolderList,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    marketingContentFolderList,
    searchText,
  ];
}
