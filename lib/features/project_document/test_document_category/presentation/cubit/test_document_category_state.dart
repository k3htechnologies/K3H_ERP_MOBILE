part of 'test_document_category_cubit.dart';

class TestDocumentCategoryState extends BaseState {
  final List<TestDocumentCategoryModel> testDocumentCategoryModelList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  const TestDocumentCategoryState({
    super.isLoading,
    required this.testDocumentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });
  factory TestDocumentCategoryState.initial() => TestDocumentCategoryState(
    testDocumentCategoryModelList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );
  TestDocumentCategoryState copyWith({
    bool? isLoading,
    List<TestDocumentCategoryModel>? testDocumentCategoryModelList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return TestDocumentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      testDocumentCategoryModelList:
          testDocumentCategoryModelList ?? this.testDocumentCategoryModelList,
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
    testDocumentCategoryModelList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
