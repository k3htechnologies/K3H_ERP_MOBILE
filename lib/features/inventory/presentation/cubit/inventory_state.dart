part of 'inventory_cubit.dart';

class InventoryState extends BaseState {
  final List<BuildingModel> buildingList;
  final int currentTabIndex;
  const InventoryState({
    super.isLoading,
    required this.buildingList,
    required this.currentTabIndex,
  });

  factory InventoryState.initial() =>
      InventoryState(buildingList: [], isLoading: true, currentTabIndex: 0);

  InventoryState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    List<BuildingModel>? buildingList,
    int? currentTabIndex,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [isLoading, buildingList, currentTabIndex];
}
