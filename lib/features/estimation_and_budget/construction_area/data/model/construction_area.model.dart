import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ConstructionAreaModel {
  int constructionAreaId;
  String uniqueKey;
  int projectId;
  int inventoryFlatId;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  double reraCarpetAreaSqFt;
  String flatType;
  String flatConfiguration;
  String flatStatus;
  String flatFacing;
  double areaByPlLineSqMt;
  double multiplierForAreaPercentage;
  double totalAreaSqMt;
  double totalAreaSqFt;
  double floorToFloorHeightMt;
  double cumulativeHeightMt;
  String remark;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ConstructionAreaModel({
    required this.constructionAreaId,
    required this.uniqueKey,
    required this.projectId,
    required this.inventoryFlatId,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.reraCarpetAreaSqFt,
    required this.flatType,
    required this.flatConfiguration,
    required this.flatStatus,
    required this.flatFacing,
    required this.areaByPlLineSqMt,
    required this.multiplierForAreaPercentage,
    required this.totalAreaSqMt,
    required this.totalAreaSqFt,
    required this.floorToFloorHeightMt,
    required this.cumulativeHeightMt,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ConstructionAreaModel.fromJson(Map<String, dynamic> json) =>
      ConstructionAreaModel(
        constructionAreaId: parseValue<int>(json, "ConstructionAreaId"),
        uniqueKey: parseValue<String>(json, "UniqueKey"),
        projectId: parseValue<int>(json, "ProjectId"),
        inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
        buildingNumber: parseValue<String>(json, "BuildingNumber"),
        wing: parseValue<String>(json, "Wing"),
        floor: parseValue<String>(json, "Floor"),
        flat: parseValue<String>(json, "Flat"),
        reraCarpetAreaSqFt: parseValue<double>(json, "RERACarpetAreaSqFt"),
        flatType: parseValue<String>(json, "FlatType"),
        flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
        flatStatus: parseValue<String>(json, "FlatStatus"),
        flatFacing: parseValue<String>(json, "FlatFacing"),
        areaByPlLineSqMt: parseValue<double>(json, "AreaByPLLineSqMt"),
        multiplierForAreaPercentage: parseValue<double>(
          json,
          "MultiplierForAreaPercentage",
        ),
        totalAreaSqMt: parseValue<double>(json, "TotalAreaSqMt"),
        totalAreaSqFt: parseValue<double>(json, "TotalAreaSqFt"),
        floorToFloorHeightMt: parseValue<double>(json, "FloorToFloorHeightMt"),
        cumulativeHeightMt: parseValue<double>(json, "CumulativeHeightMt"),
        remark: parseValue<String>(json, "Remark"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "ConstructionAreaId": constructionAreaId,
    "UniqueKey": uniqueKey,
    "ProjectId": projectId,
    "InventoryFlatId": inventoryFlatId,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "FlatType": flatType,
    "FlatConfiguration": flatConfiguration,
    "FlatStatus": flatStatus,
    "FlatFacing": flatFacing,
    "AreaByPLLineSqMt": areaByPlLineSqMt,
    "MultiplierForAreaPercentage": multiplierForAreaPercentage,
    "TotalAreaSqMt": totalAreaSqMt,
    "TotalAreaSqFt": totalAreaSqFt,
    "FloorToFloorHeightMt": floorToFloorHeightMt,
    "CumulativeHeightMt": cumulativeHeightMt,
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
