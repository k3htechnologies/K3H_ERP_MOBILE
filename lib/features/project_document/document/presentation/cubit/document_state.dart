part of 'document_cubit.dart';

class DocumentState extends BaseState {
  final int categoryIndex;
  final int projectDocumentCategoryId;
  final List<DocumentModel> documentList;
  final List<DocumentModel> subDocumentList;
  final List<DocumentCategoryModel> documentCategoryModelList;
  final int totalNumberOfRecord;
  final int totalNumberOfRecordOfSubDoc;
  final int currentPage;
  final int currentPageOfSubDoc;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const DocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.projectDocumentCategoryId,
    required this.documentList,
    required this.subDocumentList,
    required this.documentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordOfSubDoc,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentPageOfSubDoc,
  });

  factory DocumentState.initial() => DocumentState(
    categoryIndex: 0,
    projectDocumentCategoryId: 0,
    documentList: [],
    subDocumentList: [],
    documentCategoryModelList: [],
    totalNumberOfRecord: 0,
    totalNumberOfRecordOfSubDoc: 0,
    currentPage: 1,
    currentPageOfSubDoc: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  DocumentState copyWith({
    bool? isLoading,
    int? categoryIndex,
    int? currentPageOfSubDoc,
    int? projectDocumentCategoryId,
    List<DocumentModel>? documentList,
    List<DocumentModel>? subDocumentList,
    List<DocumentCategoryModel>? documentCategoryModelList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordOfSubDoc,
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
      subDocumentList: subDocumentList ?? this.subDocumentList,
      documentCategoryModelList:
          documentCategoryModelList ?? this.documentCategoryModelList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      totalNumberOfRecordOfSubDoc:
          totalNumberOfRecordOfSubDoc ?? this.totalNumberOfRecordOfSubDoc,
      currentPage: currentPage ?? this.currentPage,
      currentPageOfSubDoc: currentPageOfSubDoc ?? this.currentPageOfSubDoc,
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
    subDocumentList,
    documentCategoryModelList,
    totalNumberOfRecord,
    totalNumberOfRecordOfSubDoc,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    currentPageOfSubDoc,
  ];
}
