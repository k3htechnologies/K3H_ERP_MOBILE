import 'package:k3h_erp_app/utils/common_function.dart';

class PaymentScheduleMasterReport {
  final int carpetArea;
  final int inventoryFlatId;
  final String name;
  final double paymentSchedulePercentage;
  final double totalValue;

  PaymentScheduleMasterReport({
    required this.inventoryFlatId,
    required this.carpetArea,
    required this.name,
    required this.paymentSchedulePercentage,
    required this.totalValue,
  });

  factory PaymentScheduleMasterReport.fromJson(Map<String, dynamic> json) =>
      PaymentScheduleMasterReport(
        carpetArea: parseValue<int>(json, "CarpetArea"),
        inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),

        name: parseValue<String>(json, "Name"),
        paymentSchedulePercentage: parseValue<double>(
          json,
          "PaymentSchedulePercentage",
        ),
        totalValue: parseValue<double>(json, "TotalValue"),
      );

  Map<String, dynamic> toJson() => {
    "CarpetArea": carpetArea,
    "InventoryFlatId": inventoryFlatId,
    "Name": name,
    "PaymentSchedulePercentage": paymentSchedulePercentage,
    "TotalValue": totalValue,
  };
}

class FlatPaymentSchedule {
  final int inventoryFlatId;
  final int carpetArea;
  final List<PaymentScheduleMasterReport> slabs;

  FlatPaymentSchedule({
    required this.inventoryFlatId,
    required this.carpetArea,
    required this.slabs,
  });

  factory FlatPaymentSchedule.fromJson(Map<String, dynamic> json) {
    final slabList =
        (json['Slabs'] as List<dynamic>? ?? [])
            .map((e) => PaymentScheduleMasterReport.fromJson(e))
            .toList();

    return FlatPaymentSchedule(
      inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
      carpetArea: parseValue<int>(json, "CarpetArea"),
      slabs: slabList,
    );
  }

  Map<String, dynamic> toJson() => {
    "InventoryFlatId": inventoryFlatId,
    "CarpetArea": carpetArea,
    "Slabs": slabs.map((e) => e.toJson()).toList(),
  };
}
