part of 'content_document_cubit.dart';

class ContentDocumentState extends BaseState {
  final List<ContentDocumentModel> marketingContentDocumentList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final int selectedFolderCount;
  final String currentSortColumn;
  final String currentSortDirection;

  const ContentDocumentState({
    super.isLoading,
    required this.marketingContentDocumentList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    this.selectedFolderCount = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory ContentDocumentState.initial() => ContentDocumentState(
    marketingContentDocumentList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  ContentDocumentState copyWith({
    bool? isLoading,
    List<ContentDocumentModel>? marketingContentDocumentList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    int? selectedFolderCount,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ContentDocumentState(
      isLoading: isLoading ?? this.isLoading,
      marketingContentDocumentList:
      marketingContentDocumentList ?? this.marketingContentDocumentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      selectedFolderCount: selectedFolderCount ?? this.selectedFolderCount,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    marketingContentDocumentList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    selectedFolderCount,
    currentSortColumn,
    currentSortDirection,
  ];
}
