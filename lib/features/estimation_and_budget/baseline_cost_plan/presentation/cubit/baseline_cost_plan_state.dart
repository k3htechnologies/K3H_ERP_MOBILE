part of 'baseline_cost_plan_cubit.dart';

class BaselineCostPlanState extends BaseState {
  final int categoryIndex;
  final int baselineCostPlanDocumentCategoryId;
  final List<BaselineCostPlanDocumentModel> baselineCostPlanDocumentList;
  final List<BaselineCostPlanDocumentModel> subBaselineCostPlanDocumentList;
  final List<BaselineCostPlanDocumentCategory>
  baselineCostPlanDocumentCategoryList;
  final int totalNumberOfRecord;
  final int totalNumberOfRecordOfSubDoc;
  final int currentPage;
  final int currentPageOfSubDoc;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  const BaselineCostPlanState({
    super.isLoading,
    required this.categoryIndex,
    required this.baselineCostPlanDocumentCategoryId,
    required this.baselineCostPlanDocumentList,
    required this.subBaselineCostPlanDocumentList,
    required this.baselineCostPlanDocumentCategoryList,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordOfSubDoc,
    required this.currentPage,
    required this.currentPageOfSubDoc,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory BaselineCostPlanState.inital() => BaselineCostPlanState(
    categoryIndex: 0,
    baselineCostPlanDocumentCategoryId: 0,
    baselineCostPlanDocumentList: [],
    subBaselineCostPlanDocumentList: [],
    baselineCostPlanDocumentCategoryList: [],
    totalNumberOfRecord: 0,
    totalNumberOfRecordOfSubDoc: 0,
    currentPage: 1,
    currentPageOfSubDoc: 1,
    searchText: '',
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  BaselineCostPlanState copywith({
    bool? isLoading,
    int? categoryIndex,
    int? baselineCostPlanDocumentCategoryId,
    List<BaselineCostPlanDocumentModel>? baselineCostPlanDocumentList,
    List<BaselineCostPlanDocumentModel>? subBaselineCostPlanDocumentList,
    List<BaselineCostPlanDocumentCategory>?
    baselineCostPlanDocumentCategoryList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordOfSubDoc,
    int? currentPage,
    int? currentPageOfSubDoc,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return BaselineCostPlanState(
      isLoading: isLoading ?? this.isLoading,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      baselineCostPlanDocumentCategoryId:
          baselineCostPlanDocumentCategoryId ??
          this.baselineCostPlanDocumentCategoryId,
      baselineCostPlanDocumentList:
          baselineCostPlanDocumentList ?? this.baselineCostPlanDocumentList,
      subBaselineCostPlanDocumentList:
          subBaselineCostPlanDocumentList ??
          this.subBaselineCostPlanDocumentList,
      baselineCostPlanDocumentCategoryList:
          baselineCostPlanDocumentCategoryList ??
          this.baselineCostPlanDocumentCategoryList,
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
    baselineCostPlanDocumentCategoryId,
    baselineCostPlanDocumentList,
    subBaselineCostPlanDocumentList,
    baselineCostPlanDocumentCategoryList,
    totalNumberOfRecord,
    totalNumberOfRecordOfSubDoc,
    currentPage,
    currentPageOfSubDoc,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
