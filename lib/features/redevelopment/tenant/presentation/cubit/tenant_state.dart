part of 'tenant_cubit.dart';

class TenantState extends BaseState {
  final List<TenantModel> tenantList;
  final List<TenantDocumentModel> tenantDocumentList;
  final int totalNumberOfRecord;
  final int buildingTotalCount;
  final int currentPage;
  final int currentTabIndex;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByTenantCode;
  final String filterByFlatType;
  final String filterByFlatConfiguration;
  final String filterByApplicantName;
  final String filterByFlatCarpetAreaSqFt;
  final String filterByBuildingNumber;
  final String filterByWing;
  final String filterByFlat;
  final String filterByParkingNumber;
  final String searchDocumentName;

  const TenantState({
    super.isLoading,
    required this.tenantList,
    required this.tenantDocumentList,
    required this.totalNumberOfRecord,
    required this.buildingTotalCount,
    required this.currentPage,
    required this.currentTabIndex,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByTenantCode,
    required this.filterByFlatType,
    required this.filterByFlatConfiguration,
    required this.filterByApplicantName,
    required this.filterByFlatCarpetAreaSqFt,
    required this.filterByBuildingNumber,
    required this.filterByWing,
    required this.filterByFlat,
    required this.filterByParkingNumber,
    required this.searchDocumentName,
  });

  factory TenantState.initial() => TenantState(
    isLoading: true,
    tenantList: [],
    tenantDocumentList: [],
    totalNumberOfRecord: 0,
    buildingTotalCount: 0,
    currentPage: 1,
    currentTabIndex: 0,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterByTenantCode: "",
    filterByFlatType: "",
    filterByFlatConfiguration: "",
    filterByApplicantName: "",
    filterByFlatCarpetAreaSqFt: "",
    filterByBuildingNumber: "",
    filterByWing: "",
    filterByFlat: "",
    filterByParkingNumber: "",
    searchDocumentName: "",
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
    String? filterByFlatType,
    String? filterByFlatConfiguration,
    String? filterByTenantCode,
    String? filterByApplicantName,
    String? filterByFlatCarpetAreaSqFt,
    String? filterByBuildingNumber,
    String? filterByWing,
    String? filterByFlat,
    String? filterByParkingNumber,
    String? searchDocumentName,
  }) {
    return TenantState(
      isLoading: isLoading ?? this.isLoading,
      tenantList: tenantList ?? this.tenantList,
      tenantDocumentList: tenantDocumentList ?? this.tenantDocumentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      buildingTotalCount: buildingTotalCount ?? this.buildingTotalCount,
      currentPage: currentPage ?? this.currentPage,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByTenantCode: filterByTenantCode ?? this.filterByTenantCode,
      filterByFlatType: filterByFlatType ?? this.filterByFlatType,
      filterByFlatConfiguration:
          filterByFlatConfiguration ?? this.filterByFlatConfiguration,
      filterByApplicantName:
          filterByApplicantName ?? this.filterByApplicantName,
      filterByFlatCarpetAreaSqFt:
          filterByFlatCarpetAreaSqFt ?? this.filterByFlatCarpetAreaSqFt,
      filterByBuildingNumber:
          filterByBuildingNumber ?? this.filterByBuildingNumber,
      filterByWing: filterByWing ?? this.filterByWing,
      filterByFlat: filterByFlat ?? this.filterByFlat,
      filterByParkingNumber:
          filterByParkingNumber ?? this.filterByParkingNumber,
      searchDocumentName: searchDocumentName ?? this.searchDocumentName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    tenantList,
    tenantDocumentList,
    totalNumberOfRecord,
    buildingTotalCount,
    currentPage,
    currentTabIndex,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterByTenantCode,
    filterByFlatType,
    filterByFlatConfiguration,
    filterByApplicantName,
    filterByFlatCarpetAreaSqFt,
    filterByBuildingNumber,
    filterByWing,
    filterByFlat,
    filterByParkingNumber,
    searchDocumentName,
  ];
}
