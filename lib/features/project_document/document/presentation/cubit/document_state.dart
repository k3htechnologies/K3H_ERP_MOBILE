part of 'document_cubit.dart';

class DocumentState extends BaseState {
  final int categoryIndex;
  final int projectDocumentCategoryId;
  final List<DocumentModel> documentList;
  final List<DocumentCategoryModel> documentCategoryModelList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const DocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.projectDocumentCategoryId,
    required this.documentList,
    required this.documentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory DocumentState.initial() => DocumentState(
    categoryIndex: 0,
    projectDocumentCategoryId: 0,
    documentList: [],
    documentCategoryModelList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  DocumentState copyWith({
    bool? isLoading,
    int? categoryIndex,
    int? projectDocumentCategoryId,
    List<DocumentModel>? documentList,
    List<DocumentCategoryModel>? documentCategoryModelList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      projectDocumentCategoryId:
      projectDocumentCategoryId ?? this.projectDocumentCategoryId,
      documentList: documentList ?? this.documentList,
      documentCategoryModelList:
      documentCategoryModelList ?? this.documentCategoryModelList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    categoryIndex,
    projectDocumentCategoryId,
    documentList,
    documentCategoryModelList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
