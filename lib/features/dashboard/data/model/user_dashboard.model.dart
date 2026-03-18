import 'package:k3h_erp_app/utils/common_function.dart';

class UserDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<Table5> table5;
  final List<Table6> table6;
  final List<Table7> table7;
  final List<Table8> table8;
  final List<dynamic> table9;
  final List<Table10> table10;
  final List<Table11> table11;
  UserDashboardModel({
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
    required this.table10,
    required this.table11,
  });

  factory UserDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => UserDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<Table5>.from(json["Table5"].map((x) => Table5.fromJson(x))),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
    table7: List<Table7>.from(json["Table7"].map((x) => Table7.fromJson(x))),
    table8: List<Table8>.from(json["Table8"].map((x) => Table8.fromJson(x))),
    table9: List<dynamic>.from(json["Table9"].map((x) => x)),
    table10: List<Table10>.from(
      json["Table10"].map((x) => Table10.fromJson(x)),
    ),
    table11: List<Table11>.from(
      json["Table11"].map((x) => Table11.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x.toJson())),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
    "Table7": List<dynamic>.from(table7.map((x) => x.toJson())),
    "Table8": List<dynamic>.from(table8.map((x) => x.toJson())),
    "Table9": List<dynamic>.from(table9.map((x) => x)),
    "Table10": List<dynamic>.from(table10.map((x) => x.toJson())),
    "Table11": List<dynamic>.from(table11.map((x) => x.toJson())),
  };
}

class Table0 {
  final String name;
  final String department;
  final String employeeCode;
  final String status;
  final String punchIn;
  final String punchOut;

