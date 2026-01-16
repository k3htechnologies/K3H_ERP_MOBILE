import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';

class RERADocumentCategoryState extends BaseState {
  final List<RERADocumentCategoryModel> reraDocumentCategoryList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const RERADocumentCategoryState({
    super.isLoading,
    required this.reraDocumentCategoryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory RERADocumentCategoryState.initial() => RERADocumentCategoryState(
    reraDocumentCategoryList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "",
    currentSortDirection: "",
  );

  RERADocumentCategoryState copyWith({
    bool? isLoading,
    List<RERADocumentCategoryModel>? documentCategoryList,
    List<RERADocumentCategoryModel>? reraDocumentCategoryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return RERADocumentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      reraDocumentCategoryList:
          documentCategoryList ?? this.reraDocumentCategoryList,
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
    reraDocumentCategoryList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
