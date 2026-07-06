import 'package:k3h_erp_app/utils/functions/common_function.dart';

class StockManagementModel {
  String materialName;
  String subMaterialName;
  int subMaterialMasterId;
  String uomCode;
  double totalMaterialQuantityInStock;

  StockManagementModel({
    required this.materialName,
    required this.subMaterialName,
    required this.subMaterialMasterId,
    required this.uomCode,
    required this.totalMaterialQuantityInStock,
  });

  factory StockManagementModel.fromJson(Map<String, dynamic> json) =>
      StockManagementModel(
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        totalMaterialQuantityInStock: parseValue<double>(
          json,
          "TotalMaterialQuantityInStock",
        ),
      );

  Map<String, dynamic> toJson() => {
    "MaterialName": materialName,
    "SubMaterialName": subMaterialName,
    "SubMaterialMasterId": subMaterialMasterId,
    "UomCode": uomCode,
    "TotalMaterialQuantityInStock": totalMaterialQuantityInStock,
  };
}
