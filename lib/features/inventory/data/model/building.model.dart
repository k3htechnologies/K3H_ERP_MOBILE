import 'package:collection/collection.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class BuildingModel {
  int inventoryBuildingId;
  String uniquekey;
  int projectId;
  String buildingNumber;
  int noOfBasement;
  int noOfPodium;
  int noOfWings;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  List<WingModel> wingList;

  BuildingModel({
    required this.inventoryBuildingId,
    required this.uniquekey,
    required this.projectId,
    required this.buildingNumber,
    required this.noOfBasement,
    required this.noOfPodium,
    required this.noOfWings,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.wingList,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) => BuildingModel(
    inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    noOfBasement: parseValue<int>(json, "NoOfBasement"),
    noOfPodium: parseValue<int>(json, "NoOfPodium"),
    noOfWings: parseValue<int>(json, "NoOfWings"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
    wingList:
        json["InventoryFlatFloorBasementPodiumWingData"] == null
            ? []
            : List<WingModel>.from(
              json["InventoryFlatFloorBasementPodiumWingData"].map(
                (x) => WingModel.fromJson(x),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "InventoryBuildingId": inventoryBuildingId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "BuildingNumber": buildingNumber,
    "NoOfBasement": noOfBasement,
    "NoOfPodium": noOfPodium,
    "NoOfWings": noOfWings,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "InventoryFlatFloorBasementPodiumWingData": List<dynamic>.from(
      wingList.map((x) => x.toJson()),
    ),
  };
  BuildingModel copyWith({
    int? inventoryBuildingId,
    String? uniquekey,
    int? projectId,
    String? buildingNumber,
    int? noOfBasement,
    int? noOfPodium,
    int? noOfWings,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
    List<WingModel>? wingList,
  }) {
    return BuildingModel(
      inventoryBuildingId: inventoryBuildingId ?? this.inventoryBuildingId,
      uniquekey: uniquekey ?? this.uniquekey,
      projectId: projectId ?? this.projectId,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      noOfBasement: noOfBasement ?? this.noOfBasement,
      noOfPodium: noOfPodium ?? this.noOfPodium,
      noOfWings: noOfWings ?? this.noOfWings,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      wingList: wingList ?? this.wingList,
    );
  }
}

class WingModel {
  int inventoryFlatFloorBasementPodiumWingId;
  String uniquekey;
  int inventoryBuildingId;
  int maxNoOfFlatPerFloor;
  int noOfFloorExcludingPodium;
  String wing;
  bool isApproval;
  String approvalStatus;
  List<FloorModel> floorList;
  // FOLLOWING VARIABLES ARE CREATED AND CALCULATED ON THE FRONTEND
  int availableFlat;
  int bookedFlat;
  int blockedFlat;
  int holdFlat;
  int allotedFlat;

  WingModel({
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.uniquekey,
    required this.inventoryBuildingId,
    required this.maxNoOfFlatPerFloor,
    required this.noOfFloorExcludingPodium,
    required this.wing,
    required this.isApproval,
    required this.approvalStatus,
    required this.floorList,
    this.availableFlat = 0,
    this.bookedFlat = 0,
    this.blockedFlat = 0,
    this.holdFlat = 0,
    this.allotedFlat = 0,
  });

  factory WingModel.fromJson(Map<String, dynamic> json) {
    List<FloorModel> floorList =
        json["InventoryFloorData"] == null
            ? []
            : List<FloorModel>.from(
              json["InventoryFloorData"].map((x) => FloorModel.fromJson(x)),
            );
    int availableFlat = floorList.map((e) => e.availableFlat).sum;
    int bookedFlat = floorList.map((e) => e.bookedFlat).sum;
    int blockedFlat = floorList.map((e) => e.blockedFlat).sum;
    int holdFlat = floorList.map((e) => e.holdFlat).sum;
    int allotedFlat = floorList.map((e) => e.allotedFlat).sum;

    return WingModel(
      inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
        json,
        "InventoryFlatFloorBasementPodiumWingId",
      ),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
      maxNoOfFlatPerFloor: parseValue<int>(json, "MaxNoOfFlatPerFloor"),
      noOfFloorExcludingPodium: parseValue<int>(
        json,
        "NoOfFloorExcludingPodium",
      ),
      wing: parseValue<String>(json, "Wing"),
      isApproval: parseValue<bool>(json, "IsApproval"),
      approvalStatus: parseValue<String>(json, "ApprovalStatus"),
      floorList: floorList,
      availableFlat: availableFlat,
      bookedFlat: bookedFlat,
      blockedFlat: blockedFlat,
      holdFlat: holdFlat,
      allotedFlat: allotedFlat,
    );
  }

  Map<String, dynamic> toJson() => {
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "Uniquekey": uniquekey,
    "InventoryBuildingId": inventoryBuildingId,
    "MaxNoOfFlatPerFloor": maxNoOfFlatPerFloor,
    "NoOfFloorExcludingPodium": noOfFloorExcludingPodium,
    "Wing": wing,
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "InventoryFloorData": List<dynamic>.from(floorList.map((x) => x.toJson())),
  };
  WingModel copyWith({
    int? inventoryFlatFloorBasementPodiumWingId,
    String? uniquekey,
    int? inventoryBuildingId,
    int? maxNoOfFlatPerFloor,
    int? noOfFloorExcludingPodium,
    String? wing,
    bool? isApproval,
    String? approvalStatus,
    List<FloorModel>? floorList,
    int? availableFlat,
    int? bookedFlat,
    int? blockedFlat,
    int? holdFlat,
    int? allotedFlat,
  }) {
    return WingModel(
      inventoryFlatFloorBasementPodiumWingId:
          inventoryFlatFloorBasementPodiumWingId ??
          this.inventoryFlatFloorBasementPodiumWingId,
      uniquekey: uniquekey ?? this.uniquekey,
      inventoryBuildingId: inventoryBuildingId ?? this.inventoryBuildingId,
      maxNoOfFlatPerFloor: maxNoOfFlatPerFloor ?? this.maxNoOfFlatPerFloor,
      noOfFloorExcludingPodium:
          noOfFloorExcludingPodium ?? this.noOfFloorExcludingPodium,
      wing: wing ?? this.wing,
      isApproval: isApproval ?? this.isApproval,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      floorList: floorList ?? this.floorList,
      availableFlat: availableFlat ?? this.availableFlat,
      bookedFlat: bookedFlat ?? this.bookedFlat,
      blockedFlat: blockedFlat ?? this.blockedFlat,
      holdFlat: holdFlat ?? this.holdFlat,
      allotedFlat: allotedFlat ?? this.allotedFlat,
    );
  }
}

class FloorModel {
  int inventoryFloorId;
  String uniquekey;
  int inventoryBuildingId;
  int inventoryFlatFloorBasementPodiumWingId;
  String floor;
  double slabHeight;
  int parkingCount;
  List<FlatModel> flatList;
  // FOLLOWING VARIABLES ARE CREATED AND CALCULATED ON THE FRONTEND
  int totalFlat;
  int availableFlat;
  int bookedFlat;
  int blockedFlat;
  int holdFlat;
  int allotedFlat;

  FloorModel({
    required this.inventoryFloorId,
    required this.uniquekey,
    required this.inventoryBuildingId,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.floor,
    required this.slabHeight,
    required this.parkingCount,
    required this.flatList,
    this.totalFlat = 0,
    this.availableFlat = 0,
    this.bookedFlat = 0,
    this.blockedFlat = 0,
    this.holdFlat = 0,
    this.allotedFlat = 0,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    List<FlatModel> flatList =
        json["InventoryFlatData"] == null
            ? []
            : List<FlatModel>.from(
              json["InventoryFlatData"].map((x) => FlatModel.fromJson(x)),
            );
    int availableCount =
        flatList.where((flat) => flat.flatStatus == "Available").length;
    int bookedFlat =
        flatList.where((flat) => flat.flatStatus == "Booked").length;
    int blockedFlat =
        flatList.where((flat) => flat.flatStatus == "Blocked").length;
    int holdFlat = flatList.where((flat) => flat.flatStatus == "Hold").length;
    int allotedFlat =
        flatList.where((flat) => flat.flatStatus == "Alloted").length;

    return FloorModel(
      inventoryFloorId: parseValue<int>(json, "InventoryFloorId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
      inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
        json,
        "InventoryFlatFloorBasementPodiumWingId",
      ),
      floor: parseValue<String>(json, "Floor"),
      slabHeight: parseValue<double>(json, "SlabHeight"),
      parkingCount: parseValue<int>(json, "ParkingCount"),
      flatList: flatList,
      totalFlat: flatList.length,
      availableFlat: availableCount,
      bookedFlat: bookedFlat,
      blockedFlat: blockedFlat,
      holdFlat: holdFlat,
      allotedFlat: allotedFlat,
    );
  }

  Map<String, dynamic> toJson() => {
    "InventoryFloorId": inventoryFloorId,
    "Uniquekey": uniquekey,
    "InventoryBuildingId": inventoryBuildingId,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "Floor": floor,
    "SlabHeight": slabHeight,
    "ParkingCount": parkingCount,
    "InventoryFlatData": List<dynamic>.from(flatList.map((x) => x.toJson())),
  };
  FloorModel copyWith({
    int? inventoryFloorId,
    String? uniquekey,
    int? inventoryBuildingId,
    int? inventoryFlatFloorBasementPodiumWingId,
    String? floor,
    double? slabHeight,
    int? parkingCount,
    List<FlatModel>? flatList,
    int? totalFlat,
    int? availableFlat,
    int? bookedFlat,
    int? blockedFlat,
    int? holdFlat,
    int? allotedFlat,
  }) {
    return FloorModel(
      inventoryFloorId: inventoryFloorId ?? this.inventoryFloorId,
      uniquekey: uniquekey ?? this.uniquekey,
      inventoryBuildingId: inventoryBuildingId ?? this.inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          inventoryFlatFloorBasementPodiumWingId ??
          this.inventoryFlatFloorBasementPodiumWingId,
      floor: floor ?? this.floor,
      slabHeight: slabHeight ?? this.slabHeight,
      parkingCount: parkingCount ?? this.parkingCount,
      flatList: flatList ?? this.flatList,
      totalFlat: totalFlat ?? this.totalFlat,
      availableFlat: availableFlat ?? this.availableFlat,
      bookedFlat: bookedFlat ?? this.bookedFlat,
      blockedFlat: blockedFlat ?? this.blockedFlat,
      holdFlat: holdFlat ?? this.holdFlat,
      allotedFlat: allotedFlat ?? this.allotedFlat,
    );
  }
}

class FlatModel {
  int inventoryFlatId;
  String uniquekey;
  int inventoryBuildingId;
  String buildingNumber;
  int inventoryFlatFloorBasementPodiumWingId;
  String wing;
  int inventoryFloorId;
  String floor;
  String flat;
  double reraCarpetAreaSqFt;
  String flatType;
  String flatConfiguration;
  String flatStatus;
  String ownerName;
  String flatFacing;
  int bookingId;
  int bookingCreatedById;
  String bookingCreatedBy;
  DateTime? bookingCreatedDate;
  List<FlatSpecificationModel> specificationList;

  FlatModel({
    required this.inventoryFlatId,
    required this.uniquekey,
    required this.inventoryBuildingId,
    required this.buildingNumber,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.wing,
    required this.inventoryFloorId,
    required this.floor,
    required this.flat,
    required this.reraCarpetAreaSqFt,
    required this.flatType,
    required this.flatConfiguration,
    required this.flatStatus,
    required this.ownerName,
    required this.flatFacing,
    required this.bookingId,
    required this.bookingCreatedById,
    required this.bookingCreatedBy,
    required this.bookingCreatedDate,
    required this.specificationList,
  });

  factory FlatModel.fromJson(Map<String, dynamic> json) => FlatModel(
    inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
      json,
      "InventoryFlatFloorBasementPodiumWingId",
    ),
    wing: parseValue<String>(json, "Wing"),
    inventoryFloorId: parseValue<int>(json, "InventoryFloorId"),
    floor: parseValue<String>(json, "Floor"),
    flat: parseValue<String>(json, "Flat"),
    reraCarpetAreaSqFt: parseValue<double>(json, "RERACarpetAreaSqFt"),
    flatType: parseValue<String>(json, "FlatType"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    flatStatus: parseValue<String>(json, "FlatStatus"),
    ownerName: parseValue<String>(json, "OwnerName"),
    flatFacing: parseValue<String>(json, "FlatFacing"),
    bookingId: parseValue<int>(json, "BookingId"),
    bookingCreatedById: parseValue<int>(json, "BookingCreatedById"),
    bookingCreatedBy: parseValue<String>(json, "BookingCreatedBy"),
    bookingCreatedDate:
        json["BookingCreatedDate"] == null
            ? null
            : parseValue<DateTime>(json, "BookingCreatedDate"),
    specificationList:
        json["InventoryFlatSpecificationData"] == null
            ? []
            : List<FlatSpecificationModel>.from(
              json["InventoryFlatSpecificationData"].map(
                (x) => FlatSpecificationModel.fromJson(x),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "InventoryFlatId": inventoryFlatId,
    "Uniquekey": uniquekey,
    "InventoryBuildingId": inventoryBuildingId,
    "BuildingNumber": buildingNumber,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "Wing": wing,
    "InventoryFloorId": inventoryFloorId,
    "Floor": floor,
    "Flat": flat,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "FlatType": flatType,
    "FlatConfiguration": flatConfiguration,
    "FlatStatus": flatStatus,
    "OwnerName": ownerName,
    "FlatFacing": flatFacing,
    "BookingId": bookingId,
    "BookingCreatedById": bookingCreatedById,
    "BookingCreatedBy": bookingCreatedBy,
    "BookingCreatedDate": bookingCreatedDate?.toIso8601String(),
    "InventoryFlatSpecificationData": List<dynamic>.from(
      specificationList.map((x) => x.toJson()),
    ),
  };

  FlatModel copyWith({
    int? inventoryFlatId,
    String? uniquekey,
    int? inventoryBuildingId,
    String? buildingNumber,
    int? inventoryFlatFloorBasementPodiumWingId,
    String? wing,
    int? inventoryFloorId,
    String? floor,
    String? flat,
    double? reraCarpetAreaSqFt,
    String? flatType,
    String? flatConfiguration,
    String? flatStatus,
    String? ownerName,
    String? flatFacing,
    int? bookingId,
    int? bookingCreatedById,
    String? bookingCreatedBy,
    DateTime? bookingCreatedDate,
    List<FlatSpecificationModel>? specificationList,
  }) {
    return FlatModel(
      inventoryFlatId: inventoryFlatId ?? this.inventoryFlatId,
      uniquekey: uniquekey ?? this.uniquekey,
      inventoryBuildingId: inventoryBuildingId ?? this.inventoryBuildingId,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      inventoryFlatFloorBasementPodiumWingId:
          inventoryFlatFloorBasementPodiumWingId ??
          this.inventoryFlatFloorBasementPodiumWingId,
      wing: wing ?? this.wing,
      inventoryFloorId: inventoryFloorId ?? this.inventoryFloorId,
      floor: floor ?? this.floor,
      flat: flat ?? this.flat,
      reraCarpetAreaSqFt: reraCarpetAreaSqFt ?? this.reraCarpetAreaSqFt,
      flatType: flatType ?? this.flatType,
      flatConfiguration: flatConfiguration ?? this.flatConfiguration,
      flatStatus: flatStatus ?? this.flatStatus,
      ownerName: ownerName ?? this.ownerName,
      flatFacing: flatFacing ?? this.flatFacing,
      bookingId: bookingId ?? this.bookingId,
      bookingCreatedById: bookingCreatedById ?? this.bookingCreatedById,
      bookingCreatedBy: bookingCreatedBy ?? this.bookingCreatedBy,
      bookingCreatedDate: bookingCreatedDate ?? this.bookingCreatedDate,
      specificationList: specificationList ?? this.specificationList,
    );
  }
}

class FlatSpecificationModel {
  int inventoryFlatSpecificationId;
  String uniquekey;
  int inventoryBuildingId;
  int inventoryFlatFloorBasementPodiumWingId;
  int inventoryFloorId;
  int inventoryFlatId;
  String flatLayout;
  double flatLayoutAreaSqFt;
  double flatLayoutLengthSqFt;
  double flatLayoutWidthSqFt;
  String note;

  FlatSpecificationModel({
    required this.inventoryFlatSpecificationId,
    required this.uniquekey,
    required this.inventoryBuildingId,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.inventoryFloorId,
    required this.inventoryFlatId,
    required this.flatLayout,
    required this.flatLayoutAreaSqFt,
    required this.flatLayoutLengthSqFt,
    required this.flatLayoutWidthSqFt,
    required this.note,
  });

  factory FlatSpecificationModel.fromJson(Map<String, dynamic> json) =>
      FlatSpecificationModel(
        inventoryFlatSpecificationId: parseValue<int>(
          json,
          "InventoryFlatSpecificationId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
        inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
          json,
          "InventoryFlatFloorBasementPodiumWingId",
        ),
        inventoryFloorId: parseValue<int>(json, "InventoryFloorId"),
        inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
        flatLayout: parseValue<String>(json, "FlatLayout"),
        flatLayoutAreaSqFt: parseValue<double>(json, "FlatLayoutAreaSqFt"),
        flatLayoutLengthSqFt: parseValue<double>(json, "FlatLayoutLengthSqFt"),
        flatLayoutWidthSqFt: parseValue<double>(json, "FlatLayoutWidthSqFt"),
        note: parseValue<String>(json, "Note"),
      );

  Map<String, dynamic> toJson() => {
    "InventoryFlatSpecificationId": inventoryFlatSpecificationId,
    "Uniquekey": uniquekey,
    "InventoryBuildingId": inventoryBuildingId,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "InventoryFloorId": inventoryFloorId,
    "InventoryFlatId": inventoryFlatId,
    "FlatLayout": flatLayout,
    "FlatLayoutAreaSqFt": flatLayoutAreaSqFt,
    "FlatLayoutLengthSqFt": flatLayoutLengthSqFt,
    "FlatLayoutWidthSqFt": flatLayoutWidthSqFt,
    "Note": note,
  };
}
