part of 'inventory_cubit.dart';

class InventoryState extends BaseState {
  final List<BuildingModel> buildingList;
  final int currentTabIndex;
  final InventoryDashboardModel? inventoryDashboardModel;
  final List<InventoryDashboardModel> inventoryDashboardModelList;

  // ✅ ADD THIS
  final Map<String, Map<String, int>> wingCounts;

  const InventoryState({
    super.isLoading,
    required this.buildingList,
    required this.currentTabIndex,
    this.wingCounts = const {}, // ✅ default
    this.inventoryDashboardModel,
    required this.inventoryDashboardModelList,
  });

  factory InventoryState.initial() => InventoryState(
    buildingList: [],
    isLoading: true,
    currentTabIndex: 0,
    wingCounts: const {}, // ✅ add
    inventoryDashboardModelList: [],
  );

  InventoryState copyWith({
    bool? isLoading,
    List<BuildingModel>? buildingList,
    int? currentTabIndex,

    InventoryDashboardModel? inventoryDashboardModel,
    List<InventoryDashboardModel>? inventoryDashboardModelList,

    // ✅ ADD
    Map<String, Map<String, int>>? wingCounts,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      inventoryDashboardModel:
          inventoryDashboardModel ?? this.inventoryDashboardModel,
      inventoryDashboardModelList:
          inventoryDashboardModelList ?? this.inventoryDashboardModelList,

      // ✅ ADD
      wingCounts: wingCounts ?? this.wingCounts,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    currentTabIndex,
    inventoryDashboardModel,
    inventoryDashboardModelList,
    wingCounts, // ✅ ADD
  ];
}
