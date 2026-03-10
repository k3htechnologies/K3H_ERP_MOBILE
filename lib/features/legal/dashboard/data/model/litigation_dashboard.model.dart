import 'package:k3h_erp_app/utils/common_function.dart';

class LitigationDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<Table5> table5;
  final List<Table6> table6;

  LitigationDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
  });

  factory LitigationDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => LitigationDashboardModel(
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
  final int totalCases;
  final int openCases;
  final int closedCases;
  final int reOpenCases;

  Table0({
    required this.totalCases,
    required this.openCases,
    required this.closedCases,
    required this.reOpenCases,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalCases: parseValue<int>(json, "TotalCases"),
    openCases: parseValue<int>(json, "OpenCases"),
    closedCases: parseValue<int>(json, "ClosedCases"),
    reOpenCases: parseValue<int>(json, "ReOpenCases"),
  );

  Map<String, dynamic> toJson() => {
    "TotalCases": totalCases,
    "OpenCases": openCases,
    "ClosedCases": closedCases,
    "ReOpenCases": reOpenCases,
  };
}

class Table1 {
  final int totalHearings;

  Table1({required this.totalHearings});

  factory Table1.fromJson(Map<String, dynamic> json) =>
      Table1(totalHearings: parseValue<int>(json, "TotalHearings"));

  Map<String, dynamic> toJson() => {"TotalHearings": totalHearings};
}

class Table2 {
  final String caseType;
  final int totalCases;

  Table2({required this.caseType, required this.totalCases});

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    caseType: parseValue<String>(json, "CaseType"),
    totalCases: parseValue<int>(json, "TotalCases"),
  );

  Map<String, dynamic> toJson() => {
    "CaseType": caseType,
    "TotalCases": totalCases,
  };
}

class Table3 {
  final String caseType;
  final int totalCases;
  final int openCases;

  Table3({
    required this.caseType,
    required this.totalCases,
    required this.openCases,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    caseType: parseValue<String>(json, "CaseType"),
    totalCases: parseValue<int>(json, "TotalCases"),
    openCases: parseValue<int>(json, "OpenCases"),
  );

  Map<String, dynamic> toJson() => {
    "CaseType": caseType,
    "TotalCases": totalCases,
    "OpenCases": openCases,
  };
}

class Table4 {
  final String title;
  final String caseNumber;
  final String caseType;
  final DateTime hearingDate;
  final String status;

  Table4({
    required this.title,
    required this.caseNumber,
    required this.caseType,
    required this.hearingDate,
    required this.status,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    title: parseValue<String>(json, "Title"),
    caseNumber: parseValue<String>(json, "CaseNumber"),
    caseType: parseValue<String>(json, "CaseType"),
    hearingDate: parseValue<DateTime>(json, "HearingDate"),
    status: parseValue<String>(json, "Status"),
  );

  Map<String, dynamic> toJson() => {
    "Title": title,
    "CaseNumber": caseNumber,
    "CaseType": caseType,
    "HearingDate": hearingDate.toIso8601String(),
    "Status": status,
  };
}

class Table5 {
  final String caseNumber;
  final String caseType;
  final String courtType;
  final DateTime hearingDate;
  final int daysRemaining;

  Table5({
    required this.caseNumber,
    required this.caseType,
    required this.courtType,
    required this.hearingDate,
    required this.daysRemaining,
  });

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
    caseNumber: parseValue<String>(json, "CaseNumber"),
    caseType: parseValue<String>(json, "CaseType"),
    courtType: parseValue<String>(json, "CourtType"),
    hearingDate: parseValue<DateTime>(json, "HearingDate"),
    daysRemaining: parseValue<int>(json, "DaysRemaining"),
  );

  Map<String, dynamic> toJson() => {
    "CaseNumber": caseNumber,
    "CaseType": caseType,
    "CourtType": courtType,
    "HearingDate": hearingDate.toIso8601String(),
    "DaysRemaining": daysRemaining,
  };
}

class Table6 {
  final String documentName;
  final DateTime recentDate;

  Table6({required this.documentName, required this.recentDate});

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    documentName: parseValue<String>(json, "DocumentName"),
    recentDate: parseValue<DateTime>(json, "RecentDate"),
  );

  Map<String, dynamic> toJson() => {
    "DocumentName": documentName,
    "RecentDate": recentDate.toIso8601String(),
  };
}
