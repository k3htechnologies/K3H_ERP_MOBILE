import 'package:k3h_erp_app/utils/common_function.dart';

class SalesDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;

  SalesDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
  });

  factory SalesDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => SalesDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
  };

  SalesDashboardModel copyWith({
    List<Table0>? table0,
    List<Table1>? table1,
    List<Table2>? table2,
    List<Table3>? table3,
  }) {
    return SalesDashboardModel(
      table0: table0 ?? this.table0,
      table1: table1 ?? this.table1,
      table2: table2 ?? this.table2,
      table3: table3 ?? this.table3,
    );
  }
}

class Table0 {
  final String systemGeneratedCode;
  final String projectName;
  final int projectId;
  final String name;
  final String mobileNumber;
  final DateTime enquiryDate;
  final String enquiryTimeIn;
  final String salesAdvisor;
  final String sourcingManager;
  final int canTimeOut;
  final int enquiryId;

  Table0({
    required this.systemGeneratedCode,
    required this.projectName,
    required this.projectId,
    required this.name,
    required this.mobileNumber,
    required this.enquiryDate,
    required this.enquiryTimeIn,
    required this.salesAdvisor,
    required this.sourcingManager,
    required this.canTimeOut,
    required this.enquiryId,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    projectName: parseValue<String>(json, "ProjectName"),
    projectId: parseValue<int>(json, "ProjectId"),
    name: parseValue<String>(json, "Name"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    enquiryDate: parseValue<DateTime>(json, "EnquiryDate"),
    enquiryTimeIn: parseValue<String>(json, "EnquiryTimeIn"),
    salesAdvisor: parseValue<String>(json, "SalesAdvisor"),
    sourcingManager: parseValue<String>(json, "SourcingManager"),
    canTimeOut: parseValue<int>(json, "CanTimeOut"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
  );

  Map<String, dynamic> toJson() => {
    "SystemGeneratedCode": systemGeneratedCode,
    "ProjectName": projectName,
    "ProjectId": projectId,
    "Name": name,
    "MobileNumber": mobileNumber,
    "EnquiryDate": enquiryDate.toIso8601String(),
    "EnquiryTimeIn": enquiryTimeIn,
    "SalesAdvisor": salesAdvisor,
    "SourcingManager": sourcingManager,
    "CanTimeOut": canTimeOut,
    "EnquiryId": enquiryId,
  };
}

class Table1 {
  final String systemGeneratedCode;
  final String projectName;
  final String name;
  final String mobileNumber;
  final String enquiryFollowUpDays;
  final String finalStage;
  final DateTime? nextFollowUpDate;
  final String salesAdvisor;
  final String sourcingManager;
  final DateTime createdDate;
  final int enquiryId;

  Table1({
    required this.systemGeneratedCode,
    required this.projectName,
    required this.name,
    required this.mobileNumber,
    required this.enquiryFollowUpDays,
    required this.finalStage,
    required this.nextFollowUpDate,
    required this.salesAdvisor,
    required this.sourcingManager,
    required this.createdDate,
    required this.enquiryId,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    projectName: parseValue<String>(json, "ProjectName"),
    name: parseValue<String>(json, "Name"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    enquiryFollowUpDays: parseValue<String>(json, "EnquiryFollowUpDays"),
    finalStage: parseValue<String>(json, "FinalStage"),
    nextFollowUpDate:
        (json["NextFollowUpDate"].isEmpty ?? false)
            ? null
            : parseValue<DateTime>(json, "NextFollowUpDate"),
    salesAdvisor: parseValue<String>(json, "SalesAdvisor"),
    sourcingManager: parseValue<String>(json, "SourcingManager"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
  );

  Map<String, dynamic> toJson() => {
    "SystemGeneratedCode": systemGeneratedCode,
    "ProjectName": projectName,
    "Name": name,
    "MobileNumber": mobileNumber,
    "EnquiryFollowUpDays": enquiryFollowUpDays,
    "FinalStage": finalStage,
    "NextFollowUpDate": nextFollowUpDate?.toIso8601String(),
    "SalesAdvisor": salesAdvisor,
    "SourcingManager": sourcingManager,
    "CreatedDate": createdDate.toIso8601String(),
    "EnquiryId": enquiryId,
  };
}

class Table2 {
  final int employeeId;
  final String employeeName;
  final String designationName;
  final int walkinsByCp;
  final int actualWalkinsByCp;
  final double performanceWalkinsByCp;
  final int walkinsDirect;
  final int actualWalkinsDirect;
  final double performanceWalkinsDirect;
  final int freshVisits;
  final int actualFreshVisits;
  final double performanceFreshVisits;
  final int revisits;
  final int actualRevisits;
  final double performanceRevisits;
  final int bookingByCp;
  final int actualBookingByCp;
  final int performanceBookingByCp;
  final int bookingDirect;
  final int actualBookingDirect;
  final double performanceBookingDirect;
  final int totalRecords;
  final String message;

  Table2({
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
    required this.totalRecords,
    required this.message,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    designationName: parseValue<String>(json, "DesignationName"),
    walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
    actualWalkinsByCp: parseValue<int>(json, "ActualWalkinsByCP"),
    performanceWalkinsByCp: parseValue<double>(json, "PerformanceWalkinsByCP"),
    walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
    actualWalkinsDirect: parseValue<int>(json, "ActualWalkinsDirect"),
    performanceWalkinsDirect: parseValue<double>(
      json,
      "PerformanceWalkinsDirect",
    ),
    freshVisits: parseValue<int>(json, "FreshVisits"),
    actualFreshVisits: parseValue<int>(json, "ActualFreshVisits"),
    performanceFreshVisits: parseValue<double>(json, "PerformanceFreshVisits"),
    revisits: parseValue<int>(json, "Revisits"),
    actualRevisits: parseValue<int>(json, "ActualRevisits"),
    performanceRevisits: parseValue<double>(json, "PerformanceRevisits"),
    bookingByCp: parseValue<int>(json, "BookingByCP"),
    actualBookingByCp: parseValue<int>(json, "ActualBookingByCP"),
    performanceBookingByCp: parseValue<int>(json, "PerformanceBookingByCP"),
    bookingDirect: parseValue<int>(json, "BookingDirect"),
    actualBookingDirect: parseValue<int>(json, "ActualBookingDirect"),
    performanceBookingDirect: parseValue<double>(
      json,
      "PerformanceBookingDirect",
    ),
    totalRecords: parseValue<int>(json, "TotalRecords"),
    message: parseValue<String>(json, "Message"),
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
    "TotalRecords": totalRecords,
    "Message": message,
  };
}

class Table3 {
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

  final int totalRecords;
  final String message;

  Table3({
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
    required this.totalRecords,
    required this.message,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    employeeId: parseValue<int>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    designationName: parseValue<String>(json, "DesignationName"),

    walkinsByCP: parseValue<int>(json, "WalkinsByCP"),
    actualWalkinsByCP: parseValue<int>(json, "ActualWalkinsByCP"),
    performanceWalkinsByCP: parseValue<double>(json, "PerformanceWalkinsByCP"),

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

    totalOBM: parseValue<int>(json, "TotalOBM"),
    actualTotalOBM: parseValue<int>(json, "ActualTotalOBM"),
    performanceTotalOBM: parseValue<double>(json, "PerformanceTotalOBM"),

    totalOBMFreshVisits: parseValue<int>(json, "TotalOBMFreshVisits"),
    actualTotalOBMFreshVisits: parseValue<int>(
      json,
      "ActualTotalOBMFreshVisits",
    ),
    performanceTotalOBMFreshVisits: parseValue<double>(
      json,
      "PerformanceTotalOBMFreshVisits",
    ),

    totalOBMRevisits: parseValue<int>(json, "TotalOBMRevisits"),
    actualTotalOBMRevisits: parseValue<int>(json, "ActualTotalOBMRevisits"),
    performanceTotalOBMRevisits: parseValue<double>(
      json,
      "PerformanceTotalOBMRevisits",
    ),

    totalIBM: parseValue<int>(json, "TotalIBM"),
    actualTotalIBM: parseValue<int>(json, "ActualTotalIBM"),
    performanceTotalIBM: parseValue<double>(json, "PerformanceTotalIBM"),

    uniqueCPs: parseValue<int>(json, "UniqueCPs"),
    actualUniqueCPs: parseValue<int>(json, "ActualUniqueCPs"),
    performanceUniqueCPs:
        parseValue<num>(json, "PerformanceUniqueCPs").toDouble(),

    activeCP: parseValue<int>(json, "ActiveCP"),
    actualActiveCP: parseValue<int>(json, "ActualActiveCP"),
    performanceActiveCP: parseValue<double>(json, "PerformanceActiveCP"),

    newCP: parseValue<int>(json, "NewCP"),
    actualNewCP: parseValue<int>(json, "ActualNewCP"),
    performanceNewCP: parseValue<double>(json, "PerformanceNewCP"),

    totalRecords: parseValue<int>(json, "TotalRecords"),
    message: parseValue<String>(json, "Message"),
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
    "TotalRecords": totalRecords,
    "Message": message,
  };
}
