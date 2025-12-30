import 'package:k3h_erp_app/utils/common_function.dart';

class MaterialMasterModel {
  int materialMasterId;
  String uniquekey;
  String materialCode;
  String materialName;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  MaterialMasterModel({
    required this.materialMasterId,
    required this.uniquekey,
    required this.materialCode,
    required this.materialName,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory MaterialMasterModel.fromJson(Map<String, dynamic> json) =>
      MaterialMasterModel(
        materialMasterId: parseValue<int>(json, "MaterialMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        materialCode: parseValue<String>(json, "MaterialCode"),
        materialName: parseValue<String>(json, "MaterialName"),
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
    "MaterialMasterId": materialMasterId,
    "Uniquekey": uniquekey,
    "MaterialCode": materialCode,
    "MaterialName": materialName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
