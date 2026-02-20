import 'package:k3h_erp_app/utils/common_function.dart';

class PaymentScheduleMasterReport {
  final int carpetArea;
  final String name;

  PaymentScheduleMasterReport({required this.carpetArea, required this.name});

  factory PaymentScheduleMasterReport.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleMasterReport(
        carpetArea: parseValue<int>(json, "CarpetArea"),
        name: parseValue<String>(json, "Name"),
      );

  Map<String, dynamic> toJson() => {"CarpetArea": carpetArea, "Name": name};
}
