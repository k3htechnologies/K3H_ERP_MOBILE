import 'package:k3h_erp_app/utils/common_function.dart';

class SourcingAchievementReportModel {
  int employeeId;
  String employeeName;
  String designationName;
  int walkinsByCp;
  int freshVisits;
  int revisits;
  int bookings;
  double totalRevenue;
  int totalMeetings;
  int totalObmFreshVisits;
  int totalObmRevisits;
  int totalIbm;

  SourcingAchievementReportModel({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCp,
    required this.freshVisits,
    required this.revisits,
    required this.bookings,
    required this.totalRevenue,
    required this.totalMeetings,
    required this.totalObmFreshVisits,
    required this.totalObmRevisits,
    required this.totalIbm,
  });

  factory SourcingAchievementReportModel.fromJson(Map<String, dynamic> json) =>
      SourcingAchievementReportModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        designationName: parseValue<String>(json, "DesignationName"),
        walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
        freshVisits: parseValue<int>(json, "FreshVisits"),
        revisits: parseValue<int>(json, "Revisits"),
        bookings: parseValue<int>(json, "Bookings"),
        totalRevenue: parseValue<double>(json, "TotalRevenue"),
        totalMeetings: parseValue<int>(json, "TotalMeetings"),
        totalObmFreshVisits: parseValue<int>(json, "TotalOBMFreshVisits"),
        totalObmRevisits: parseValue<int>(json, "TotalOBMRevisits"),
        totalIbm: parseValue<int>(json, "TotalIBM"),
      );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCp,
    "FreshVisits": freshVisits,
    "Revisits": revisits,
    "Bookings": bookings,
    "TotalRevenue": totalRevenue,
    "TotalMeetings": totalMeetings,
    "TotalOBMFreshVisits": totalObmFreshVisits,
    "TotalOBMRevisits": totalObmRevisits,
    "TotalIBM": totalIbm,
  };
}
