// To parse this JSON data, do
//
//     final userDashboardModel = userDashboardModelFromJson(jsonString);

import 'dart:convert';

UserDashboardModel userDashboardModelFromJson(String str) =>
    UserDashboardModel.fromJson(json.decode(str));

String userDashboardModelToJson(UserDashboardModel data) =>
    json.encode(data.toJson());

class UserDashboardModel {
  final List<String> successMessage;
  final List<dynamic> errorMessage;
  final List<dynamic> warningMessage;
  final Data data;
  final bool isSuccess;
  final int totalNumberOfRecord;
  final int httpStatusCode;

  UserDashboardModel({
    required this.successMessage,
    required this.errorMessage,
    required this.warningMessage,
    required this.data,
    required this.isSuccess,
    required this.totalNumberOfRecord,
    required this.httpStatusCode,
  });

  factory UserDashboardModel.fromJson(Map<String, dynamic> json) =>
      UserDashboardModel(
        successMessage: List<String>.from(json["SuccessMessage"].map((x) => x)),
        errorMessage: List<dynamic>.from(json["ErrorMessage"].map((x) => x)),
        warningMessage: List<dynamic>.from(
          json["WarningMessage"].map((x) => x),
        ),
        data: Data.fromJson(json["Data"]),
        isSuccess: json["IsSuccess"],
        totalNumberOfRecord: json["TotalNumberOfRecord"],
        httpStatusCode: json["HttpStatusCode"],
      );

  Map<String, dynamic> toJson() => {
    "SuccessMessage": List<dynamic>.from(successMessage.map((x) => x)),
    "ErrorMessage": List<dynamic>.from(errorMessage.map((x) => x)),
    "WarningMessage": List<dynamic>.from(warningMessage.map((x) => x)),
    "Data": data.toJson(),
    "IsSuccess": isSuccess,
    "TotalNumberOfRecord": totalNumberOfRecord,
    "HttpStatusCode": httpStatusCode,
  };
}

class Data {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<dynamic> table5;
  final List<Table6> table6;
  final List<dynamic> table7;
  final List<dynamic> table8;
  final List<Table9> table9;

  Data({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
    required this.table7,
    required this.table8,
    required this.table9,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<dynamic>.from(json["Table5"].map((x) => x)),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
    table7: List<dynamic>.from(json["Table7"].map((x) => x)),
    table8: List<dynamic>.from(json["Table8"].map((x) => x)),
    table9: List<Table9>.from(json["Table9"].map((x) => Table9.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x)),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
    "Table7": List<dynamic>.from(table7.map((x) => x)),
    "Table8": List<dynamic>.from(table8.map((x) => x)),
    "Table9": List<dynamic>.from(table9.map((x) => x.toJson())),
  };
}

class Table0 {
  final String attendanceDate;
  final String fullName;
  final String attendanceStatus;

  Table0({
    required this.attendanceDate,
    required this.fullName,
    required this.attendanceStatus,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    attendanceDate: json["AttendanceDate"],
    fullName: json["FullName"],
    attendanceStatus: json["AttendanceStatus"],
  );

  Map<String, dynamic> toJson() => {
    "AttendanceDate": attendanceDate,
    "FullName": fullName,
    "AttendanceStatus": attendanceStatus,
  };
}

class Table1 {
  final String shift;
  final String shiftBeginTime;
  final String shiftEndTime;
  final String avgWorkingHours;

  Table1({
    required this.shift,
    required this.shiftBeginTime,
    required this.shiftEndTime,
    required this.avgWorkingHours,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    shift: json["Shift"],
    shiftBeginTime: json["ShiftBeginTime"],
    shiftEndTime: json["ShiftEndTime"],
    avgWorkingHours: json["AvgWorkingHours"],
  );

  Map<String, dynamic> toJson() => {
    "Shift": shift,
    "ShiftBeginTime": shiftBeginTime,
    "ShiftEndTime": shiftEndTime,
    "AvgWorkingHours": avgWorkingHours,
  };
}

class Table2 {
  final AvgDailyHours thisWeekHours;
  final AvgDailyHours overtimeHours;
  final AvgDailyHours avgDailyHours;
  final String message;

