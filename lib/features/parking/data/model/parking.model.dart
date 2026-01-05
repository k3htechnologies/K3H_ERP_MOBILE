import 'package:k3h_erp_app/utils/common_function.dart';

class ParkingModel {
  int parkingId;
  String uniquekey;
  int projectId;
  String parkingNumber;
  String parkingCategory;
  String parkingType;
  String parkingSubType;
  String parkingDimensions;
  bool isEVChargingAvailable;
  String parkingStatus;
  int inventoryBuildingId;
  String buildingNumber;
  int inventoryFlatFloorBasementPodiumWingId;
  String wing;
  int inventoryFloorId;
  String floor;
  String ownerName;
  int bookingId;
  bool isApproval;
  String approvalStatus;
  int parkingBookingCreatedById;
  String parkingBookingCreatedBy;
  DateTime? parkingBookingCreatedDate;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ParkingModel({
    required this.parkingId,
    required this.uniquekey,
    required this.projectId,
    required this.parkingNumber,
    required this.parkingCategory,
    required this.parkingType,
    required this.parkingSubType,
    required this.parkingDimensions,
    required this.isEVChargingAvailable,
    required this.parkingStatus,
    required this.inventoryBuildingId,
    required this.buildingNumber,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.wing,
    required this.inventoryFloorId,
    required this.floor,
    required this.ownerName,
    required this.bookingId,
    required this.isApproval,
    required this.approvalStatus,
    required this.parkingBookingCreatedById,
    required this.parkingBookingCreatedBy,
    required this.parkingBookingCreatedDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) => ParkingModel(
    parkingId: parseValue<int>(json, "ParkingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    parkingNumber: parseValue<String>(json, "ParkingNumber"),
    parkingCategory: parseValue<String>(json, "ParkingCategory"),
    parkingType: parseValue<String>(json, "ParkingType"),
    parkingSubType: parseValue<String>(json, "ParkingSubType"),
    parkingDimensions: parseValue<String>(json, "ParkingDimensions"),
    isEVChargingAvailable: parseValue<bool>(json, "IsEVChargingAvailable"),
    parkingStatus: parseValue<String>(json, "ParkingStatus"),
    inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
      json,
      "InventoryFlatFloorBasementPodiumWingId",
    ),
    wing: parseValue<String>(json, "Wing"),
    inventoryFloorId: parseValue<int>(json, "InventoryFloorId"),
    floor: parseValue<String>(json, "Floor"),
    ownerName: parseValue<String>(json, "OwnerName"),
    bookingId: parseValue<int>(json, "BookingId"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    parkingBookingCreatedById: parseValue<int>(
      json,
      "ParkingBookingCreatedById",
    ),
    parkingBookingCreatedBy: parseValue<String>(
      json,
      "ParkingBookingCreatedBy",
    ),
    parkingBookingCreatedDate:
    json["ParkingBookingCreatedDate"] == null
        ? null
        : parseValue<DateTime>(json, "ParkingBookingCreatedDate"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
    json["ModifiedDate"] == null
        ? null
        : parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "ParkingId": parkingId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ParkingNumber": parkingNumber,
    "ParkingCategory": parkingCategory,
    "ParkingType": parkingType,
    "ParkingSubType": parkingSubType,
    "ParkingDimensions": parkingDimensions,
    "IsEVChargingAvailable": isEVChargingAvailable,
    "ParkingStatus": parkingStatus,
    "InventoryBuildingId": inventoryBuildingId,
    "BuildingNumber": buildingNumber,
    "InventoryFlatFloorBasementPodiumWingId":
    inventoryFlatFloorBasementPodiumWingId,
    "Wing": wing,
    "InventoryFloorId": inventoryFloorId,
    "Floor": floor,
    "OwnerName": ownerName,
    "BookingId": bookingId,
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "ParkingBookingCreatedById": parkingBookingCreatedById,
    "ParkingBookingCreatedBy": parkingBookingCreatedBy,
    "ParkingBookingCreatedDate": parkingBookingCreatedDate?.toIso8601String(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}