import 'package:k3h_erp_app/utils/common_function.dart';

class SaleTargetClosingModel {
  final String uniquekey;
  final int projectId;
  final int employeeId;
  final String employeeName;
  final int salesTargetClosingId;
  final int walkinsByCp;
  final int walkinsDirect;
  final int freshVisits;
  final int revisits;
  final int bookingByCp;
  final int bookingDirect;
  final DateTime fromDate;
  final DateTime toDate;
  final int createdById;
  final String createdBy;
  final String createdDate;
  final int modifiedById;
  final String modifiedBy;
  final String? modifiedDate;

  SaleTargetClosingModel({
    required this.uniquekey,
    required this.projectId,
    required this.employeeId,
    required this.employeeName,
    required this.salesTargetClosingId,
    required this.walkinsByCp,
    required this.walkinsDirect,
    required this.freshVisits,
    required this.revisits,
    required this.bookingByCp,
    required this.bookingDirect,
    required this.fromDate,
    required this.toDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory SaleTargetClosingModel.fromJson(Map<String, dynamic> json) =>
      SaleTargetClosingModel(
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        salesTargetClosingId: parseValue<int>(json, "SalesTargetClosingId"),
        walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
        walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
        freshVisits: parseValue<int>(json, "FreshVisits"),
        revisits: parseValue<int>(json, "Revisits"),
        bookingByCp: parseValue<int>(json, "BookingByCP"),
        bookingDirect: parseValue<int>(json, "BookingDirect"),
        fromDate: parseValue<DateTime>(json, "FromDate"),
        toDate: parseValue<DateTime>(json, "ToDate"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<String>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: parseValue<String>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "SalesTargetClosingId": salesTargetClosingId,
    "WalkinsByCP": walkinsByCp,
    "WalkinsDirect": walkinsDirect,
    "FreshVisits": freshVisits,
    "Revisits": revisits,
    "BookingByCP": bookingByCp,
    "BookingDirect": bookingDirect,
    "FromDate": fromDate.toIso8601String(),
    "ToDate": toDate.toIso8601String(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
