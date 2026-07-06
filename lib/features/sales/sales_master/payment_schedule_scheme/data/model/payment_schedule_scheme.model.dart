import 'package:k3h_erp_app/utils/functions/common_function.dart';

class PaymentScheduleSchemeModel {
  int paymentScheduleSchemeMasterId;
  String uniquekey;
  int projectId;
  String paymentScheduleSchemeName;

  int inventoryBuildingId;
  String buildingNumber;
  String wing;
  int inventoryFlatFloorBasementPodiumWingId;
  bool isExistsPaymentScheduleScheme;

  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  PaymentScheduleSchemeModel({
    required this.paymentScheduleSchemeMasterId,
    required this.uniquekey,
    required this.projectId,
    required this.paymentScheduleSchemeName,
    required this.inventoryBuildingId,
    required this.buildingNumber,
    required this.wing,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.isExistsPaymentScheduleScheme,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PaymentScheduleSchemeModel.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleSchemeModel(
        paymentScheduleSchemeMasterId: parseValue<int>(
          json,
          "PaymentScheduleSchemeMasterId",
        ),

        uniquekey: parseValue<String>(json, "Uniquekey"),

        projectId: parseValue<int>(json, "ProjectId"),

        paymentScheduleSchemeName: parseValue<String>(
          json,
          "PaymentScheduleScheme",
        ),

        inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),

        buildingNumber: parseValue<String>(json, "BuildingNumber"),

        wing: parseValue<String>(json, "Wing"),

        inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
          json,
          "InventoryFlatFloorBasementPodiumWingId",
        ),
        isExistsPaymentScheduleScheme: parseValue<bool>(json, "IsExistsPaymentScheduleScheme"),

        createdById: parseValue<int>(json, "CreatedById"),

        createdBy: parseValue<String>(json, "CreatedBy"),

        createdDate:
            json["CreatedDate"] == null
                ? null
                : parseValue<DateTime>(json, "CreatedDate"),

        modifiedById: parseValue<int>(json, "ModifiedById"),

        modifiedBy: parseValue<String>(json, "ModifiedBy"),

        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "PaymentScheduleSchemeMasterId": paymentScheduleSchemeMasterId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "PaymentScheduleScheme": paymentScheduleSchemeName,
    "InventoryBuildingId": inventoryBuildingId,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "IsExistsPaymentScheduleScheme": isExistsPaymentScheduleScheme,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
