import 'package:k3h_erp_app/utils/common_function.dart';

class SubMaterialModel {
  int materialMasterId;
  String materialName;
  int subMaterialMasterId;
  String subMaterialName;
  int materialMasterIdIdRef;
  int uomMasterId;
  String uomCode;
  String uom;

  SubMaterialModel({
    required this.materialMasterId,
    required this.materialName,
    required this.subMaterialMasterId,
    required this.subMaterialName,
    required this.materialMasterIdIdRef,
    required this.uomMasterId,
    required this.uomCode,
    required this.uom,
  });

  factory SubMaterialModel.fromJson(Map<String, dynamic> json) =>
      SubMaterialModel(
        materialMasterId: parseValue<int>(json, "MaterialMasterId"),
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        materialMasterIdIdRef: parseValue<int>(json, "MaterialMasterIdIdRef"),
        uomMasterId: parseValue<int>(json, "UomMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        uom: parseValue<String>(json, "Uom"),
      );

  Map<String, dynamic> toJson() => {
    "MaterialMasterId": materialMasterId,
    "MaterialName": materialName,
    "SubMaterialMasterId": subMaterialMasterId,
    "SubMaterialName": subMaterialName,
    "MaterialMasterIdIdRef": materialMasterIdIdRef,
    "UomMasterId": uomMasterId,
    "UomCode": uomCode,
    "Uom": uom,
  };
}