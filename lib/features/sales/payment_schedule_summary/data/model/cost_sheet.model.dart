import 'package:k3h_erp_app/utils/common_function.dart';

class CostSheetReport {
  final double carpetArea;
  final String flatConfiguration;
  final double totalValue;

  CostSheetReport({
    required this.carpetArea,
    required this.flatConfiguration,
    required this.totalValue,
  });

  factory CostSheetReport.fromJson(Map<String, dynamic> json) =>
      CostSheetReport(
        carpetArea: parseValue<double>(json, "CarpetArea"),
        flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
        totalValue: parseValue<double>(json, "TotalValue"),
      );

  Map<String, dynamic> toJson() => {
    "CarpetArea": carpetArea,
    "FlatConfiguration": flatConfiguration,
    "TotalValue": totalValue,
  };
}
