import 'package:k3h_erp_app/utils/functions/common_function.dart';

class PerformanceReportSourcingModel {
  final int employeeId;
  final String employeeName;
  final String designationName;
  final int walkinsByCp;
  final int actualWalkinsByCp;
  final double performanceWalkinsByCp;
  final int freshVisits;
  final int actualFreshVisits;
  final double performanceFreshVisits;
  final int revisits;
  final int actualRevisits;
  final double performanceRevisits;
  final int bookings;
  final int actualBookings;
  final double performanceBookings;
  final int totalMeetings;
  final int actualTotalMeetings;
  final double performanceTotalMeetings;
  final int totalObm;
  final int actualTotalObm;
  final double performanceTotalObm;
  final int totalObmFreshVisits;
  final int actualTotalObmFreshVisits;
  final double performanceTotalObmFreshVisits;
  final int totalObmRevisits;
  final int actualTotalObmRevisits;
  final double performanceTotalObmRevisits;
  final int totalIbm;
  final int actualTotalIbm;
  final double performanceTotalIbm;
  final int uniqueCPs;
  final int actualUniqueCPs;
  final double performanceUniqueCPs;
  final int activeCp;
  final int actualActiveCp;
  final double performanceActiveCp;
  final int newCp;
  final int actualNewCp;
  final double performanceNewCp;

  PerformanceReportSourcingModel({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCp,
    required this.actualWalkinsByCp,
    required this.performanceWalkinsByCp,
    required this.freshVisits,
    required this.actualFreshVisits,
    required this.performanceFreshVisits,
    required this.revisits,
    required this.actualRevisits,
    required this.performanceRevisits,
    required this.bookings,
    required this.actualBookings,
    required this.performanceBookings,
    required this.totalMeetings,
    required this.actualTotalMeetings,
    required this.performanceTotalMeetings,
    required this.totalObm,
    required this.actualTotalObm,
    required this.performanceTotalObm,
    required this.totalObmFreshVisits,
    required this.actualTotalObmFreshVisits,
    required this.performanceTotalObmFreshVisits,
    required this.totalObmRevisits,
    required this.actualTotalObmRevisits,
    required this.performanceTotalObmRevisits,
    required this.totalIbm,
    required this.actualTotalIbm,
    required this.performanceTotalIbm,
    required this.uniqueCPs,
    required this.actualUniqueCPs,
    required this.performanceUniqueCPs,
    required this.activeCp,
    required this.actualActiveCp,
    required this.performanceActiveCp,
    required this.newCp,
    required this.actualNewCp,
    required this.performanceNewCp,
  });

  factory PerformanceReportSourcingModel.fromJson(Map<String, dynamic> json) =>
      PerformanceReportSourcingModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        designationName: parseValue<String>(json, "DesignationName"),
        walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
        actualWalkinsByCp: parseValue<int>(json, "ActualWalkinsByCP"),
        performanceWalkinsByCp: parseValue<double>(json, "PerformanceWalkinsByCP"),
        freshVisits: parseValue<int>(json, "FreshVisits"),
        actualFreshVisits: parseValue<int>(json, "ActualFreshVisits"),
        performanceFreshVisits: parseValue<double>(json, "PerformanceFreshVisits"),
        revisits: parseValue<int>(json, "Revisits"),
        actualRevisits: parseValue<int>(json, "ActualRevisits"),
        performanceRevisits: parseValue<double>(json, "PerformanceRevisits"),
        bookings: parseValue<int>(json, "Bookings"),
        actualBookings: parseValue<int>(json, "ActualBookings"),
        performanceBookings: parseValue<double>(json, "PerformanceBookings"),
        totalMeetings: parseValue<int>(json, "TotalMeetings"),
        actualTotalMeetings: parseValue<int>(json, "ActualTotalMeetings"),
        performanceTotalMeetings: parseValue<double>(
          json,
          "PerformanceTotalMeetings",
        ),
        totalObm: parseValue<int>(json, "TotalOBM"),
        actualTotalObm: parseValue<int>(json, "ActualTotalOBM"),
        performanceTotalObm: parseValue<double>(json, "PerformanceTotalOBM"),
        totalObmFreshVisits: parseValue<int>(json, "TotalOBMFreshVisits"),
        actualTotalObmFreshVisits: parseValue<int>(
          json,
          "ActualTotalOBMFreshVisits",
        ),
        performanceTotalObmFreshVisits: parseValue<double>(
          json,
          "PerformanceTotalOBMFreshVisits",
        ),
        totalObmRevisits: parseValue<int>(json, "TotalOBMRevisits"),
        actualTotalObmRevisits: parseValue<int>(json, "ActualTotalOBMRevisits"),
        performanceTotalObmRevisits: parseValue<double>(
          json,
          "PerformanceTotalOBMRevisits",
        ),
        totalIbm: parseValue<int>(json, "TotalIBM"),
        actualTotalIbm: parseValue<int>(json, "ActualTotalIBM"),
        performanceTotalIbm: parseValue<double>(json, "PerformanceTotalIBM"),
        uniqueCPs: parseValue<int>(json, "UniqueCPs"),
        actualUniqueCPs: parseValue<int>(json, "ActualUniqueCPs"),
        performanceUniqueCPs: parseValue<double>(json, "PerformanceUniqueCPs"),
        activeCp: parseValue<int>(json, "ActiveCP"),
        actualActiveCp: parseValue<int>(json, "ActualActiveCP"),
        performanceActiveCp: parseValue<double>(json, "PerformanceActiveCP"),
        newCp: parseValue<int>(json, "NewCP"),
        actualNewCp: parseValue<int>(json, "ActualNewCP"),
        performanceNewCp: parseValue<double>(json, "PerformanceNewCP"),
      );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCp,
    "ActualWalkinsByCP": actualWalkinsByCp,
    "PerformanceWalkinsByCP": performanceWalkinsByCp,
    "FreshVisits": freshVisits,
    "ActualFreshVisits": actualFreshVisits,
    "PerformanceFreshVisits": performanceFreshVisits,
    "Revisits": revisits,
    "ActualRevisits": actualRevisits,
    "PerformanceRevisits": performanceRevisits,
    "Bookings": bookings,
    "ActualBookings": actualBookings,
    "PerformanceBookings": performanceBookings,
    "TotalMeetings": totalMeetings,
    "ActualTotalMeetings": actualTotalMeetings,
    "PerformanceTotalMeetings": performanceTotalMeetings,
    "TotalOBM": totalObm,
    "ActualTotalOBM": actualTotalObm,
    "PerformanceTotalOBM": performanceTotalObm,
    "TotalOBMFreshVisits": totalObmFreshVisits,
    "ActualTotalOBMFreshVisits": actualTotalObmFreshVisits,
    "PerformanceTotalOBMFreshVisits": performanceTotalObmFreshVisits,
    "TotalOBMRevisits": totalObmRevisits,
    "ActualTotalOBMRevisits": actualTotalObmRevisits,
    "PerformanceTotalOBMRevisits": performanceTotalObmRevisits,
    "TotalIBM": totalIbm,
    "ActualTotalIBM": actualTotalIbm,
    "PerformanceTotalIBM": performanceTotalIbm,
    "UniqueCPs": uniqueCPs,
    "ActualUniqueCPs": actualUniqueCPs,
    "PerformanceUniqueCPs": performanceUniqueCPs,
    "ActiveCP": activeCp,
    "ActualActiveCP": actualActiveCp,
    "PerformanceActiveCP": performanceActiveCp,
    "NewCP": newCp,
    "ActualNewCP": actualNewCp,
    "PerformanceNewCP": performanceNewCp,
  };
}
