import 'package:k3h_erp_app/utils/functions/common_function.dart';

class InventoryProjectBasementPodiumWingBudgetModel {
  int inventoryFlatFloorBasementPodiumWingId;
  String projectBuildingNumberWing;
  double budgetAmount;

  InventoryProjectBasementPodiumWingBudgetModel({
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.projectBuildingNumberWing,
    required this.budgetAmount,
  });

  factory InventoryProjectBasementPodiumWingBudgetModel.fromJson(
    Map<String, dynamic> json,
  ) => InventoryProjectBasementPodiumWingBudgetModel(
    inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
      json,
      "InventoryFlatFloorBasementPodiumWingId",
    ),
    projectBuildingNumberWing: parseValue<String>(
      json,
      "ProjectBuildingNumberWing",
    ),
    budgetAmount: parseValue<double>(json, "BudgetAmount"),
  );

  Map<String, dynamic> toJson() => {
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "ProjectBuildingNumberWing": projectBuildingNumberWing,
    "BudgetAmount": budgetAmount,
  };
}
