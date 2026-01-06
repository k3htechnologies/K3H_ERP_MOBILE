part of 'building_cubit.dart';

class BuildingState extends BaseState {
  final List<RedevelopmentBuildingModel> buildingList;
  final BuildingDetailsModel? buildingDetails;
  final List<BuildingDocumentModel> buildingDocumentList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int currentTabIndex;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const BuildingState({
    super.isLoading,
    super.stateType,
    required this.buildingList,
    this.buildingDetails,
    required this.buildingDocumentList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentTabIndex,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory BuildingState.initial() => BuildingState(
    buildingList: [],
    buildingDetails: null,
    buildingDocumentList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentTabIndex: 0,
    searchText: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  BuildingState copyWith({
    bool? isLoading,
    StateType? stateType,
    List<RedevelopmentBuildingModel>? buildingList,
    BuildingDetailsModel? buildingDetails,
    List<BuildingDocumentModel>? buildingDocumentList,
    int? totalNumberOfRecord,
    int? currentPage,
    int? currentTabIndex,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return BuildingState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      buildingList: buildingList ?? this.buildingList,
      buildingDetails: buildingDetails ?? this.buildingDetails,
      buildingDocumentList: buildingDocumentList ?? this.buildingDocumentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    buildingDetails,
    buildingDocumentList,
    totalNumberOfRecord,
    currentPage,
    currentTabIndex,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
