import 'package:k3h_erp_app/utils/common_function.dart';

class CostSheetReport {
  final int carpetArea;
  final String name;

  CostSheetReport({required this.carpetArea, required this.name});

  factory CostSheetReport.fromJson(Map<String, dynamic> json) =>
      CostSheetReport(
        carpetArea: parseValue<int>(json, "CarpetArea"),
        name: parseValue<String>(json, "Name"),
      );

  Map<String, dynamic> toJson() => {"CarpetArea": carpetArea, "Name": name};
}