  Table2({
    required this.thisWeekHours,
    required this.overtimeHours,
    required this.avgDailyHours,
    required this.message,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    thisWeekHours: AvgDailyHours.fromJson(json["ThisWeekHours"]),
    overtimeHours: AvgDailyHours.fromJson(json["OvertimeHours"]),
    avgDailyHours: AvgDailyHours.fromJson(json["AvgDailyHours"]),
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "ThisWeekHours": thisWeekHours.toJson(),
    "OvertimeHours": overtimeHours.toJson(),
    "AvgDailyHours": avgDailyHours.toJson(),
    "Message": message,
  };
}

class AvgDailyHours {
  AvgDailyHours();

  factory AvgDailyHours.fromJson(Map<String, dynamic> json) => AvgDailyHours();

  Map<String, dynamic> toJson() => {};
}

class Table3 {
  final double totalLeaves;
  final double usedLeaves;
  final int pendingLeaves;
  final String leaveTypeName;
  final int leaveTypeMasterId;
  final String message;

  Table3({
    required this.totalLeaves,
    required this.usedLeaves,
    required this.pendingLeaves,
    required this.leaveTypeName,
    required this.leaveTypeMasterId,
    required this.message,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    totalLeaves: json["TotalLeaves"]?.toDouble(),
    usedLeaves: json["UsedLeaves"]?.toDouble(),
    pendingLeaves: json["PendingLeaves"],
    leaveTypeName: json["LeaveTypeName"],
    leaveTypeMasterId: json["LeaveTypeMasterId"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "TotalLeaves": totalLeaves,
    "UsedLeaves": usedLeaves,
    "PendingLeaves": pendingLeaves,
    "LeaveTypeName": leaveTypeName,
    "LeaveTypeMasterId": leaveTypeMasterId,
    "Message": message,
  };
}

class Table4 {
  final int leaveId;
  final String startDate;
  final String endDate;
  final double noOfDays;
  final String leaveTypeName;
  final String reason;
  final String message;

  Table4({
    required this.leaveId,
    required this.startDate,
    required this.endDate,
    required this.noOfDays,
    required this.leaveTypeName,
    required this.reason,
    required this.message,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    leaveId: json["LeaveId"],
    startDate: json["StartDate"],
    endDate: json["EndDate"],
    noOfDays: json["NoOfDays"]?.toDouble(),
    leaveTypeName: json["LeaveTypeName"],
    reason: json["Reason"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "LeaveId": leaveId,
    "StartDate": startDate,
    "EndDate": endDate,
    "NoOfDays": noOfDays,
    "LeaveTypeName": leaveTypeName,
    "Reason": reason,
    "Message": message,
  };
}

class Table6 {
  final int totalEmployees;
  final int presentCount;
  final int onLeaveCount;
  final int absentCount;
  final String message;

  Table6({
    required this.totalEmployees,
    required this.presentCount,
    required this.onLeaveCount,
    required this.absentCount,
    required this.message,
  });

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    totalEmployees: json["TotalEmployees"],
    presentCount: json["PresentCount"],
    onLeaveCount: json["OnLeaveCount"],
    absentCount: json["AbsentCount"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "TotalEmployees": totalEmployees,
    "PresentCount": presentCount,
    "OnLeaveCount": onLeaveCount,
    "AbsentCount": absentCount,
    "Message": message,
  };
}

class Table9 {
  final AvgDailyHours managerId;
  final AvgDailyHours managerName;
  final AvgDailyHours managerEmail;
  final AvgDailyHours managerPhone;
  final AvgDailyHours departmentName;
  final AvgDailyHours designationName;
  final String message;

  Table9({
    required this.managerId,
    required this.managerName,
    required this.managerEmail,
    required this.managerPhone,
    required this.departmentName,
    required this.designationName,
    required this.message,
  });

  factory Table9.fromJson(Map<String, dynamic> json) => Table9(
    managerId: AvgDailyHours.fromJson(json["ManagerId"]),
    managerName: AvgDailyHours.fromJson(json["ManagerName"]),
    managerEmail: AvgDailyHours.fromJson(json["ManagerEmail"]),
    managerPhone: AvgDailyHours.fromJson(json["ManagerPhone"]),
    departmentName: AvgDailyHours.fromJson(json["DepartmentName"]),
    designationName: AvgDailyHours.fromJson(json["DesignationName"]),
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "ManagerId": managerId.toJson(),
    "ManagerName": managerName.toJson(),
    "ManagerEmail": managerEmail.toJson(),
    "ManagerPhone": managerPhone.toJson(),
    "DepartmentName": departmentName.toJson(),
    "DesignationName": designationName.toJson(),
    "Message": message,
  };
}
