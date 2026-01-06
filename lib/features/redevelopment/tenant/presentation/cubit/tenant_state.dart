part of 'tenant_cubit.dart';

class TenantState extends BaseState {
  final List<TenantModel> tenantList;
  final List<RedevelopmentBuildingModel> buildingList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int totalNumberOfRecordCharges;
  final int currentPageCharges;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;

  const TenantState({
    super.isLoading,
    required this.tenantList,
    required this.buildingList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.totalNumberOfRecordCharges,
    required this.currentPageCharges,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory TenantState.initial() => TenantState(
    tenantList: [],
    buildingList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    totalNumberOfRecordCharges: 0,
    currentPageCharges: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
  );

  TenantState copyWith({
    bool? isLoading,
    List<TenantModel>? tenantList,
    List<RedevelopmentBuildingModel>? buildingList,
    int? totalNumberOfRecord,
    int? currentPage,
    int? totalNumberOfRecordCharges,
    int? currentPageCharges,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return TenantState(
      isLoading: isLoading ?? this.isLoading,
      tenantList: tenantList ?? this.tenantList,
      buildingList: buildingList ?? this.buildingList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecordCharges:
          totalNumberOfRecordCharges ?? this.totalNumberOfRecordCharges,
      currentPageCharges: currentPageCharges ?? this.currentPageCharges,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    tenantList,
    buildingList,
    totalNumberOfRecord,
    currentPage,
    totalNumberOfRecordCharges,
    currentPageCharges,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
