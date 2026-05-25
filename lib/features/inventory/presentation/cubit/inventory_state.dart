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
  final String? selectedStatusFilter;

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
    this.selectedStatusFilter = 'total',
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
    wingCurrentPage: 0,
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
    String? selectedStatusFilter,
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
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
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
    selectedStatusFilter,
  ];
}
