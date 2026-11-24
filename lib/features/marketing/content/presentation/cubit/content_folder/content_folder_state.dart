part of 'content_folder_cubit.dart';

class ContentFolderState extends BaseState {
  final List<ContentFolderModel> marketingContentFolderList;
  final String searchText;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByContentName;
  const ContentFolderState({
    super.isLoading,
    required this.marketingContentFolderList,
    required this.searchText,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByContentName,
  });

  factory ContentFolderState.initial() => ContentFolderState(
    marketingContentFolderList: [],
    searchText: "",
    isLoading: true,
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: '',
    currentSortDirection: '',
    filterByContentName: '',
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
    String? filterByContentName,
  }) {
    return ContentFolderState(
      isLoading: isLoading ?? this.isLoading,
      marketingContentFolderList:
          marketingContentFolderList ?? this.marketingContentFolderList,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByContentName: filterByContentName ?? this.filterByContentName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    marketingContentFolderList,
    searchText,
    totalNumberOfRecord,
    currentPage,
    currentSortColumn,
    currentSortDirection,
    filterByContentName,
  ];
}
