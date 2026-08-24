part of 'building_cubit.dart';

class BuildingState extends BaseState {
  final List<BusinessDevelopmentBuildingModel> buildingList;
  final BuildingDetailsModel? buildingDetails;
  final List<BuildingDocumentModel> buildingDocumentList;
  final int totalNumberOfRecord;
  final int totalNumberOfRecordDocument;
  final int currentPage;
  final int currentPageDocument;
  final int currentTabIndex;
  final String searchText;
  final String documentSearchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterCTSNumber;
  final String filterCategory;
  final String filterRoadWidth;
  final String filterCity;
  final String filterVillage;
  final String filterWard;
  const BuildingState({
    super.isLoading,
    required this.buildingList,
    this.buildingDetails,
    required this.buildingDocumentList,
    required this.totalNumberOfRecord,
    required this.totalNumberOfRecordDocument,
    required this.currentPage,
    required this.currentPageDocument,
    required this.currentTabIndex,
    required this.searchText,
    required this.documentSearchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterCTSNumber,
    required this.filterCategory,
    required this.filterRoadWidth,
    required this.filterCity,
    required this.filterVillage,
    required this.filterWard,
  });
  factory BuildingState.initial() => BuildingState(
    buildingList: [],
    buildingDetails: null,
    buildingDocumentList: [],
    totalNumberOfRecord: 0,
    totalNumberOfRecordDocument: 0,
    currentPage: 1,
    currentPageDocument: 1,
    currentTabIndex: 0,
    searchText: "",
    documentSearchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterCTSNumber: "",
    filterCategory: "",
    filterRoadWidth: "",
    filterCity: "",
    filterVillage: "",
    filterWard: "",
  );
  BuildingState copyWith({
    bool? isLoading,
    List<BusinessDevelopmentBuildingModel>? buildingList,
    BuildingDetailsModel? buildingDetails,
    List<BuildingDocumentModel>? buildingDocumentList,
    int? totalNumberOfRecord,
    int? totalNumberOfRecordDocument,
    int? currentPage,
    int? currentPageDocument,
    int? currentTabIndex,
    String? searchText,
    String? documentSearchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterCategory,
    String? filterCTSNumber,
    String? filterRoadWidth,
    String? filterCity,
    String? filterVillage,
    String? filterWard,
  }) {
    return BuildingState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      buildingDetails: buildingDetails ?? this.buildingDetails,
      buildingDocumentList: buildingDocumentList ?? this.buildingDocumentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      totalNumberOfRecordDocument:
          totalNumberOfRecordDocument ?? this.totalNumberOfRecordDocument,
      currentPage: currentPage ?? this.currentPage,
      currentPageDocument: currentPageDocument ?? this.currentPageDocument,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchText: searchText ?? this.searchText,
      documentSearchText: documentSearchText ?? this.documentSearchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterCTSNumber: filterCTSNumber ?? this.filterCTSNumber,
      filterCategory: filterCategory ?? this.filterCategory,
      filterRoadWidth: filterRoadWidth ?? this.filterRoadWidth,
      filterCity: filterCity ?? this.filterCity,
      filterVillage: filterVillage ?? this.filterVillage,
      filterWard: filterWard ?? this.filterWard,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    buildingDetails,
    buildingDocumentList,
    totalNumberOfRecord,
    totalNumberOfRecordDocument,
    currentPage,
    currentPageDocument,
    currentTabIndex,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterCTSNumber,
    filterCategory,
    filterRoadWidth,
    filterCity,
    filterVillage,
    filterWard,
    documentSearchText,
  ];
}
