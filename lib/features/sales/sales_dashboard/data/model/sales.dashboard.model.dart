import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/project_achievement_report.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SalesDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<ProjectAchievementReportModel> projectAchievementData;
  final List<Table6> table6;
  final List<Table7> table7;
  final List<Table8> table8;

  SalesDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.projectAchievementData,
    required this.table6,
    required this.table7,
    required this.table8,
  });

  factory SalesDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => SalesDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    projectAchievementData: List<ProjectAchievementReportModel>.from(
      json["Table5"].map((x) => ProjectAchievementReportModel.fromJson(x)),
    ),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
    table7: List<Table7>.from(json["Table7"].map((x) => Table7.fromJson(x))),
    table8: List<Table8>.from(json["Table8"].map((x) => Table8.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(projectAchievementData.map((x) => x.toJson())),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
    "Table7": List<dynamic>.from(table7.map((x) => x.toJson())),
    "Table8": List<dynamic>.from(table8.map((x) => x.toJson())),
  };

  SalesDashboardModel copyWith({
    List<Table0>? table0,
    List<Table1>? table1,
    List<Table2>? table2,
    List<Table3>? table3,
    List<Table4>? table4,
    List<ProjectAchievementReportModel>? projectAchievementData,
    List<Table6>? table6,
    List<Table7>? table7,
    List<Table8>? table8,
  }) {
    return SalesDashboardModel(
      table0: table0 ?? this.table0,
      table1: table1 ?? this.table1,
      table2: table2 ?? this.table2,
      table3: table3 ?? this.table3,
      table4: table4 ?? this.table4,
      projectAchievementData:
          projectAchievementData ?? this.projectAchievementData,
      table6: table6 ?? this.table6,
      table7: table7 ?? this.table7,
      table8: table8 ?? this.table8,
    );
  }
}

class Table0 {
  String systemGeneratedCode;
  String projectName;
  int projectId;
  String name;
  String mobileNumberCountryCode;
  String mobileNumber;
  DateTime enquiryDate;
  String enquiryTimeIn;
  String salesAdvisor;
  String sourcingManager;
  int canTimeOut;
  int enquiryId;

