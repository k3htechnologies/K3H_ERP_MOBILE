part of 'inventory_cubit.dart';

class InventoryState extends BaseState {
  final List<BuildingModel> buildingList;
  final int currentTabIndex;
  final InventoryDashboardModel? inventoryDashboardModel;
  final List<InventoryDashboardModel> inventoryDashboardModelList;
  final Map<String, Map<String, int>> wingCounts;
  final String searchText;
  final List<BuildingModel> originalBuildingList;
  final int wingCurrentPage;
  final String? wingCurrentPageKey;
  final String? selectedFlatStatus;
  final List<FlatModel> flatList;
  final int currentUnitPage;
  final int unitTotalRecords;

  const InventoryState({
    super.isLoading,
    required this.buildingList,
    required this.currentTabIndex,
    this.wingCounts = const {},
    this.inventoryDashboardModel,
    required this.inventoryDashboardModelList,
    required this.searchText,
    required this.originalBuildingList,
    this.wingCurrentPageKey,
    this.wingCurrentPage = 0,
    this.selectedFlatStatus = 'total',
    this.flatList = const [],
    this.currentUnitPage = 0,
    this.unitTotalRecords = 0,
  });

  factory InventoryState.initial() => InventoryState(
    buildingList: [],
    isLoading: true,
    currentTabIndex: 0,
    wingCounts: const {},
    inventoryDashboardModelList: [],
    searchText: "",
    originalBuildingList: [],
    wingCurrentPageKey: null,
    flatList: [],
    wingCurrentPage: 0,
    currentUnitPage: 0,
    unitTotalRecords: 0,
    selectedFlatStatus: "total",
  );

  InventoryState copyWith({
    bool? isLoading,
    List<BuildingModel>? buildingList,
    int? currentTabIndex,
    String? searchText,
    List<BuildingModel>? originalBuildingList,

    InventoryDashboardModel? inventoryDashboardModel,
    List<InventoryDashboardModel>? inventoryDashboardModelList,

    Map<String, Map<String, int>>? wingCounts,
    String? wingCurrentPageKey,
    int? wingCurrentPage,
    String? selectedFlatStatus,
    List<FlatModel>? flatList,
    int? currentUnitPage,
    int? unitTotalRecords,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      inventoryDashboardModel:
          inventoryDashboardModel ?? this.inventoryDashboardModel,
      inventoryDashboardModelList:
          inventoryDashboardModelList ?? this.inventoryDashboardModelList,
      wingCounts: wingCounts ?? this.wingCounts,
      searchText: searchText ?? this.searchText,
      originalBuildingList: originalBuildingList ?? this.originalBuildingList,
      wingCurrentPageKey: wingCurrentPageKey ?? this.wingCurrentPageKey,
      wingCurrentPage: wingCurrentPage ?? this.wingCurrentPage,
      selectedFlatStatus: selectedFlatStatus ?? this.selectedFlatStatus,
      flatList: flatList ?? this.flatList,
      currentUnitPage: currentUnitPage ?? this.currentUnitPage,
      unitTotalRecords: unitTotalRecords ?? this.unitTotalRecords,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    currentTabIndex,
    inventoryDashboardModel,
    inventoryDashboardModelList,
    wingCounts,
    originalBuildingList,
    wingCurrentPageKey,
    wingCurrentPage,
    wingCurrentPageKey,
    selectedFlatStatus,
    flatList,
    currentUnitPage,
    unitTotalRecords,
  ];
}
