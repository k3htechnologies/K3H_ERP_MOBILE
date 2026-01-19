import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';

class ApprovalCategoryState extends BaseState {
  final List<ApprovalDocumentCategoryModel> approvalCategoryList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const ApprovalCategoryState({
    super.isLoading,
    required this.approvalCategoryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory ApprovalCategoryState.initial() => ApprovalCategoryState(
    approvalCategoryList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "",
    currentSortDirection: "",
  );

  ApprovalCategoryState copyWith({
    bool? isLoading,
    List<ApprovalDocumentCategoryModel>? approvalCategoryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return ApprovalCategoryState(
      isLoading: isLoading ?? this.isLoading,
      approvalCategoryList: approvalCategoryList ?? this.approvalCategoryList,
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
    approvalCategoryList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