  Table0({
    required this.systemGeneratedCode,
    required this.projectName,
    required this.projectId,
    required this.name,
    required this.mobileNumberCountryCode,
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
    mobileNumberCountryCode: parseValue<String>(
      json,
      "MobileNumberCountryCode",
    ),
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
    "MobileNumberCountryCode": mobileNumberCountryCode,
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
  String systemGeneratedCode;
  String projectName;
  int projectId;
  String name;
  String mobileNumber;
  String mobileNumberCountryCode;
  String enquiryFollowUpDays;
  String finalStage;
  DateTime? nextFollowUpDate;
  String salesAdvisor;
  int isAction;
  String sourcingManager;
  DateTime createdDate;
  int enquiryId;

  Table1({
    required this.systemGeneratedCode,
    required this.projectName,
    required this.projectId,
    required this.name,
    required this.mobileNumber,
    required this.mobileNumberCountryCode,
    required this.enquiryFollowUpDays,
    required this.finalStage,
    required this.nextFollowUpDate,
    required this.salesAdvisor,
    required this.isAction,
    required this.sourcingManager,
    required this.createdDate,
    required this.enquiryId,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    projectName: parseValue<String>(json, "ProjectName"),
    projectId: parseValue<int>(json, "ProjectId"),
    name: parseValue<String>(json, "Name"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    mobileNumberCountryCode: parseValue<String>(
      json,
      "MobileNumberCountryCode",
    ),
    enquiryFollowUpDays: parseValue<String>(json, "EnquiryFollowUpDays"),
    finalStage: parseValue<String>(json, "FinalStage"),
    nextFollowUpDate: parseValue<DateTime>(json, "NextFollowUpDate"),
    salesAdvisor: parseValue<String>(json, "SalesAdvisor"),
    isAction: parseValue<int>(json, "IsAction"),
    sourcingManager: parseValue<String>(json, "SourcingManager"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
  );

  Map<String, dynamic> toJson() => {
    "SystemGeneratedCode": systemGeneratedCode,
    "ProjectName": projectName,
    "ProjectId": projectId,
    "Name": name,
    "MobileNumber": mobileNumber,
    "MobileNumberCountryCode": mobileNumberCountryCode,
    "EnquiryFollowUpDays": enquiryFollowUpDays,
    "FinalStage": finalStage,
    "NextFollowUpDate": nextFollowUpDate?.toIso8601String(),
    "SalesAdvisor": salesAdvisor,
    "IsAction": isAction,
    "SourcingManager": sourcingManager,
    "CreatedDate": createdDate.toIso8601String(),
    "EnquiryId": enquiryId,
  };
}

class Table4 {
  int totalEmployees;
  int presentCount;
  int onLeaveCount;
  int absentCount;

  Table4({
    required this.totalEmployees,
    required this.presentCount,
    required this.onLeaveCount,
    required this.absentCount,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    totalEmployees: parseValue<int>(json, "TotalEmployees"),
    presentCount: parseValue<int>(json, "PresentCount"),
    onLeaveCount: parseValue<int>(json, "OnLeaveCount"),
    absentCount: parseValue<int>(json, "AbsentCount"),
  );

  Map<String, dynamic> toJson() => {
    "TotalEmployees": totalEmployees,
    "PresentCount": presentCount,
    "OnLeaveCount": onLeaveCount,
    "AbsentCount": absentCount,
  };
}

class Table5 {
  int projectId;
  String projectName;
  int totalWalkins;
  int walkinsByCp;
  int walkinsDirect;
  int totalFreshVisits;
  int revisits;
  int bookingByCp;
  int bookingDirect;
  int totalBooking;
  double totalRevenue;
  int totalIbm;
  int totalObm;
  int totalRecords;
  String message;

  Table5({
    required this.projectId,
    required this.projectName,
    required this.totalWalkins,
    required this.walkinsByCp,
    required this.walkinsDirect,
    required this.totalFreshVisits,
    required this.revisits,
    required this.bookingByCp,
    required this.bookingDirect,
    required this.totalBooking,
    required this.totalRevenue,
    required this.totalIbm,
    required this.totalObm,
    required this.totalRecords,
    required this.message,
  });

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    totalWalkins: parseValue<int>(json, "TotalWalkins"),
    walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
    walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
    totalFreshVisits: parseValue<int>(json, "TotalFreshVisits"),
    revisits: parseValue<int>(json, "Revisits"),
    bookingByCp: parseValue<int>(json, "BookingByCP"),
    bookingDirect: parseValue<int>(json, "BookingDirect"),
    totalBooking: parseValue<int>(json, "TotalBooking"),
    totalRevenue: parseValue<double>(json, "TotalRevenue"),
    totalIbm: parseValue<int>(json, "TotalIBM"),
    totalObm: parseValue<int>(json, "TotalOBM"),
    totalRecords: parseValue<int>(json, "TotalRecords"),
    message: parseValue<String>(json, "Message"),
  );

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ProjectName": projectName,
    "TotalWalkins": totalWalkins,
    "WalkinsByCP": walkinsByCp,
    "WalkinsDirect": walkinsDirect,
    "TotalFreshVisits": totalFreshVisits,
    "Revisits": revisits,
    "BookingByCP": bookingByCp,
    "BookingDirect": bookingDirect,
    "TotalBooking": totalBooking,
    "TotalRevenue": totalRevenue,
    "TotalIBM": totalIbm,
    "TotalOBM": totalObm,
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

  Table7({
    required this.name,
    required this.department,
    required this.designationName,
    required this.employeeCode,
    required this.status,
    required this.punchIn,
    required this.punchOut,
    required this.emailId,
  });

  factory Table7.fromJson(Map<String, dynamic> json) => Table7(
    name: parseValue<String>(json, "Name"),
    department: parseValue<String>(json, "Department"),
    designationName: parseValue<String>(json, "DesignationName"),
    employeeCode: parseValue<String>(json, "EmployeeCode"),
    status: parseValue<String>(json, "Status"),
    punchIn: parseValue<String>(json, "PunchIn"),
    punchOut: parseValue<String>(json, "PunchOut"),
    emailId: parseValue<String>(json, "EmailId"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Department": department,
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

class Table4 {
  final int absentCount;
  final int onLeaveCount;
  final int presentCount;
  final int totalEmployees;

  Table4({
    required this.absentCount,
    required this.onLeaveCount,
    required this.presentCount,
    required this.totalEmployees,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    absentCount: parseValue<int>(json, "AbsentCount"),
    onLeaveCount: parseValue<int>(json, "OnLeaveCount"),
    presentCount: parseValue<int>(json, "PresentCount"),
    totalEmployees: parseValue<int>(json, "TotalEmployees"),
  );

  Map<String, dynamic> toJson() => {
    "AbsentCount": absentCount,
    "OnLeaveCount": onLeaveCount,
    "PresentCount": presentCount,
    "TotalEmployees": totalEmployees,
  };
}

class Table6 {
  final String systemGeneratedCode;
  final String applicantName;
  final double agreementValue;
  final DateTime createdDate;
  final String flat;
  final String projectName;
  final String salesAdvisor;
  final String sourcingManager;

  Table6({
    required this.systemGeneratedCode,
    required this.applicantName,
    required this.agreementValue,
    required this.createdDate,
    required this.flat,
    required this.projectName,
    required this.salesAdvisor,
    required this.sourcingManager,
  });

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    agreementValue: parseValue<double>(json, "AgreementValue"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    flat: parseValue<String>(json, "Flat"),
    projectName: parseValue<String>(json, "ProjectName"),
    salesAdvisor: parseValue<String>(json, "SalesAdvisor"),
    sourcingManager: parseValue<String>(json, "SourcingManager"),
  );

  Map<String, dynamic> toJson() => {
    "SystemGeneratedCode": systemGeneratedCode,
    "ApplicantName": applicantName,
    "AgreementValue": agreementValue,
    "CreatedDate": createdDate.toIso8601String(),
    "Flat": flat,
    "ProjectName": projectName,
    "SalesAdvisor": salesAdvisor,
    "SourcingManager": sourcingManager,
  };
}

class Table7 {
  final String name;
  final String department;
  final String designationName;
  final String employeeCode;
  final String status;
  final String punchIn;
  final String punchOut;
  final String emailId;

  Table7({
    required this.name,
    required this.department,
    required this.designationName,
    required this.employeeCode,
    required this.status,
    required this.punchIn,
    required this.punchOut,
    required this.emailId,
  });

  factory Table7.fromJson(Map<String, dynamic> json) => Table7(
    name: parseValue<String>(json, "Name"),
    department: parseValue<String>(json, "Department"),
    designationName: parseValue<String>(json, "DesignationName"),
    employeeCode: parseValue<String>(json, "EmployeeCode"),
    status: parseValue<String>(json, "Status"),
    punchIn: parseValue<String>(json, "PunchIn"),
    punchOut: parseValue<String>(json, "PunchOut"),
    emailId: parseValue<String>(json, "EmailId"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Department": department,
    "DesignationName": designationName,
    "EmployeeCode": employeeCode,
    "Status": status,
    "PunchIn": punchIn,
    "PunchOut": punchOut,
    "EmailId": emailId,
  };
}

class Table8 {
  final double agreementValue;
  final String name;
  final int totalBooking;
  final String department;
  final int totalObm;
  final int walkinsByCp;
  final String profilePhotoUrl;

  Table8({
    required this.agreementValue,
    required this.name,
    required this.totalBooking,
    required this.department,
    required this.totalObm,
    required this.walkinsByCp,
    required this.profilePhotoUrl,
  });

  factory Table8.fromJson(Map<String, dynamic> json) => Table8(
    agreementValue: parseValue<double>(json, "AgreementValue"),
    name: parseValue<String>(json, "Name"),
    totalBooking: parseValue<int>(json, "TotalBooking"),
    department: parseValue<String>(json, "Department"),
    totalObm: parseValue<int>(json, "TotalOBM"),
    walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
    profilePhotoUrl: parseValue<String>(json, "ProfilePhotoUrl"),
  );

  Map<String, dynamic> toJson() => {
    "AgreementValue": agreementValue,
    "Name": name,
    "TotalBooking": totalBooking,
    "Department": department,
    "TotalOBM": totalObm,
    "WalkinsByCP": walkinsByCp,
    "ProfilePhotoUrl": profilePhotoUrl,
  };
}
