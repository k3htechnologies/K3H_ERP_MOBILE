import 'package:k3h_erp_app/utils/common_function.dart';

class StockManagementHistoryModel {
  String materialName;
  String subMaterialName;
  int subMaterialMasterId;
  String uomCode;
  int materialQuantityInwardOutward;
  String inwardOutwardType;
  String reason;
  String systemGeneratedCode;
  int createdById;
  String createdBy;
  DateTime createdDate;

  StockManagementHistoryModel({
    required this.materialName,
    required this.subMaterialName,
    required this.subMaterialMasterId,
    required this.uomCode,
    required this.materialQuantityInwardOutward,
    required this.inwardOutwardType,
    required this.reason,
    required this.systemGeneratedCode,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
  });

  factory StockManagementHistoryModel.fromJson(Map<String, dynamic> json) =>
      StockManagementHistoryModel(
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        materialQuantityInwardOutward: parseValue<int>(
          json,
          "MaterialQuantityInwardOutward",
        ),
        inwardOutwardType: parseValue<String>(json, "InwardOutwardType"),
        reason: parseValue<String>(json, "Reason"),
        systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] != null
                ? DateTime.parse(json["CreatedDate"])
                : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    "MaterialName": materialName,
    "SubMaterialName": subMaterialName,
    "SubMaterialMasterId": subMaterialMasterId,
    "UomCode": uomCode,
    "MaterialQuantityInwardOutward": materialQuantityInwardOutward,
    "InwardOutwardType": inwardOutwardType,
    "Reason": reason,
    "SystemGeneratedCode": systemGeneratedCode,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
  };
}
