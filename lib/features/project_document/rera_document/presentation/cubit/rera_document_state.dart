import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';

class RERADocumentState extends BaseState {
  final int categoryIndex;
  final int projectRERADocumentCategoryId;
  final List<RERADocumentModel> reraDocumentList;
  final List<RERADocumentModel> reraSubDocumentList;
  final List<RERADocumentCategoryModel> documentCategoryModelList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int currentPageOfSubDoc;
  final int totalNumberOfRecordOfSubDoc;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const RERADocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.projectRERADocumentCategoryId,
    required this.reraDocumentList,
    required this.reraSubDocumentList,
    required this.documentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordOfSubDoc,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentPageOfSubDoc,
  });

  factory RERADocumentState.initial() => RERADocumentState(
    categoryIndex: 0,
    projectRERADocumentCategoryId: 0,
    reraDocumentList: [],
    reraSubDocumentList: [],
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

  RERADocumentState copyWith({
    bool? isLoading,
    int? categoryIndex,
    int? currentPageOfSubDoc,
    int? projectRERADocumentCategoryId,
    List<RERADocumentModel>? reraDocumentList,
    List<RERADocumentModel>? reraSubDocumentList,
    List<RERADocumentCategoryModel>? documentCategoryModelList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordOfSubDoc,
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
      reraDocumentList: reraDocumentList ?? this.reraDocumentList,
      reraSubDocumentList: reraSubDocumentList ?? this.reraSubDocumentList,
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
    projectRERADocumentCategoryId,
    reraDocumentList,
    reraSubDocumentList,
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