  Table0({
    required this.name,
    required this.department,
    required this.employeeCode,
    required this.status,
    required this.punchIn,
    required this.punchOut,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    name: parseValue<String>(json, "Name"),
    department: parseValue<String>(json, "Department"),
    employeeCode: parseValue<String>(json, "EmployeeCode"),
    status: parseValue<String>(json, "Status"),
    punchIn: parseValue<String>(json, "PunchIn"),
    punchOut: parseValue<String>(json, "PunchOut"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Department": department,
    "EmployeeCode": employeeCode,
    "Status": status,
    "PunchIn": punchIn,
    "PunchOut": punchOut,
  };
}

class Table1 {
  final num presentDays;
  final String avgLoginTime;
  final String shiftStartTime;
  final String shiftEndTime;
  final String shiftPattern;
  final String message;

  Table1({
    required this.presentDays,
    required this.avgLoginTime,
    required this.shiftStartTime,
    required this.shiftEndTime,
    required this.shiftPattern,
    required this.message,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    presentDays: parseValue<num>(json, "PresentDays"),
    avgLoginTime: parseValue<String>(json, "AvgLoginTime"),
    shiftStartTime: parseValue<String>(json, "ShiftStartTime"),
    shiftEndTime: parseValue<String>(json, "ShiftEndTime"),
    shiftPattern: parseValue<String>(json, "ShiftPattern"),
    message: parseValue<String>(json, "Message"),
  );

  Map<String, dynamic> toJson() => {
    "PresentDays": presentDays,
    "AvgLoginTime": avgLoginTime,
    "ShiftStartTime": shiftStartTime,
    "ShiftEndTime": shiftEndTime,
    "ShiftPattern": shiftPattern,
    "Message": message,
  };
}

class Table2 {
  final double thisMonthHours;
  final double thisWeekHours;
  final double overtimeHours;
  final double avgDailyHours;
  final String message;

  Table2({
    required this.thisMonthHours,
    required this.thisWeekHours,
    required this.overtimeHours,
    required this.avgDailyHours,
    required this.message,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    thisMonthHours: parseValue<double>(json, "ThisMonthHours").toDouble(),
    thisWeekHours: parseValue<double>(json, "ThisWeekHours").toDouble(),
    overtimeHours: parseValue<double>(json, "OvertimeHours").toDouble(),
    avgDailyHours: parseValue<double>(json, "AvgDailyHours").toDouble(),
    message: parseValue<String>(json, "Message"),
  );

  Map<String, dynamic> toJson() => {
    "ThisMonthHours": thisMonthHours,
    "ThisWeekHours": thisWeekHours,
    "OvertimeHours": overtimeHours,
    "AvgDailyHours": avgDailyHours,
    "Message": message,
  };
}

class Table3 {
  final DateTime date;
  final String dayName;
  final DateTime punchIn;
  final DateTime punchOut;
  final String workingHours;
  final String status;
  final String hoursWorked;
  final int requiredHours;
  final String message;

  Table3({
    required this.date,
    required this.dayName,
    required this.punchIn,
    required this.punchOut,
    required this.workingHours,
    required this.status,
    required this.hoursWorked,
    required this.requiredHours,
    required this.message,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    date: parseValue<DateTime>(json, "Date"),
    dayName: parseValue<String>(json, "DayName"),
    punchIn: parseValue<DateTime>(json, "PunchIn"),
    punchOut: parseValue<DateTime>(json, "PunchOut"),
    workingHours: parseValue<String>(json, "WorkingHours"),
    status: parseValue<String>(json, "Status"),
    hoursWorked: parseValue<String>(json, "HoursWorked"),
    requiredHours: 9,
    message: parseValue(json, "Message"),
  );

  Map<String, dynamic> toJson() => {
    "Date": date.toIso8601String(),
    "DayName": dayName,
    "PunchIn": punchIn.toIso8601String(),
    "PunchOut": punchOut.toIso8601String(),
    "WorkingHours": workingHours,
    "Status": status,
    "HoursWorked": hoursWorked,
    "RequiredHours": requiredHours,
    "Message": message,
  };
}

class Table4 {
  final double totalLeaves;
  final double usedLeaves;
  final double pendingLeaves;
  final String leaveTypeName;
  final int leaveTypeMasterId;
  final String message;

  Table4({
    required this.totalLeaves,
    required this.usedLeaves,
    required this.pendingLeaves,
    required this.leaveTypeName,
    required this.leaveTypeMasterId,
    required this.message,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    totalLeaves: parseValue<double>(json, "TotalLeaves").toDouble(),
    usedLeaves: parseValue<double>(json, "UsedLeaves").toDouble(),
    pendingLeaves: parseValue<double>(json, "PendingLeaves").toDouble(),
    leaveTypeName: parseValue<String>(json, "LeaveTypeName"),
    leaveTypeMasterId: parseValue<int>(json, "LeaveTypeMasterId"),
    message: parseValue<String>(json, "Message"),
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

class Table5 {
  final int leaveId;
  final DateTime startDate;
  final DateTime endDate;
  final double noOfDays;
  final String leaveTypeName;
  final String reason;
  final String message;

  Table5({
    required this.leaveId,
    required this.startDate,
    required this.endDate,
    required this.noOfDays,
    required this.leaveTypeName,
    required this.reason,
    required this.message,
  });

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
    leaveId: parseValue<int>(json, "LeaveId"),
    startDate: parseValue<DateTime>(json, "StartDate"),
    endDate: parseValue<DateTime>(json, "EndDate"),
    noOfDays: parseValue<double>(json, "NoOfDays").toDouble(),
    leaveTypeName: parseValue<String>(json, "LeaveTypeName"),
    reason: parseValue<String>(json, "Reason"),
    message: parseValue<String>(json, "Message"),
  );

  Map<String, dynamic> toJson() => {
    "LeaveId": leaveId,
    "StartDate": startDate.toIso8601String(),
    "EndDate": endDate.toIso8601String(),
    "NoOfDays": noOfDays,
    "LeaveTypeName": leaveTypeName,
    "Reason": reason,
    "Message": message,
  };
}

class Table6 {
  final int holidayMasterId;
  final String holidayName;
  final DateTime holidayDate;
  final int daysRemaining;
  final String dayName;

  Table6({
    required this.holidayMasterId,
    required this.holidayName,
    required this.holidayDate,
    required this.daysRemaining,
    required this.dayName,
  });

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    holidayMasterId: parseValue<int>(json, "HolidayMasterId"),
    holidayName: parseValue<String>(json, "HolidayName"),
    holidayDate: parseValue<DateTime>(json, "HolidayDate"),
    daysRemaining: parseValue<int>(json, "DaysRemaining"),
    dayName: json["DayName"],
  );

  Map<String, dynamic> toJson() => {
    "HolidayMasterId": holidayMasterId,
    "HolidayName": holidayName,
    "HolidayDate": holidayDate.toIso8601String(),
    "DaysRemaining": daysRemaining,
    "DayName": dayName,
  };
}

class Table7 {
  final int totalEmployees;
  final int presentCount;
  final int onLeaveCount;
  final int absentCount;
  final String message;

  Table7({
    required this.totalEmployees,
    required this.presentCount,
    required this.onLeaveCount,
    required this.absentCount,
    required this.message,
  });

  factory Table7.fromJson(Map<String, dynamic> json) => Table7(
    totalEmployees: parseValue<int>(json, "TotalEmployees"),
    presentCount: parseValue<int>(json, "PresentCount"),
    onLeaveCount: parseValue<int>(json, "OnLeaveCount"),
    absentCount: parseValue<int>(json, "AbsentCount"),
    message: parseValue(json, "Message"),
  );

  Map<String, dynamic> toJson() => {
    "TotalEmployees": totalEmployees,
    "PresentCount": presentCount,
    "OnLeaveCount": onLeaveCount,
    "AbsentCount": absentCount,
    "Message": message,
  };
}

class Table8 {
  final int employeeId;
  final String fullName;
  final DateTime dateOfBirth;
  final String departmentName;
  final int birthDay;
  final int birthMonth;
  final int daysUntilBirthday;

  Table8({
    required this.employeeId,
    required this.fullName,
    required this.dateOfBirth,
    required this.departmentName,
    required this.birthDay,
    required this.birthMonth,
    required this.daysUntilBirthday,
  });

  factory Table8.fromJson(Map<String, dynamic> json) => Table8(
    employeeId: parseValue<int>(json, "EmployeeId"),
    fullName: parseValue<String>(json, "FullName"),
    dateOfBirth: parseValue<DateTime>(json, "DateOfBirth"),
    departmentName: parseValue<String>(json, "DepartmentName"),
    birthDay: parseValue<int>(json, "BirthDay"),
    birthMonth: parseValue<int>(json, "BirthMonth"),
    daysUntilBirthday: parseValue<int>(json, "DaysUntilBirthday"),
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "FullName": fullName,
    "DateOfBirth": dateOfBirth.toIso8601String(),
    "DepartmentName": departmentName,
    "BirthDay": birthDay,
    "BirthMonth": birthMonth,
    "DaysUntilBirthday": daysUntilBirthday,
  };
}

class Table10 {
  final int managerId;
  final String managerName;
  final String managerEmail;
  final String managerPhone;
  final String departmentName;
  final String designationName;

  Table10({
    required this.managerId,
    required this.managerName,
    required this.managerEmail,
    required this.managerPhone,
    required this.departmentName,
    required this.designationName,
  });

  factory Table10.fromJson(Map<String, dynamic> json) => Table10(
    managerId: parseValue<int>(json, "ManagerId"),
    managerName: parseValue<String>(json, "ManagerName"),
    managerEmail: parseValue<String>(json, "ManagerEmail"),
    managerPhone: parseValue<String>(json, "ManagerPhone"),
    departmentName: parseValue<String>(json, "DepartmentName"),
    designationName: parseValue<String>(json, "DesignationName"),
  );

  Map<String, dynamic> toJson() => {
    "ManagerId": managerId,
    "ManagerName": managerName,
    "ManagerEmail": managerEmail,
    "ManagerPhone": managerPhone,
    "DepartmentName": departmentName,
    "DesignationName": designationName,
  };
}

class Table11 {
  final DateTime? punchOut;
  final DateTime? punchIn;
  final String punchInAddress;
  final String punchOutAddress;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final double distance;
  final String polyline;

  Table11({
    this.punchOut,
    this.punchIn,
    required this.punchInAddress,
    required this.punchOutAddress,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.distance,
    required this.polyline,
  });

  factory Table11.fromJson(Map<String, dynamic> json) => Table11(
    punchOut: parseApiDate(json["PunchOut"]),
    punchIn: parseApiDate(json["PunchIn"]),
    punchInAddress: parseValue<String>(json, "PunchInAddress"),
    punchOutAddress: parseValue<String>(json, "PunchOutAddress"),
    startLatitude: parseValue<double>(json, "StartLatitude").toDouble(),
    startLongitude: parseValue<double>(json, "StartLongitude").toDouble(),
    endLatitude: parseValue<double>(json, "EndLatitude").toDouble(),
    endLongitude: parseValue<double>(json, "EndLongitude").toDouble(),
    distance: parseValue<double>(json, "Distance").toDouble(),
    polyline: parseValue<String>(json, "Polyline"),
  );

  Map<String, dynamic> toJson() => {
    "PunchOut": punchOut?.toIso8601String(),
    "PunchIn": punchIn?.toIso8601String(),
    "PunchInAddress": punchInAddress,
    "PunchOutAddress": punchOutAddress,
    "StartLatitude": startLatitude,
    "StartLongitude": startLongitude,
    "EndLatitude": endLatitude,
    "EndLongitude": endLongitude,
    "Distance": distance,
    "Polyline": polyline,
  };
}
