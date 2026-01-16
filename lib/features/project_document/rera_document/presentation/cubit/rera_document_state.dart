import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';

class RERADocumentState extends BaseState {
  final int categoryIndex;
  final int projectRERADocumentCategoryId;
  final List<RERADocumentModel> documentList;
  final List<RERADocumentModel> subDocumentList;
  final List<RERADocumentCategoryModel> documentCategoryModelList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int currentPageOfSubDoc;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const RERADocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.projectRERADocumentCategoryId,
    required this.documentList,
    required this.subDocumentList,
    required this.documentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentPageOfSubDoc,
  });

  factory RERADocumentState.initial() => RERADocumentState(
    categoryIndex: 0,
    projectRERADocumentCategoryId: 0,
    documentList: [],
    subDocumentList: [],
    documentCategoryModelList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentPageOfSubDoc: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  RERADocumentState copyWith({
    bool? isLoading,
    int? categoryIndex,
    int? currentPageOfSubDoc,
    int? projectRERADocumentCategoryId,
    List<RERADocumentModel>? documentList,
    List<RERADocumentModel>? subDocumentList,
    List<RERADocumentCategoryModel>? documentCategoryModelList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return RERADocumentState(
      isLoading: isLoading ?? this.isLoading,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      projectRERADocumentCategoryId:
          projectRERADocumentCategoryId ?? this.projectRERADocumentCategoryId,
      documentList: documentList ?? this.documentList,
      subDocumentList: subDocumentList ?? this.subDocumentList,
      documentCategoryModelList:
          documentCategoryModelList ?? this.documentCategoryModelList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
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
    projectRERADocumentCategoryId,
    documentList,
    subDocumentList,
    documentCategoryModelList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    currentPageOfSubDoc,
  ];
}
