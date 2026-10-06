import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SpecificationMasterModel {
  int specificationMasterId;
  String uniqueKey;
  String levelType;
  String categoryName;
  int levelId1;
  String level1Name;
  int levelId2;
  String level2Name;
  int levelId3;
  String level3Name;
  int subMaterialMasterId;
  String subMaterialName;
  String materialName;
  String subMaterialUomCode;
  String subMaterialUom;
  int quantity;
  int uomMasterId;
  String uomCode;
  int leadTimeInDays;
  bool isTolerant;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  SpecificationMasterModel({
    required this.specificationMasterId,
    required this.uniqueKey,
    required this.levelType,
    required this.categoryName,
    required this.levelId1,
    required this.level1Name,
    required this.levelId2,
    required this.level2Name,
    required this.levelId3,
    required this.level3Name,
    required this.subMaterialMasterId,
    required this.subMaterialName,
    required this.materialName,
    required this.subMaterialUomCode,
    required this.subMaterialUom,
    required this.quantity,
    required this.uomMasterId,
    required this.uomCode,
    required this.leadTimeInDays,
    required this.isTolerant,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory SpecificationMasterModel.fromJson(Map<String, dynamic> json) =>
      SpecificationMasterModel(
        specificationMasterId: parseValue<int>(json, "SpecificationMasterId"),
        uniqueKey: parseValue<String>(json, "UniqueKey"),
        levelType: parseValue<String>(json, "LevelType"),
        categoryName: parseValue<String>(json, "CategoryName"),
        levelId1: parseValue<int>(json, "LevelId1"),
        level1Name: parseValue<String>(json, "Level1Name"),
        levelId2: parseValue<int>(json, "LevelId2"),
        level2Name: parseValue<String>(json, "Level2Name"),
        levelId3: parseValue<int>(json, "LevelId3"),
        level3Name: parseValue<String>(json, "Level3Name"),
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialUomCode: parseValue<String>(json, "SubMaterialUomCode"),
        subMaterialUom: parseValue<String>(json, "SubMaterialUom"),
        quantity: parseValue<int>(json, "Quantity"),
        uomMasterId: parseValue<int>(json, "UomMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        leadTimeInDays: parseValue<int>(json, "LeadTimeInDays"),
        isTolerant: parseValue<bool>(json, "IsTolerant"),
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
    "SpecificationMasterId": specificationMasterId,
    "UniqueKey": uniqueKey,
    "LevelType": levelType,
    "CategoryName": categoryName,
    "LevelId1": levelId1,
    "Level1Name": level1Name,
    "LevelId2": levelId2,
    "Level2Name": level2Name,
    "LevelId3": levelId3,
    "Level3Name": level3Name,
    "SubMaterialMasterId": subMaterialMasterId,
    "SubMaterialName": subMaterialName,
    "MaterialName": materialName,
    "SubMaterialUomCode": subMaterialUomCode,
    "SubMaterialUom": subMaterialUom,
    "Quantity": quantity,
    "UomMasterId": uomMasterId,
    "UomCode": uomCode,
    "LeadTimeInDays": leadTimeInDays,
    "IsTolerant": isTolerant,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
