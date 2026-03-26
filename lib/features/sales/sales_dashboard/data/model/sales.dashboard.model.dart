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
  final String name;
  final DateTime enquiryDate;
  final String enquiryTimeIn;
  final int enquiryId;

  Table0({
    required this.name,
    required this.enquiryDate,
    required this.enquiryTimeIn,
    required this.enquiryId,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    name: parseValue<String>(json, "Name"),
    enquiryDate: parseValue<DateTime>(json, "EnquiryDate"),
    enquiryTimeIn: parseValue<String>(json, "EnquiryTimeIn"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "EnquiryDate": enquiryDate.toIso8601String(),
    "EnquiryTimeIn": enquiryTimeIn,
    "EnquiryId": enquiryId,
  };
}

class Table1 {
  final String name;
  final String enquiryFollowUpDays;
  final String finalStage;
  final String nextFollowUpDate;
  final int enquiryId;

  Table1({
    required this.name,
    required this.enquiryFollowUpDays,
    required this.finalStage,
    required this.nextFollowUpDate,
    required this.enquiryId,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    name: parseValue<String>(json, "Name"),
    enquiryFollowUpDays: parseValue<String>(json, "EnquiryFollowUpDays"),
    finalStage: parseValue<String>(json, "FinalStage"),
    nextFollowUpDate: parseValue<String>(json, "NextFollowUpDate"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "EnquiryFollowUpDays": enquiryFollowUpDays,
    "FinalStage": finalStage,
    "NextFollowUpDate": nextFollowUpDate,
    "EnquiryId": enquiryId,
  };
}
