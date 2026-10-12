part of 'drawing_document_category_cubit.dart';

class DrawingDocumentCategoryState extends BaseState {
  final List<DrawingDocumentCategoryModel> drawingDocumentCategoryModelList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  const DrawingDocumentCategoryState({
    super.isLoading,
    required this.drawingDocumentCategoryModelList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory DrawingDocumentCategoryState.initial() =>
      DrawingDocumentCategoryState(
        isLoading: true,
        drawingDocumentCategoryModelList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        searchText: "",
        currentSortColumn: "Created Date",
        currentSortDirection: "DESC",
      );
  DrawingDocumentCategoryState copyWith({
    bool? isLoading,
    List<DrawingDocumentCategoryModel>? drawingDocumentCategoryModelList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return DrawingDocumentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      drawingDocumentCategoryModelList:
          drawingDocumentCategoryModelList ??
          this.drawingDocumentCategoryModelList,
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
    drawingDocumentCategoryModelList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
