import 'package:k3h_erp_app/utils/common_function.dart';

class PayrollDashboardModel {
  final List<PayrollTable0> table0;
  final List<PayrollTable1> table1;
  final List<PayrollTable2> table2;
  final List<PayrollTable3> table3;
  final List<PayrollTable4> table4;
  final List<PayrollTable5> table5;

  PayrollDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
  });

  factory PayrollDashboardModel.fromJson(Map<String, dynamic> json) {
    return PayrollDashboardModel(
      table0:
          (json["Table0"] ?? [])
              .map<PayrollTable0>((x) => PayrollTable0.fromJson(x))
              .toList(),
      table1:
          (json["Table1"] ?? [])
              .map<PayrollTable1>((x) => PayrollTable1.fromJson(x))
              .toList(),
      table2:
          (json["Table2"] ?? [])
              .map<PayrollTable2>((x) => PayrollTable2.fromJson(x))
              .toList(),
      table3:
          (json["Table3"] ?? [])
              .map<PayrollTable3>((x) => PayrollTable3.fromJson(x))
              .toList(),
      table4:
          (json["Table4"] ?? [])
              .map<PayrollTable4>((x) => PayrollTable4.fromJson(x))
              .toList(),
      table5:
          (json["Table5"] ?? [])
              .map<PayrollTable5>((x) => PayrollTable5.fromJson(x))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "Table0": table0.map((x) => x.toJson()).toList(),
    "Table1": table1.map((x) => x.toJson()).toList(),
    "Table2": table2.map((x) => x.toJson()).toList(),
    "Table3": table3.map((x) => x.toJson()).toList(),
    "Table4": table4.map((x) => x.toJson()).toList(),
    "Table5": table5.map((x) => x.toJson()).toList(),
  };
}

class PayrollTable0 {
  final int onLeave;
  final int outdoor;
  final int pendingApproval;
  final int attendanceAlert;

  PayrollTable0({
    required this.onLeave,
    required this.outdoor,
    required this.pendingApproval,
    required this.attendanceAlert,
  });

  factory PayrollTable0.fromJson(Map<String, dynamic> json) {
    return PayrollTable0(
      onLeave: json["OnLeave"] ?? 0,
      outdoor: json["Outdoor"] ?? 0,
      pendingApproval: json["PendingApproval"] ?? 0,
      attendanceAlert: json["AttendanceAlert"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "OnLeave": onLeave,
    "Outdoor": outdoor,
    "PendingApproval": pendingApproval,
    "AttendanceAlert": attendanceAlert,
  };
}

// LEAVES
class PayrollTable1 {
  final String fullName;
  final double noOfDays;
  final DateTime startDate;
  final DateTime endDate;
  final int leaveTypeMasterId;

  PayrollTable1({
    required this.fullName,
    required this.noOfDays,
    required this.startDate,
    required this.endDate,
    required this.leaveTypeMasterId,
  });

  factory PayrollTable1.fromJson(Map<String, dynamic> json) {
    return PayrollTable1(
      fullName: json["FullName"] ?? "",
      noOfDays: (json["NoOfDays"] ?? 0).toDouble(),
      startDate: DateTime.parse(json["StartDate"]),
      endDate: DateTime.parse(json["EndDate"]),
      leaveTypeMasterId: json["LeaveTypeMasterId"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "NoOfDays": noOfDays,
    "StartDate": startDate.toIso8601String(),
    "EndDate": endDate.toIso8601String(),
    "LeaveTypeMasterId": leaveTypeMasterId,
  };
}

// COMP OFF
class PayrollTable2 {
  final DateTime compoffDate;
  final DateTime workingDate;
  final String createdBy;
  final DateTime createdDate;

  PayrollTable2({
    required this.compoffDate,
    required this.workingDate,
    required this.createdBy,
    required this.createdDate,
  });

  factory PayrollTable2.fromJson(Map<String, dynamic> json) {
    return PayrollTable2(
      compoffDate: DateTime.parse(json["CompoffDate"]),
      workingDate: DateTime.parse(json["WorkingDate"]),
      createdBy: json["CreatedBy"] ?? "",
      createdDate: DateTime.parse(json["CreatedDate"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "CompoffDate": compoffDate.toIso8601String(),
    "WorkingDate": workingDate.toIso8601String(),
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
  };
}

// OUTDOOR
class PayrollTable3 {
  final String companyName;
  final String createdBy;
  final DateTime outDoorDate;
  final DateTime outDoorTime;

  PayrollTable3({
    required this.companyName,
    required this.createdBy,
    required this.outDoorDate,
    required this.outDoorTime,
  });

  factory PayrollTable3.fromJson(Map<String, dynamic> json) {
    return PayrollTable3(
      companyName: json["CompanyName"] ?? "",
      createdBy: json["CreatedBy"] ?? "",
      outDoorDate: DateTime.parse(json["OutDoorDate"]),
      outDoorTime: DateTime.parse(json["OutDoorTime"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "CompanyName": companyName,
    "CreatedBy": createdBy,
    "OutDoorDate": outDoorDate.toIso8601String(),
    "OutDoorTime": outDoorTime.toIso8601String(),
  };
}

// RESIGNATION
class PayrollTable4 {
  final String fullName;
  final DateTime expectedRelievingDate;
  final DateTime resignationDate;
  final bool isAnyOfferInHand;

  PayrollTable4({
    required this.fullName,
    required this.expectedRelievingDate,
    required this.resignationDate,
    required this.isAnyOfferInHand,
  });

  factory PayrollTable4.fromJson(Map<String, dynamic> json) {
    return PayrollTable4(
      fullName: json["FullName"] ?? "",
      expectedRelievingDate: DateTime.parse(json["ExpectedRelievingDate"]),
      resignationDate: DateTime.parse(json["ResignationDate"]),
      isAnyOfferInHand: json["IsAnyOfferInHand"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "ExpectedRelievingDate": expectedRelievingDate.toIso8601String(),
    "ResignationDate": resignationDate.toIso8601String(),
    "IsAnyOfferInHand": isAnyOfferInHand,
  };
}

// ATTENDANCE
class PayrollTable5 {
  final int totalEmployees;
  final int presentCount;
  final int onLeaveCount;
  final int absentCount;

  PayrollTable5({
    required this.totalEmployees,
    required this.presentCount,
    required this.onLeaveCount,
    required this.absentCount,
  });

  factory PayrollTable5.fromJson(Map<String, dynamic> json) {
    return PayrollTable5(
      totalEmployees: parseValue<int>(json, "TotalEmployees"),
      presentCount: parseValue<int>(json, "PresentCount"),
      onLeaveCount: parseValue<int>(json, "OnLeaveCount"),
      absentCount: parseValue<int>(json, "AbsentCount"),
    );
  }

  Map<String, dynamic> toJson() => {
    "TotalEmployees": totalEmployees,
    "PresentCount": presentCount,
    "OnLeaveCount": onLeaveCount,
    "AbsentCount": absentCount,
  };
}
