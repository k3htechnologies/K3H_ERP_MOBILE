part of 'collection_report_cubit.dart';

class CollectionReportState extends BaseState {
  final List<CollectionReportModel> collectionReportList;
  final CollectionReportModel? collectionModel;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final List<CollectionReportProjectWiseModel> collectionProjectReportList;
  final Map<int, List<CollectionReportProjectWiseModel>> projectWiseReportMap;
  final Set<int> loadingProjectIds;
  const CollectionReportState({
    super.isLoading,
    required this.collectionReportList,
    this.collectionModel,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.collectionProjectReportList,
    required this.projectWiseReportMap,
    required this.loadingProjectIds,
  });
  factory CollectionReportState.initial() => CollectionReportState(
    isLoading: true,
    collectionReportList: [],
    totalNumberOfRecord: 0,
    currentPage: 0,
    searchText: "",
    collectionProjectReportList: [],
    projectWiseReportMap: {},
    loadingProjectIds: {0},
  );

  CollectionReportState copyWith({
    bool? isLoading,
    List<CollectionReportModel>? collectionReportList,
    CollectionReportModel? collectionModel,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    List<CollectionReportProjectWiseModel>? collectionProjectReportList,
    Map<int, List<CollectionReportProjectWiseModel>>? projectWiseReportMap,
    Set<int>? loadingProjectIds,
  }) {
    return CollectionReportState(
      isLoading: isLoading ?? this.isLoading,
      collectionReportList: collectionReportList ?? this.collectionReportList,
      collectionModel: collectionModel ?? this.collectionModel,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      collectionProjectReportList:
          collectionProjectReportList ?? this.collectionProjectReportList,
      projectWiseReportMap: projectWiseReportMap ?? this.projectWiseReportMap,
      loadingProjectIds: loadingProjectIds ?? this.loadingProjectIds,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    collectionReportList,
    collectionModel,
    totalNumberOfRecord,
    currentPage,
    searchText,
    collectionProjectReportList,
    projectWiseReportMap,
    loadingProjectIds,
  ];
}
