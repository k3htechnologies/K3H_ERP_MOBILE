part of 'document_category_cubit.dart';

class DocumentCategoryState extends BaseState {
  final List<DocumentCategoryModel> documentCategoryList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const DocumentCategoryState({
    super.isLoading,
    required this.documentCategoryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory DocumentCategoryState.initial() => DocumentCategoryState(
    documentCategoryList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "",
    currentSortDirection: "",
  );

  DocumentCategoryState copyWith({
    bool? isLoading,
    List<DocumentCategoryModel>? documentCategoryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return DocumentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      documentCategoryList: documentCategoryList ?? this.documentCategoryList,
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
    documentCategoryList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
