import 'package:k3h_erp_app/utils/common_function.dart';

class SalesDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;

  SalesDashboardModel({required this.table0, required this.table1});

  factory SalesDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => SalesDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
  };
}

class Table0 {
  final String systemGeneratedCode;
  final String projectName;
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
  final DateTime nextFollowUpDate;
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
    nextFollowUpDate: parseValue<DateTime>(json, "NextFollowUpDate"),
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
    "NextFollowUpDate": nextFollowUpDate.toIso8601String(),
    "SalesAdvisor": salesAdvisor,
    "SourcingManager": sourcingManager,
    "CreatedDate": createdDate.toIso8601String(),
    "EnquiryId": enquiryId,
  };
}
