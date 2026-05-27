import 'package:k3h_erp_app/utils/common_function.dart';

class ClosingAchievementReportModel {
  int employeeId;
  String employeeName;
  String designationName;
  int totalWalkins;
  int walkinsByCp;
  int walkinsDirect;
  int totalFreshVisits;
  int revisits;
  int bookingByCp;
  int bookingDirect;
  int totalBooking;
  double totalRevenue;

  ClosingAchievementReportModel({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.totalWalkins,
    required this.walkinsByCp,
    required this.walkinsDirect,
    required this.totalFreshVisits,
    required this.revisits,
    required this.bookingByCp,
    required this.bookingDirect,
    required this.totalBooking,
    required this.totalRevenue,
  });

  factory ClosingAchievementReportModel.fromJson(Map<String, dynamic> json) =>
      ClosingAchievementReportModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        designationName: parseValue<String>(json, "DesignationName"),
        totalWalkins: parseValue<int>(json, "TotalWalkins"),
        walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
        walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
        totalFreshVisits: parseValue<int>(json, "TotalFreshVisits"),
        revisits: parseValue<int>(json, "Revisits"),
        bookingByCp: parseValue<int>(json, "BookingByCP"),
        bookingDirect: parseValue<int>(json, "BookingDirect"),
        totalBooking: parseValue<int>(json, "TotalBooking"),
        totalRevenue: parseValue<double>(json, "TotalRevenue"),
      );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "TotalWalkins": totalWalkins,
    "WalkinsByCP": walkinsByCp,
    "WalkinsDirect": walkinsDirect,
    "TotalFreshVisits": totalFreshVisits,
    "Revisits": revisits,
    "BookingByCP": bookingByCp,
    "BookingDirect": bookingDirect,
    "TotalBooking": totalBooking,
    "TotalRevenue": totalRevenue,
  };
}
