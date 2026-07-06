import 'package:k3h_erp_app/utils/functions/common_function.dart';

class InventoryParkingDetailsModel {
  int projectId;
  String projectName;
  int totalBuilding;
  double totalReraArea;
  int totalUnit;
  int availableUnit;
  int bookedUnit;
  int blockedUnit;
  int holdUnit;
  int allotedUnit;
  int totalParking;

  InventoryParkingDetailsModel({
    required this.projectId,
    required this.projectName,
    required this.totalBuilding,
    required this.totalReraArea,
    required this.totalUnit,
    required this.availableUnit,
    required this.bookedUnit,
    required this.blockedUnit,
    required this.holdUnit,
    required this.allotedUnit,
    required this.totalParking,
  });

  factory InventoryParkingDetailsModel.fromJson(Map<String, dynamic> json) {
    return InventoryParkingDetailsModel(
      projectId: parseValue<int>(json, "ProjectId"),
      projectName: parseValue<String>(json, "ProjectName"),
      totalBuilding: parseValue<int>(json, "TotalBuilding"),
      totalReraArea: parseValue<double>(json, "TotalReraArea"),
      totalUnit: parseValue<int>(json, "TotalUnit"),
      availableUnit: parseValue<int>(json, "AvailableUnit"),
      bookedUnit: parseValue<int>(json, "BookedUnit"),
      blockedUnit: parseValue<int>(json, "BlockedUnit"),
      holdUnit: parseValue<int>(json, "HoldUnit"),
      allotedUnit: parseValue<int>(json, "AllotedUnit"),
      totalParking: parseValue<int>(json, "TotalParking"),
    );
  }

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ProjectName": projectName,
    "TotalBuilding": totalBuilding,
    "TotalReraArea": totalReraArea,
    "TotalUnit": totalUnit,
    "AvailableUnit": availableUnit,
    "BookedUnit": bookedUnit,
    "BlockedUnit": blockedUnit,
    "HoldUnit": holdUnit,
    "AllotedUnit": allotedUnit,
    "TotalParking": totalParking,
  };
}
