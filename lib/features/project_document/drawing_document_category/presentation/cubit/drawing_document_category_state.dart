part of 'drawing_document_category_cubit.dart';

class DrawingDocumentCategoryState extends BaseState {
  final List<DrawingDocumentCategoryModel> drawingDocumentCategoryList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  const DrawingDocumentCategoryState({
    super.isLoading,
    required this.drawingDocumentCategoryList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });
  factory DrawingDocumentCategoryState.initial() =>
      DrawingDocumentCategoryState(
        isLoading: true,
        drawingDocumentCategoryList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        searchText: "",
        currentSortColumn: "",
        currentSortDirection: "",
      );
  DrawingDocumentCategoryState copyWith({
    bool? isLoading,
    List<DrawingDocumentCategoryModel>? drawingDocumentCategoryList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return DrawingDocumentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      drawingDocumentCategoryList:
          drawingDocumentCategoryList ?? this.drawingDocumentCategoryList,
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
    drawingDocumentCategoryList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
