import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectWiseSalesDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<ProjectAchievementReportModel> projectAchievementData;
  final List<Table3> table3;

  ProjectWiseSalesDashboardModel({
    required this.table0,
    required this.table1,
    required this.projectAchievementData,
    required this.table3,
  });
  factory ProjectWiseSalesDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => ProjectWiseSalesDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),

    projectAchievementData: List<ProjectAchievementReportModel>.from(
      json["Table2"].map((x) => ProjectAchievementReportModel.fromJson(x)),
    ),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(projectAchievementData.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
  };
}

class Table0 {
  final int employeeId;
  final String employeeName;
  final String designationName;

  final int walkinsByCP;
  final int actualWalkinsByCP;
  final double performanceWalkinsByCP;

  final int walkinsDirect;
  final int actualWalkinsDirect;
  final double performanceWalkinsDirect;

  final int freshVisits;
  final int actualFreshVisits;
  final double performanceFreshVisits;

  final int revisits;
  final int actualRevisits;
  final double performanceRevisits;

  final int bookingByCP;
  final int actualBookingByCP;
  final double performanceBookingByCP;

  final int bookingDirect;
  final int actualBookingDirect;
  final double performanceBookingDirect;

  Table0({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCP,
    required this.actualWalkinsByCP,
    required this.performanceWalkinsByCP,
    required this.walkinsDirect,
    required this.actualWalkinsDirect,
    required this.performanceWalkinsDirect,
    required this.freshVisits,
    required this.actualFreshVisits,
    required this.performanceFreshVisits,
    required this.revisits,
    required this.actualRevisits,
    required this.performanceRevisits,
    required this.bookingByCP,
    required this.actualBookingByCP,
    required this.performanceBookingByCP,
    required this.bookingDirect,
    required this.actualBookingDirect,
    required this.performanceBookingDirect,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    designationName: parseValue<String>(json, "DesignationName"),

    walkinsByCP: parseValue<int>(json, "WalkinsByCP"),
    actualWalkinsByCP: parseValue<int>(json, "ActualWalkinsByCP"),
    performanceWalkinsByCP:
        parseValue<num>(json, "PerformanceWalkinsByCP").toDouble(),

    walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
    actualWalkinsDirect: parseValue<int>(json, "ActualWalkinsDirect"),
    performanceWalkinsDirect:
        parseValue<num>(json, "PerformanceWalkinsDirect").toDouble(),

    freshVisits: parseValue<int>(json, "FreshVisits"),
    actualFreshVisits: parseValue<int>(json, "ActualFreshVisits"),
    performanceFreshVisits:
        parseValue<num>(json, "PerformanceFreshVisits").toDouble(),

    revisits: parseValue<int>(json, "Revisits"),
    actualRevisits: parseValue<int>(json, "ActualRevisits"),
    performanceRevisits:
        parseValue<num>(json, "PerformanceRevisits").toDouble(),

    bookingByCP: parseValue<int>(json, "BookingByCP"),
    actualBookingByCP: parseValue<int>(json, "ActualBookingByCP"),
    performanceBookingByCP:
        parseValue<num>(json, "PerformanceBookingByCP").toDouble(),

    bookingDirect: parseValue<int>(json, "BookingDirect"),
    actualBookingDirect: parseValue<int>(json, "ActualBookingDirect"),
    performanceBookingDirect:
        parseValue<num>(json, "PerformanceBookingDirect").toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCP,
    "ActualWalkinsByCP": actualWalkinsByCP,
    "PerformanceWalkinsByCP": performanceWalkinsByCP,
    "WalkinsDirect": walkinsDirect,
    "ActualWalkinsDirect": actualWalkinsDirect,
    "PerformanceWalkinsDirect": performanceWalkinsDirect,
    "FreshVisits": freshVisits,
    "ActualFreshVisits": actualFreshVisits,
    "PerformanceFreshVisits": performanceFreshVisits,
    "Revisits": revisits,
    "ActualRevisits": actualRevisits,
    "PerformanceRevisits": performanceRevisits,
    "BookingByCP": bookingByCP,
    "ActualBookingByCP": actualBookingByCP,
    "PerformanceBookingByCP": performanceBookingByCP,
    "BookingDirect": bookingDirect,
    "ActualBookingDirect": actualBookingDirect,
    "PerformanceBookingDirect": performanceBookingDirect,
  };
}

class Table1 {
  final int employeeId;
  final String employeeName;
  final String designationName;

