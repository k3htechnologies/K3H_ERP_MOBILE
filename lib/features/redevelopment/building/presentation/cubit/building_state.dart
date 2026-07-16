part of 'building_cubit.dart';

class BuildingState extends BaseState {
  final List<RedevelopmentBuildingModel> buildingList;
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
  final String filterRoadWidth;
  final String filterCity;
  final String filterVillage;
  const BuildingState({
    super.isLoading,
    super.stateType,
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
    required this.filterRoadWidth,
    required this.filterCity,
    required this.filterVillage,
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
    filterRoadWidth: "",
    filterCity: "",
    filterVillage: "",
  );

  BuildingState copyWith({
    bool? isLoading,
    StateType? stateType,
    List<RedevelopmentBuildingModel>? buildingList,
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
    String? filterCTSNumber,
    String? filterRoadWidth,
    String? filterCity,
    String? filterVillage,
  }) {
    return BuildingState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
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
      filterRoadWidth: filterRoadWidth ?? this.filterRoadWidth,
      filterCity: filterCity ?? this.filterCity,
      filterVillage: filterVillage ?? this.filterVillage,
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
    filterRoadWidth,
    filterCity,
    filterVillage,
    documentSearchText,
  ];
}
