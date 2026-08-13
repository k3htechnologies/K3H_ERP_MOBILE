part of 'collection_report_cubit.dart';

class CollectionReportState extends BaseState {
  final List<CollectionReportModel> collectionReportList;
  final CollectionReportModel? collectionModel;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final List<CollectionReportProjectWiseModel> collectionProjectReportList;
  const CollectionReportState({
    super.isLoading,
    required this.collectionReportList,
    this.collectionModel,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.collectionProjectReportList,
  });
  factory CollectionReportState.initial() => CollectionReportState(
    isLoading: true,
    collectionReportList: [],
    totalNumberOfRecord: 0,
    currentPage: 0,
    searchText: "",
    collectionProjectReportList: [],
  );

  CollectionReportState copyWith({
    bool? isLoading,
    List<CollectionReportModel>? collectionReportList,
    CollectionReportModel? collectionModel,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    List<CollectionReportProjectWiseModel>? collectionProjectReportList,
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
  ];
}
