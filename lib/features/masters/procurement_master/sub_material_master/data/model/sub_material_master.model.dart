import 'package:k3h_erp_app/utils/common_function.dart';

class SubMaterialMasterModel {
  int subMaterialMasterId;
  String uniquekey;
  String subMaterialName;
  int materialMasterId;
  String materialCode;
  String materialName;
  int uomMasterId;
  String uomCode;
  String uom;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  SubMaterialMasterModel({
    required this.subMaterialMasterId,
    required this.uniquekey,
    required this.subMaterialName,
    required this.materialMasterId,
    required this.materialCode,
    required this.materialName,
    required this.uomMasterId,
    required this.uomCode,
    required this.uom,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory SubMaterialMasterModel.fromJson(Map<String, dynamic> json) =>
      SubMaterialMasterModel(
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        materialMasterId: parseValue<int>(json, "MaterialMasterId"),
        materialCode: parseValue<String>(json, "MaterialCode"),
        materialName: parseValue<String>(json, "MaterialName"),
        uomMasterId: parseValue<int>(json, "UomMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        uom: parseValue<String>(json, "Uom"),
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
    "SubMaterialMasterId": subMaterialMasterId,
    "Uniquekey": uniquekey,
    "SubMaterialName": subMaterialName,
    "MaterialMasterId": materialMasterId,
    "MaterialCode": materialCode,
    "MaterialName": materialName,
    "UomMasterId": uomMasterId,
    "UomCode": uomCode,
    "Uom": uom,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
