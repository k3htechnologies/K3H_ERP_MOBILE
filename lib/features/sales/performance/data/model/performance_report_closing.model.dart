import 'package:k3h_erp_app/utils/common_function.dart';

class PerformanceReportClosingModel {
  final int employeeId;
  final String employeeName;
  final String designationName;
  final int walkinsByCp;
  final int actualWalkinsByCp;
  final int performanceWalkinsByCp;
  final int walkinsDirect;
  final int actualWalkinsDirect;
  final int performanceWalkinsDirect;
  final int freshVisits;
  final int actualFreshVisits;
  final int performanceFreshVisits;
  final int revisits;
  final int actualRevisits;
  final int performanceRevisits;
  final int bookingByCp;
  final int actualBookingByCp;
  final int performanceBookingByCp;
  final int bookingDirect;
  final int actualBookingDirect;
  final int performanceBookingDirect;

  PerformanceReportClosingModel({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCp,
    required this.actualWalkinsByCp,
    required this.performanceWalkinsByCp,
    required this.walkinsDirect,
    required this.actualWalkinsDirect,
    required this.performanceWalkinsDirect,
    required this.freshVisits,
    required this.actualFreshVisits,
    required this.performanceFreshVisits,
    required this.revisits,
    required this.actualRevisits,
    required this.performanceRevisits,
    required this.bookingByCp,
    required this.actualBookingByCp,
    required this.performanceBookingByCp,
    required this.bookingDirect,
    required this.actualBookingDirect,
    required this.performanceBookingDirect,
  });

  factory PerformanceReportClosingModel.fromJson(
    Map<String, dynamic> json,
  ) => PerformanceReportClosingModel(
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    designationName: parseValue<String>(json, "DesignationName"),
    walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
    actualWalkinsByCp: parseValue<int>(json, "ActualWalkinsByCP"),
    performanceWalkinsByCp: parseValue<int>(json, "PerformanceWalkinsByCP"),
    walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
    actualWalkinsDirect: parseValue<int>(json, "ActualWalkinsDirect"),
    performanceWalkinsDirect: parseValue<int>(json, "PerformanceWalkinsDirect"),
    freshVisits: parseValue<int>(json, "FreshVisits"),
    actualFreshVisits: parseValue<int>(json, "ActualFreshVisits"),
    performanceFreshVisits: parseValue<int>(json, "PerformanceFreshVisits"),
    revisits: parseValue<int>(json, "Revisits"),
    actualRevisits: parseValue<int>(json, "ActualRevisits"),
    performanceRevisits: parseValue<int>(json, "PerformanceRevisits"),
    bookingByCp: parseValue<int>(json, "BookingByCP"),
    actualBookingByCp: parseValue<int>(json, "ActualBookingByCP"),
    performanceBookingByCp: parseValue<int>(json, "PerformanceBookingByCP"),
    bookingDirect: parseValue<int>(json, "BookingDirect"),
    actualBookingDirect: parseValue<int>(json, "ActualBookingDirect"),
    performanceBookingDirect: parseValue<int>(json, "PerformanceBookingDirect"),
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCp,
    "ActualWalkinsByCP": actualWalkinsByCp,
    "PerformanceWalkinsByCP": performanceWalkinsByCp,
    "WalkinsDirect": walkinsDirect,
    "ActualWalkinsDirect": actualWalkinsDirect,
    "PerformanceWalkinsDirect": performanceWalkinsDirect,
    "FreshVisits": freshVisits,
    "ActualFreshVisits": actualFreshVisits,
    "PerformanceFreshVisits": performanceFreshVisits,
    "Revisits": revisits,
    "ActualRevisits": actualRevisits,
    "PerformanceRevisits": performanceRevisits,
    "BookingByCP": bookingByCp,
    "ActualBookingByCP": actualBookingByCp,
    "PerformanceBookingByCP": performanceBookingByCp,
    "BookingDirect": bookingDirect,
    "ActualBookingDirect": actualBookingDirect,
    "PerformanceBookingDirect": performanceBookingDirect,
  };
}
