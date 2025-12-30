import 'package:k3h_erp_app/utils/common_function.dart';

class UOMModel {
  int uomMasterId;
  String uomCode;
  String uom;

  UOMModel({required this.uomMasterId, required this.uomCode, required this.uom});

  factory UOMModel.fromJson(Map<String, dynamic> json) => UOMModel(
    uomMasterId: parseValue<int>(json, "UomMasterId"),
    uomCode: parseValue<String>(json, "UomCode"),
    uom: parseValue<String>(json, "Uom"),
  );

  Map<String, dynamic> toJson() => {
    "UomMasterId": uomMasterId,
    "UomCode": uomCode,
    "Uom": uom,
  };
}