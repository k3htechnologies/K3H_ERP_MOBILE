import 'package:k3h_erp_app/utils/common_function.dart';

class PayrollDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<Table5> table5;
  final List<Table6> table6;

  PayrollDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
  });

  factory PayrollDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => PayrollDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<Table5>.from(json["Table5"].map((x) => Table5.fromJson(x))),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x.toJson())),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
  };
}

class Table0 {
  final int onLeave;
  final int outdoor;
  final int pendingApproval;
  final int attendanceAlert;

  Table0({
    required this.onLeave,
    required this.outdoor,
    required this.pendingApproval,
    required this.attendanceAlert,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    onLeave: parseValue<int>(json, "OnLeave"),
    outdoor: parseValue<int>(json, "Outdoor"),
    pendingApproval: parseValue<int>(json, "PendingApproval"),
    attendanceAlert: parseValue<int>(json, "AttendanceAlert"),
  );

  Map<String, dynamic> toJson() => {
    "OnLeave": onLeave,
    "Outdoor": outdoor,
    "PendingApproval": pendingApproval,
    "AttendanceAlert": attendanceAlert,
  };
}

class Table1 {
  final String fullName;
  final double noOfDays;
  final DateTime startDate;
  final DateTime endDate;
  final int leaveTypeMasterId;
  final String leaveType;
  final String status;
  final int canApprove;

  Table1({
    required this.fullName,
    required this.noOfDays,
    required this.startDate,
    required this.endDate,
    required this.leaveTypeMasterId,
    required this.leaveType,
    required this.status,
    required this.canApprove,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    fullName: parseValue<String>(json, "FullName"),
    noOfDays: parseValue<double>(json, "NoOfDays").toDouble(),
    startDate: parseValue<DateTime>(json, "StartDate"),
    endDate: parseValue<DateTime>(json, "EndDate"),
    leaveTypeMasterId: parseValue<int>(json, "LeaveTypeMasterId"),
    leaveType: parseValue<String>(json, "LeaveType"),
    status: parseValue<String>(json, "Status"),
    canApprove: parseValue<int>(json, "CanApprove"),
  );

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "NoOfDays": noOfDays,
    "StartDate": startDate.toIso8601String(),
    "EndDate": endDate.toIso8601String(),
    "LeaveTypeMasterId": leaveTypeMasterId,
    "LeaveType": leaveType,
    "Status": status,
    "CanApprove": canApprove,
  };
}

class Table2 {
  final DateTime compoffDate;
  final DateTime workingDate;
  final String createdBy;
  final String createdDate;
  final String status;

  Table2({
    required this.compoffDate,
    required this.workingDate,
    required this.createdBy,
    required this.createdDate,
    required this.status,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    compoffDate: parseValue<DateTime>(json, "CompoffDate"),
    workingDate: parseValue<DateTime>(json, "WorkingDate"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: json["CreatedDate"],
    status: parseValue<String>(json, "Status"),
  );

  Map<String, dynamic> toJson() => {
    "CompoffDate": compoffDate.toIso8601String(),
    "WorkingDate": workingDate.toIso8601String(),
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "Status": status,
  };
}

class Table3 {
  final String companyName;
  final String createdBy;
  final DateTime outDoorDate;
  final DateTime outDoorTime;

  Table3({
    required this.companyName,
    required this.createdBy,
    required this.outDoorDate,
    required this.outDoorTime,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    companyName: parseValue<String>(json, "CompanyName"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    outDoorDate: parseValue<DateTime>(json, "OutDoorDate"),
    outDoorTime: parseValue<DateTime>(json, "OutDoorTime"),
  );

  Map<String, dynamic> toJson() => {
    "CompanyName": companyName,
    "CreatedBy": createdBy,
    "OutDoorDate": outDoorDate.toIso8601String(),
    "OutDoorTime": outDoorTime.toIso8601String(),
  };
}

class Table4 {
  final String fullName;

  final DateTime expectedRelievingDate;
  final DateTime resignationDate;
  final bool isAnyOfferInHand;

  Table4({
    required this.fullName,
    required this.expectedRelievingDate,
    required this.resignationDate,
    required this.isAnyOfferInHand,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    fullName: parseValue<String>(json, "FullName"),
    expectedRelievingDate: parseValue<DateTime>(json, "ExpectedRelievingDate"),
    resignationDate: parseValue<DateTime>(json, "ResignationDate"),
    isAnyOfferInHand: parseValue<bool>(json, "IsAnyOfferInHand"),
  );

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "ExpectedRelievingDate": expectedRelievingDate.toIso8601String(),
    "ResignationDate": resignationDate.toIso8601String(),
    "IsAnyOfferInHand": isAnyOfferInHand,
  };
}

class Table5 {
  final int totalEmployees;
  final int presentCount;
  final int onLeaveCount;
  final int absentCount;

  Table5({
    required this.totalEmployees,
    required this.presentCount,
    required this.onLeaveCount,
    required this.absentCount,
  });

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
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

class Table6 {
  final DateTime attendanceDate;
  final String fullName;
  final String attendanceStatus;

  Table6({
    required this.attendanceDate,
    required this.fullName,
    required this.attendanceStatus,
  });

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    attendanceDate: parseValue<DateTime>(json, "AttendanceDate"),
    fullName: parseValue<String>(json, "FullName"),
    attendanceStatus: parseValue<String>(json, "AttendanceStatus"),
  );

  Map<String, dynamic> toJson() => {
    "AttendanceDate": attendanceDate.toIso8601String(),
    "FullName": fullName,
    "AttendanceStatus": attendanceStatus,
  };
}
