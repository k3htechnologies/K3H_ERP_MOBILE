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
        subMaterialMasterId: json["SubMaterialMasterId"],
        uomCode: json["UomCode"],
        systemGeneratedCode: json["SystemGeneratedCode"],
        totalMaterialQuantityInStock:
            json["TotalMaterialQuantityInStock"]?.toDouble(),
        availableMaterial: json["AvailableMaterial"],
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
