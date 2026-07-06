import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ParkingModificationRequestModel {
  int parkingModificationRequestId;
  String uniqueKey;
  int bookingId;
  int projectId;
  String parkingId;
  List<ParkingDatum> parkingData;
  bool isApproval;
  String approvalStatus;
  String versionNumber;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ParkingModificationRequestModel({
    required this.parkingModificationRequestId,
    required this.uniqueKey,
    required this.bookingId,
    required this.projectId,
    required this.parkingId,
    required this.parkingData,
    required this.isApproval,
    required this.approvalStatus,
    required this.versionNumber,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ParkingModificationRequestModel.fromJson(Map<String, dynamic> json) =>
      ParkingModificationRequestModel(
        parkingModificationRequestId: json["ParkingModificationRequestId"],
        uniqueKey: json["UniqueKey"],
        bookingId: json["BookingId"],
        projectId: json["ProjectId"],
        parkingId: json["ParkingId"],
        parkingData: List<ParkingDatum>.from(
          json["parkingData"].map((x) => ParkingDatum.fromJson(x)),
        ),
        isApproval: json["IsApproval"],
        approvalStatus: json["ApprovalStatus"],
        versionNumber: json["VersionNumber"],
        createdById: json["CreatedById"],
        createdBy: json["CreatedBy"],
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: json["ModifiedById"],
        modifiedBy: json["ModifiedBy"],
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ParkingModificationRequestId": parkingModificationRequestId,
    "UniqueKey": uniqueKey,
    "BookingId": bookingId,
    "ProjectId": projectId,
    "ParkingId": parkingId,
    "parkingData": List<dynamic>.from(parkingData.map((x) => x.toJson())),
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "VersionNumber": versionNumber,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class ParkingDatum {
  int parkingId;
  String uniquekey;
  int projectId;
  String parkingNumber;
  String parkingCategory;
  String parkingType;
  String parkingSubType;
  String parkingDimensions;
  bool isEvChargingAvailable;
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
  dynamic parkingBookingCreatedDate;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ParkingDatum({
    required this.parkingId,
    required this.uniquekey,
    required this.projectId,
    required this.parkingNumber,
    required this.parkingCategory,
    required this.parkingType,
    required this.parkingSubType,
    required this.parkingDimensions,
    required this.isEvChargingAvailable,
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

  factory ParkingDatum.fromJson(Map<String, dynamic> json) => ParkingDatum(
    parkingId: parseValue<int>(json, "ParkingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    parkingNumber: parseValue<String>(json, "ParkingNumber"),
    parkingCategory: parseValue<String>(json, "ParkingCategory"),
    parkingType: parseValue<String>(json, "ParkingType"),
    parkingSubType: parseValue<String>(json, "ParkingSubType"),
    parkingDimensions: parseValue<String>(json, "ParkingDimensions"),
    isEvChargingAvailable: parseValue<bool>(json, "IsEVChargingAvailable"),
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
    parkingBookingCreatedDate: parseValue<int>(
      json,
      "ParkingBookingCreatedDate",
    ),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: DateTime.parse(json["CreatedDate"]),
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
    "IsEVChargingAvailable": isEvChargingAvailable,
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
    "ParkingBookingCreatedDate": parkingBookingCreatedDate,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
