

import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';

class ApprovalDocumentState extends BaseState {
  final int categoryIndex;
  final int approvalDocumentCategoryId;
  final List<ApprovalDocumentModel> documentList;
  final List<ApprovalDocumentModel> subApprovalDocumentList;
  final List<ApprovalDocumentCategoryModel> documentCategoryModelList;
  final int totalNumberOfRecord;
  final int totalNumberOfRecordOfSubDoc;
  final int currentPage;
  final int currentPageOfSubDoc;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const ApprovalDocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.approvalDocumentCategoryId,
    required this.documentList,
    required this.subApprovalDocumentList,
    required this.documentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordOfSubDoc,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentPageOfSubDoc,
  });

  factory ApprovalDocumentState.initial() => ApprovalDocumentState(
    categoryIndex: 0,
    approvalDocumentCategoryId: 0,
    documentList: [],
    subApprovalDocumentList: [],
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

  ApprovalDocumentState copyWith({
    bool? isLoading,
    int? categoryIndex,
    int? currentPageOfSubDoc,
    int? approvalDocumentCategoryId,
    List<ApprovalDocumentModel>? documentList,
    List<ApprovalDocumentModel>? subApprovalDocumentList,
    List<ApprovalDocumentCategoryModel>? documentCategoryModelList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordOfSubDoc,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ApprovalDocumentState(
      isLoading: isLoading ?? this.isLoading,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      approvalDocumentCategoryId:
          approvalDocumentCategoryId ?? this.approvalDocumentCategoryId,
      documentList: documentList ?? this.documentList,
      subApprovalDocumentList: subApprovalDocumentList ?? this.subApprovalDocumentList,
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
    approvalDocumentCategoryId,
    documentList,
    subApprovalDocumentList,
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
