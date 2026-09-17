part of 'test_document_cubit.dart';

class TestDocumentState extends BaseState {
  final int categoryIndex;
  final int testDocumentCategoryId;
  final List<TestDocumentModel> testDocumentList;
  final List<TestDocumentModel> subTestDocumentList;
  final List<TestDocumentCategoryModel> tesDocumentCategoryModelList;
  final int totalNumberOfRecord;
  final int totalNumberOfRecordOfSubDoc;
  final int currentPage;
  final int currentPageOfSubDoc;
  final String searchText;
  const TestDocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.testDocumentCategoryId,
    required this.testDocumentList,
    required this.subTestDocumentList,
    required this.tesDocumentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.totalNumberOfRecordOfSubDoc,
    required this.currentPageOfSubDoc,
  });

  factory TestDocumentState.initial() => TestDocumentState(
    categoryIndex: 0,
    testDocumentCategoryId: 0,
    testDocumentList: [],
    subTestDocumentList: [],
    tesDocumentCategoryModelList: [],
    totalNumberOfRecord: 0,
    totalNumberOfRecordOfSubDoc: 0,
    currentPage: 1,
    currentPageOfSubDoc: 1,
    searchText: "",
    isLoading: true,
  );

  TestDocumentState copywith({
    bool? isLoading,
    int? categoryIndex,
    int? testDocumentCategoryId,
    List<TestDocumentModel>? testDocumentList,
    List<TestDocumentModel>? subTestDocumentList,
    List<TestDocumentCategoryModel>? tesDocumentCategoryModelList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordOfSubDoc,
    int? currentPage,
    int? currentPageOfSubDoc,
    String? searchText,
  }) {
    return TestDocumentState(
      isLoading: isLoading ?? this.isLoading,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      testDocumentCategoryId:
          testDocumentCategoryId ?? this.testDocumentCategoryId,
      testDocumentList: testDocumentList ?? this.testDocumentList,
      subTestDocumentList: subTestDocumentList ?? this.subTestDocumentList,
      tesDocumentCategoryModelList:
          tesDocumentCategoryModelList ?? this.tesDocumentCategoryModelList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      totalNumberOfRecordOfSubDoc:
          totalNumberOfRecordOfSubDoc ?? this.totalNumberOfRecordOfSubDoc,
      currentPage: currentPage ?? this.currentPage,
      currentPageOfSubDoc: currentPageOfSubDoc ?? this.currentPageOfSubDoc,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    categoryIndex,
    testDocumentCategoryId,
    testDocumentList,
    subTestDocumentList,
    tesDocumentCategoryModelList,
    totalNumberOfRecord,
    totalNumberOfRecordOfSubDoc,
    currentPage,
    currentPageOfSubDoc,
    searchText,
  ];
}
