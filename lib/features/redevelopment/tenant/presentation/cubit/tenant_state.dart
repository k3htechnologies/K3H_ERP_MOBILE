part of 'tenant_cubit.dart';

class TenantState extends BaseState {
  final List<TenantModel> tenantList;
  final List<TenantDocumentModel> tenantDocumentList;
  final List<RedevelopmentBuildingModel> buildingList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int currentTabIndex;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const TenantState({
    super.isLoading,
    required this.tenantList,
    required this.tenantDocumentList,
    required this.buildingList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentTabIndex,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory TenantState.initial() => TenantState(
    tenantList: [],
    tenantDocumentList: [],
    buildingList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentTabIndex: 0,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
  );

  TenantState copyWith({
    bool? isLoading,
    List<TenantModel>? tenantList,
    List<TenantDocumentModel>? tenantDocumentList,
    List<RedevelopmentBuildingModel>? buildingList,
    int? totalNumberOfRecord,
    int? currentPage,
    int? currentTabIndex,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return TenantState(
      isLoading: isLoading ?? this.isLoading,
      tenantList: tenantList ?? this.tenantList,
      tenantDocumentList: tenantDocumentList ?? this.tenantDocumentList,
      buildingList: buildingList ?? this.buildingList,
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
    tenantList,
    tenantDocumentList,
    buildingList,
    totalNumberOfRecord,
    currentPage,
    currentTabIndex,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
