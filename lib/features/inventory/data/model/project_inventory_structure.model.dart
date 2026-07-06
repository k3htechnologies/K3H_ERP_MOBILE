import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectInventoryStructure {
  final int inventoryBuildingId;
  final String flat;
  final String buildingNumber;
  final String wing;
  final String floor;
  final String flatConfiguration;
  final int inventoryFlatFloorBasementPodiumWingId;

  ProjectInventoryStructure({
    required this.inventoryBuildingId,
    required this.flat,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flatConfiguration,
    required this.inventoryFlatFloorBasementPodiumWingId,
  });

  factory ProjectInventoryStructure.fromJson(Map<String, dynamic> json) =>
      ProjectInventoryStructure(
        inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
        flat: parseValue<String>(json, "Flat"),
        buildingNumber: parseValue<String>(json, "BuildingNumber"),
        wing: parseValue<String>(json, "Wing"),
        floor: parseValue<String>(json, "Floor"),
        flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
        inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
          json,
          "InventoryFlatFloorBasementPodiumWingId",
        ),
      );

  Map<String, dynamic> toJson() => {
    "InventoryBuildingId": inventoryBuildingId,
    "Flat": flat,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "FlatConfiguration": flatConfiguration,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
  };
}
