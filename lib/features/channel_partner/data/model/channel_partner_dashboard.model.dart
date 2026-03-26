import 'package:k3h_erp_app/utils/common_function.dart';

class ChannelPartnerDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<Table5> table5;

  ChannelPartnerDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
  });

  factory ChannelPartnerDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => ChannelPartnerDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<Table5>.from(json["Table5"].map((x) => Table5.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x.toJson())),
  };
}

class Table0 {
  final int totalChannelPartner;
  final int activeChannelPartner;
  final int thisMonthAddedChannelPartner;
  final int missingInfoChannelPartner;

  Table0({
    required this.totalChannelPartner,
    required this.activeChannelPartner,
    required this.thisMonthAddedChannelPartner,
    required this.missingInfoChannelPartner,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalChannelPartner: parseValue<int>(json, "TotalChannelPartner"),
    activeChannelPartner: parseValue<int>(json, "ActiveChannelPartner"),
    thisMonthAddedChannelPartner: parseValue<int>(
      json,
      "ThisMonthAddedChannelPartner",
    ),
    missingInfoChannelPartner: parseValue<int>(
      json,
      "MissingInfoChannelPartner",
    ),
  );

  Map<String, dynamic> toJson() => {
    "TotalChannelPartner": totalChannelPartner,
    "ActiveChannelPartner": activeChannelPartner,
    "ThisMonthAddedChannelPartner": thisMonthAddedChannelPartner,
    "MissingInfoChannelPartner": missingInfoChannelPartner,
  };
}

class Table1 {
  final String firmsType;
  final int totalCount;

  Table1({required this.firmsType, required this.totalCount});

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    firmsType: parseValue<String>(json, "FirmsType"),
    totalCount: parseValue<int>(json, "TotalCount"),
  );

  Map<String, dynamic> toJson() => {
    "FirmsType": firmsType,
    "TotalCount": totalCount,
  };
}

class Table2 {
  final String type;
  final int totalCount;

  Table2({required this.type, required this.totalCount});

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    type: parseValue<String>(json, "Type"),
    totalCount: parseValue<int>(json, "TotalCount"),
  );

  Map<String, dynamic> toJson() => {"Type": type, "TotalCount": totalCount};
}

class Table3 {
  final String name;
  final int totalChannelPartner;

  Table3({required this.name, required this.totalChannelPartner});

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    name: parseValue<String>(json, "Name"),
    totalChannelPartner: parseValue<int>(json, "TotalChannelPartner"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "TotalChannelPartner": totalChannelPartner,
  };
}

class Table4 {
  final String systemGeneratedCode;
  final int channelPartnerId;
  final String name;
  final String companyName;
  final String mobileNumber;
  final String type;
  final DateTime createdDate;

  Table4({
    required this.systemGeneratedCode,
    required this.channelPartnerId,
    required this.name,
    required this.companyName,
    required this.mobileNumber,
    required this.type,
    required this.createdDate,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
    name: parseValue<String>(json, "Name"),
    companyName: parseValue<String>(json, "CompanyName"),
    mobileNumber: parseValue<String>(json, "MobileNumber"),
    type: parseValue<String>(json, "Type"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
  );

  Map<String, dynamic> toJson() => {
    "SystemGeneratedCode": systemGeneratedCode,
    "ChannelPartnerId": channelPartnerId,
    "Name": name,
    "CompanyName": companyName,
    "MobileNumber": mobileNumber,
    "Type": type,
    "CreatedDate": createdDate.toIso8601String(),
  };
}

class Table5 {
  final int channelPartnerId;
  final String name;
  final String systemGeneratedCode;
  final String missingFields;

  Table5({
    required this.channelPartnerId,
    required this.name,
    required this.systemGeneratedCode,
    required this.missingFields,
  });

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
    channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
    name: parseValue<String>(json, "Name"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    missingFields: parseValue<String>(json, "MissingFields"),
  );

  Map<String, dynamic> toJson() => {
    "ChannelPartnerId": channelPartnerId,
    "Name": name,
    "SystemGeneratedCode": systemGeneratedCode,
    "MissingFields": missingFields,
  };
}
