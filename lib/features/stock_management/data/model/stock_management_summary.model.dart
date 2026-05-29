import 'package:k3h_erp_app/utils/common_function.dart';

class StockManagementSummaryModel {
  String materialName;
  String subMaterialName;
  int subMaterialMasterId;
  String uomCode;
  String systemGeneratedCode;
  double totalMaterialQuantityInStock;
  int availableMaterial;

  StockManagementSummaryModel({
    required this.materialName,
    required this.subMaterialName,
    required this.subMaterialMasterId,
    required this.uomCode,
    required this.systemGeneratedCode,
    required this.totalMaterialQuantityInStock,
    required this.availableMaterial,
  });

  factory StockManagementSummaryModel.fromJson(Map<String, dynamic> json) =>
      StockManagementSummaryModel(
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
        totalMaterialQuantityInStock: parseValue<double>(
          json,
          "TotalMaterialQuantityInStock",
        ),
        availableMaterial: parseValue<int>(json, "AvailableMaterial"),
      );

  Map<String, dynamic> toJson() => {
    "MaterialName": materialName,
    "SubMaterialName": subMaterialName,
    "SubMaterialMasterId": subMaterialMasterId,
    "UomCode": uomCode,
    "SystemGeneratedCode": systemGeneratedCode,
    "TotalMaterialQuantityInStock": totalMaterialQuantityInStock,
    "AvailableMaterial": availableMaterial,
  };
}
