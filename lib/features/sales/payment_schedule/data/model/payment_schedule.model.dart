import 'package:k3h_erp_app/utils/common_function.dart';

class PaymentScheduleMasterModel {
  int paymentScheduleMasterId;
  String? uniquekey;
  int projectId;
  int inventoryBuildingId;
  String? stage;
  String? wing;
  String? flatConfiguration;
  double paymentSchedulePercentage;
  double paymentScheduleCummulativePercentage;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String lastModifiedBy;
  DateTime? lastModifiedDate;

  PaymentScheduleMasterModel({
    required this.paymentScheduleMasterId,
    this.uniquekey,
    required this.projectId,
    required this.inventoryBuildingId,
    this.stage,
    this.wing,
    this.flatConfiguration,
    required this.paymentSchedulePercentage,
    required this.paymentScheduleCummulativePercentage,
    required this.createdById,
    required this.createdBy,
    this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
    required this.lastModifiedBy,
    this.lastModifiedDate,
  });

  factory PaymentScheduleMasterModel.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleMasterModel(
        paymentScheduleMasterId: parseValue<int>(
          json,
          "PaymentScheduleMasterId",
        ),
        uniquekey: parseValue<String?>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
        stage: parseValue<String?>(json, "Stage"),
        wing: parseValue<String?>(json, "Wing"),
        flatConfiguration: parseValue<String?>(json, "FlatConfiguration"),
        paymentSchedulePercentage: parseValue<double>(
          json,
          "PaymentSchedulePercentage",
        ),
        paymentScheduleCummulativePercentage: parseValue<double>(
          json,
          "PaymentScheduleCummulativePercentage",
        ),
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
        lastModifiedBy: parseValue<String>(json, "LastModifiedBy"),
        lastModifiedDate:
            json["LastModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "LastModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "PaymentScheduleMasterId": paymentScheduleMasterId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "InventoryBuildingId": inventoryBuildingId,
    "Stage": stage,
    "Wing": wing,
    "FlatConfiguration": flatConfiguration,
    "PaymentSchedulePercentage": paymentSchedulePercentage,
    "PaymentScheduleCummulativePercentage":
        paymentScheduleCummulativePercentage,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "LastModifiedBy": lastModifiedBy,
    "LastModifiedDate": lastModifiedDate?.toIso8601String(),
  };
}
