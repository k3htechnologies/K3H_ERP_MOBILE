part of 'tenant_cubit.dart';

class TenantState extends BaseState {
  final List<TenantModel> tenantList;
  final List<TenantDocumentModel> tenantDocumentList;
  final List<RedevelopmentBuildingModel> buildingList;
  final int totalNumberOfRecord;
  final int buildingTotalCount;
  final int currentPage;
  final int currentTabIndex;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterFlatType;
  final String filterFlatConfiguration;


  const TenantState({
    super.isLoading,
    required this.tenantList,
    required this.tenantDocumentList,
    required this.buildingList,
    required this.totalNumberOfRecord,
    required this.buildingTotalCount,
    required this.currentPage,
    required this.currentTabIndex,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterFlatType,
    required this.filterFlatConfiguration,
  });

  factory TenantState.initial() => TenantState(
    isLoading: true,
    tenantList: [],
    tenantDocumentList: [],
    buildingList: [],
    totalNumberOfRecord: 0,
    buildingTotalCount: 0,
    currentPage: 1,
    currentTabIndex: 0,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterFlatType: "",
    filterFlatConfiguration: "",
  );

  TenantState copyWith({
    bool? isLoading,
    List<TenantModel>? tenantList,
    List<TenantDocumentModel>? tenantDocumentList,
    List<RedevelopmentBuildingModel>? buildingList,
    int? totalNumberOfRecord,
    int? buildingTotalCount,
    int? currentPage,
    int? currentTabIndex,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterFlatType,
    String? filterFlatConfiguration,
  }) {
    return TenantState(
      isLoading: isLoading ?? this.isLoading,
      tenantList: tenantList ?? this.tenantList,
      tenantDocumentList: tenantDocumentList ?? this.tenantDocumentList,
      buildingList: buildingList ?? this.buildingList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      buildingTotalCount: buildingTotalCount ?? this.buildingTotalCount,
      currentPage: currentPage ?? this.currentPage,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterFlatType: filterFlatType ?? this.filterFlatType,
      filterFlatConfiguration: filterFlatConfiguration ?? this.filterFlatConfiguration
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    tenantList,
    tenantDocumentList,
    buildingList,
    totalNumberOfRecord,
    buildingTotalCount,
    currentPage,
    currentTabIndex,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterFlatType,
    filterFlatConfiguration,
  ];
}