  final int walkinsByCP;
  final int actualWalkinsByCP;
  final double performanceWalkinsByCP;

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

  final int totalOBM;
  final int actualTotalOBM;
  final double performanceTotalOBM;

  final int totalOBMFreshVisits;
  final int actualTotalOBMFreshVisits;
  final double performanceTotalOBMFreshVisits;

  final int totalOBMRevisits;
  final int actualTotalOBMRevisits;
  final double performanceTotalOBMRevisits;

  final int totalIBM;
  final int actualTotalIBM;
  final double performanceTotalIBM;

  final int uniqueCPs;
  final int actualUniqueCPs;
  final double performanceUniqueCPs;

  final int activeCP;
  final int actualActiveCP;
  final double performanceActiveCP;

  final int newCP;
  final int actualNewCP;
  final double performanceNewCP;

  Table1({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCP,
    required this.actualWalkinsByCP,
    required this.performanceWalkinsByCP,
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
    required this.totalOBM,
    required this.actualTotalOBM,
    required this.performanceTotalOBM,
    required this.totalOBMFreshVisits,
    required this.actualTotalOBMFreshVisits,
    required this.performanceTotalOBMFreshVisits,
    required this.totalOBMRevisits,
    required this.actualTotalOBMRevisits,
    required this.performanceTotalOBMRevisits,
    required this.totalIBM,
    required this.actualTotalIBM,
    required this.performanceTotalIBM,
    required this.uniqueCPs,
    required this.actualUniqueCPs,
    required this.performanceUniqueCPs,
    required this.activeCP,
    required this.actualActiveCP,
    required this.performanceActiveCP,
    required this.newCP,
    required this.actualNewCP,
    required this.performanceNewCP,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    designationName: parseValue<String>(json, "DesignationName"),

    walkinsByCP: parseValue<int>(json, "WalkinsByCP"),
    actualWalkinsByCP: parseValue<int>(json, "ActualWalkinsByCP"),
    performanceWalkinsByCP:
        parseValue<num>(json, "PerformanceWalkinsByCP").toDouble(),

    freshVisits: parseValue<int>(json, "FreshVisits"),
    actualFreshVisits: parseValue<int>(json, "ActualFreshVisits"),
    performanceFreshVisits:
        parseValue<num>(json, "PerformanceFreshVisits").toDouble(),

    revisits: parseValue<int>(json, "Revisits"),
    actualRevisits: parseValue<int>(json, "ActualRevisits"),
    performanceRevisits:
        parseValue<num>(json, "PerformanceRevisits").toDouble(),

    bookings: parseValue<int>(json, "Bookings"),
    actualBookings: parseValue<int>(json, "ActualBookings"),
    performanceBookings:
        parseValue<num>(json, "PerformanceBookings").toDouble(),

    totalMeetings: parseValue<int>(json, "TotalMeetings"),
    actualTotalMeetings: parseValue<int>(json, "ActualTotalMeetings"),
    performanceTotalMeetings:
        parseValue<num>(json, "PerformanceTotalMeetings").toDouble(),

    totalOBM: parseValue<int>(json, "TotalOBM"),
    actualTotalOBM: parseValue<int>(json, "ActualTotalOBM"),
    performanceTotalOBM:
        parseValue<num>(json, "PerformanceTotalOBM").toDouble(),

    totalOBMFreshVisits: parseValue<int>(json, "TotalOBMFreshVisits"),
    actualTotalOBMFreshVisits: parseValue<int>(
      json,
      "ActualTotalOBMFreshVisits",
    ),
    performanceTotalOBMFreshVisits:
        parseValue<num>(json, "PerformanceTotalOBMFreshVisits").toDouble(),

    totalOBMRevisits: parseValue<int>(json, "TotalOBMRevisits"),
    actualTotalOBMRevisits: parseValue<int>(json, "ActualTotalOBMRevisits"),
    performanceTotalOBMRevisits:
        parseValue<num>(json, "PerformanceTotalOBMRevisits").toDouble(),

    totalIBM: parseValue<int>(json, "TotalIBM"),
    actualTotalIBM: parseValue<int>(json, "ActualTotalIBM"),
    performanceTotalIBM:
        parseValue<num>(json, "PerformanceTotalIBM").toDouble(),

    uniqueCPs: parseValue<int>(json, "UniqueCPs"),
    actualUniqueCPs: parseValue<int>(json, "ActualUniqueCPs"),
    performanceUniqueCPs:
        parseValue<num>(json, "PerformanceUniqueCPs").toDouble(),

    activeCP: parseValue<int>(json, "ActiveCP"),
    actualActiveCP: parseValue<int>(json, "ActualActiveCP"),
    performanceActiveCP:
        parseValue<num>(json, "PerformanceActiveCP").toDouble(),

    newCP: parseValue<int>(json, "NewCP"),
    actualNewCP: parseValue<int>(json, "ActualNewCP"),
    performanceNewCP: parseValue<num>(json, "PerformanceNewCP").toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCP,
    "ActualWalkinsByCP": actualWalkinsByCP,
    "PerformanceWalkinsByCP": performanceWalkinsByCP,
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
    "TotalOBM": totalOBM,
    "ActualTotalOBM": actualTotalOBM,
    "PerformanceTotalOBM": performanceTotalOBM,
    "TotalOBMFreshVisits": totalOBMFreshVisits,
    "ActualTotalOBMFreshVisits": actualTotalOBMFreshVisits,
    "PerformanceTotalOBMFreshVisits": performanceTotalOBMFreshVisits,
    "TotalOBMRevisits": totalOBMRevisits,
    "ActualTotalOBMRevisits": actualTotalOBMRevisits,
    "PerformanceTotalOBMRevisits": performanceTotalOBMRevisits,
    "TotalIBM": totalIBM,
    "ActualTotalIBM": actualTotalIBM,
    "PerformanceTotalIBM": performanceTotalIBM,
    "UniqueCPs": uniqueCPs,
    "ActualUniqueCPs": actualUniqueCPs,
    "PerformanceUniqueCPs": performanceUniqueCPs,
    "ActiveCP": activeCP,
    "ActualActiveCP": actualActiveCP,
    "PerformanceActiveCP": performanceActiveCP,
    "NewCP": newCP,
    "ActualNewCP": actualNewCP,
    "PerformanceNewCP": performanceNewCP,
  };
}

class Table3 {
  final int channelPartnerId;
  final String channelPartnerName;
  final String systemGeneratedCode;
  final int walkinsByCP;
  final int revisits;
  final double totalRevenue;
  final int totalBooking;

  Table3({
    required this.channelPartnerId,
    required this.channelPartnerName,
    required this.systemGeneratedCode,
    required this.walkinsByCP,
    required this.revisits,
    required this.totalBooking,
    required this.totalRevenue,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
    channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    walkinsByCP: parseValue<int>(json, "WalkinsByCP"),
    revisits: parseValue<int>(json, "Revisits"),
    totalBooking: parseValue<int>(json, "TotalBooking"),
    totalRevenue: parseValue<num>(json, "TotalRevenue").toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "ChannelPartnerId": channelPartnerId,
    "ChannelPartnerName": channelPartnerName,
    "SystemGeneratedCode": systemGeneratedCode,
    "WalkinsByCP": walkinsByCP,
    "Revisits": revisits,
    "TotalBooking": totalBooking,
    "TotalRevenue": totalRevenue,
  };
}
