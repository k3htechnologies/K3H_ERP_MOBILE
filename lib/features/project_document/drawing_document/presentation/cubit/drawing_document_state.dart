part of 'drawing_document_cubit.dart';

class DrawingDocumentState extends BaseState {
  final int categoryIndex;
  final int drawingDocumentCategoryId;
  final List<DrawingDocumentModel> drawingDocumentList;
  final List<DrawingDocumentModel> subDrawingDocumentList;
  final List<DrawingDocumentCategoryModel> drawingDocumentCategoryModelList;
  final List<InventoryDrawingDocumentModel> inventoryDrawingDocumentList;
  final int totalNumberOfRecord;
  final int totalNumberOfRecordOfSubDoc;
  final int currentPage;
  final int currentPageOfSubDoc;
  final String searchText;
  final String buildingNumberText;
  final String wingText;
  final String floorText;
  final String currentSortColumn;
  final String currentSortDirection;
  const DrawingDocumentState({
    super.isLoading,
    required this.categoryIndex,
    required this.drawingDocumentCategoryId,
    required this.drawingDocumentList,
    required this.subDrawingDocumentList,
    required this.drawingDocumentCategoryModelList,
    required this.inventoryDrawingDocumentList,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordOfSubDoc,
    required this.currentPage,
    required this.currentPageOfSubDoc,
    required this.searchText,
    required this.buildingNumberText,
    required this.wingText,
    required this.floorText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });
  factory DrawingDocumentState.initial() => DrawingDocumentState(
    isLoading: true,
    categoryIndex: 0,
    drawingDocumentCategoryId: 0,
    drawingDocumentList: [],
    subDrawingDocumentList: [],
    drawingDocumentCategoryModelList: [],
    inventoryDrawingDocumentList: [],
    totalNumberOfRecord: 0,
    totalNumberOfRecordOfSubDoc: 0,
    currentPage: 1,
    currentPageOfSubDoc: 1,
    searchText: '',
    buildingNumberText: '',
    wingText: '',
    floorText: '',
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  DrawingDocumentState copyWith({
    bool? isLoading,
    int? categoryIndex,
    int? drawingDocumentCategoryId,
    List<DrawingDocumentModel>? drawingDocumentList,
    List<DrawingDocumentModel>? subDrawingDocumentList,
    List<DrawingDocumentCategoryModel>? drawingDocumentCategoryModelList,
    List<InventoryDrawingDocumentModel>? inventoryDrawingDocumentList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordOfSubDoc,
    int? currentPage,
    int? currentPageOfSubDoc,
    String? searchText,
    String? buildingNumberText,
    String? wingText,
    String? floorText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return DrawingDocumentState(
      isLoading: isLoading ?? this.isLoading,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      drawingDocumentCategoryId:
          drawingDocumentCategoryId ?? this.drawingDocumentCategoryId,
      drawingDocumentList: drawingDocumentList ?? this.drawingDocumentList,
      subDrawingDocumentList:
          subDrawingDocumentList ?? this.subDrawingDocumentList,
      drawingDocumentCategoryModelList:
          drawingDocumentCategoryModelList ??
          this.drawingDocumentCategoryModelList,
      inventoryDrawingDocumentList:
          inventoryDrawingDocumentList ?? this.inventoryDrawingDocumentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      totalNumberOfRecordOfSubDoc:
          totalNumberOfRecordOfSubDoc ?? this.totalNumberOfRecordOfSubDoc,
      currentPage: currentPage ?? this.currentPage,
      currentPageOfSubDoc: currentPageOfSubDoc ?? this.currentPageOfSubDoc,
      searchText: searchText ?? this.searchText,
      buildingNumberText: buildingNumberText ?? this.buildingNumberText,
      wingText: wingText ?? this.wingText,
      floorText: floorText ?? this.floorText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    categoryIndex,
    drawingDocumentCategoryId,
    drawingDocumentList,
    subDrawingDocumentList,
    inventoryDrawingDocumentList,
    drawingDocumentCategoryModelList,
    totalNumberOfRecord,
    totalNumberOfRecordOfSubDoc,
    currentPage,
    currentPageOfSubDoc,
    searchText,
    buildingNumberText,
    wingText,
    floorText,
    currentSortColumn,
    currentSortDirection,
  ];
}
