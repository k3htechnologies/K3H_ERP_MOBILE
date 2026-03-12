part of 'inventory_cubit.dart';

class InventoryState extends BaseState {
  final List<BuildingModel> buildingList;
  final int currentTabIndex;

  // ✅ ADD THIS
  final Map<String, Map<String, int>> wingCounts;

  const InventoryState({
    super.isLoading,
    required this.buildingList,
    required this.currentTabIndex,
    this.wingCounts = const {},   // ✅ default
  });

  factory InventoryState.initial() => InventoryState(
    buildingList: [],
    isLoading: true,
    currentTabIndex: 0,
    wingCounts: const {},     // ✅ add
  );

  InventoryState copyWith({
    bool? isLoading,
    List<BuildingModel>? buildingList,
    int? currentTabIndex,

    // ✅ ADD
    Map<String, Map<String, int>>? wingCounts,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,

      // ✅ ADD
      wingCounts: wingCounts ?? this.wingCounts,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    currentTabIndex,
    wingCounts, // ✅ ADD
  ];
}
