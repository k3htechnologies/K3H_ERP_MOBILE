import 'package:k3h_erp_app/utils/functions/common_function.dart';

class InventoryParkingOverallReport {
  int projectId;
  String projectName;
  String buildingNumber;
  String wing;

  double allotedReraArea;
  double bookedReraArea;
  double holdReraArea;
  double availableReraArea;
  double blockReraArea;
  double totalReraArea;

  int allotedUnit;
  int bookedUnit;
  int availableUnit;
  int holdUnit;
  int blockUnit;
  int totalUnit;

  int availableParking;
  int blockedParking;
  int bookedParking;
  int holdParking;
  int memberParking;
  int totalParking;

  InventoryParkingOverallReport({
    required this.projectId,
    required this.projectName,
    required this.buildingNumber,
    required this.wing,
    required this.allotedReraArea,
    required this.bookedReraArea,
    required this.holdReraArea,
    required this.availableReraArea,
    required this.blockReraArea,
    required this.totalReraArea,
    required this.allotedUnit,
    required this.bookedUnit,
    required this.availableUnit,
    required this.holdUnit,
    required this.blockUnit,
    required this.totalUnit,
    required this.availableParking,
    required this.blockedParking,
    required this.bookedParking,
    required this.holdParking,
    required this.memberParking,
    required this.totalParking,
  });

  factory InventoryParkingOverallReport.fromJson(Map<String, dynamic> json) {
    return InventoryParkingOverallReport(
      projectId: parseValue<int>(json, "ProjectId"),
      projectName: parseValue<String>(json, "ProjectName"),
      buildingNumber: parseValue<String>(json, "BuildingNumber"),
      wing: parseValue<String>(json, "Wing"),

      allotedReraArea: parseValue<double>(json, "AllotedReraArea"),
      bookedReraArea: parseValue<double>(json, "BookedReraArea"),
      holdReraArea: parseValue<double>(json, "HoldReraArea"),
      availableReraArea: parseValue<double>(json, "AvailableReraArea"),
      blockReraArea: parseValue<double>(json, "BlockReraArea"),
      totalReraArea: parseValue<double>(json, "TotalReraArea"),

      allotedUnit: parseValue<int>(json, "AllotedUnit"),
      bookedUnit: parseValue<int>(json, "BookedUnit"),
      availableUnit: parseValue<int>(json, "AvailableUnit"),
      holdUnit: parseValue<int>(json, "HoldUnit"),
      blockUnit: parseValue<int>(json, "BlockUnit"),
      totalUnit: parseValue<int>(json, "TotalUnit"),

      availableParking: parseValue<int>(json, "AvailableParking"),
      blockedParking: parseValue<int>(json, "BlockedParking"),
      bookedParking: parseValue<int>(json, "BookedParking"),
      holdParking: parseValue<int>(json, "HoldParking"),
      memberParking: parseValue<int>(json, "MemberParking"),
      totalParking: parseValue<int>(json, "TotalParking"),
    );
  }

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ProjectName": projectName,
    "BuildingNumber": buildingNumber,
    "Wing": wing,

    "AllotedReraArea": allotedReraArea,
    "BookedReraArea": bookedReraArea,
    "HoldReraArea": holdReraArea,
    "AvailableReraArea": availableReraArea,
    "BlockReraArea": blockReraArea,
    "TotalReraArea": totalReraArea,

    "AllotedUnit": allotedUnit,
    "BookedUnit": bookedUnit,
    "AvailableUnit": availableUnit,
    "HoldUnit": holdUnit,
    "BlockUnit": blockUnit,
    "TotalUnit": totalUnit,

    "AvailableParking": availableParking,
    "BlockedParking": blockedParking,
    "BookedParking": bookedParking,
    "HoldParking": holdParking,
    "MemberParking": memberParking,
    "TotalParking": totalParking,
  };
}
