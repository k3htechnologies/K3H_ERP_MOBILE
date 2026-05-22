import 'package:k3h_erp_app/utils/common_function.dart';

class CrmDashboardModel {
  List<Table0> table0;
  List<dynamic> table1;
  List<dynamic> table2;
  List<dynamic> table3;
  List<Table4> table4;
  List<dynamic> table5;
  List<Table6> table6;

  CrmDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
  });

  factory CrmDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => CrmDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<dynamic>.from(json["Table1"].map((x) => x)),
    table2: List<dynamic>.from(json["Table2"].map((x) => x)),
    table3: List<dynamic>.from(json["Table3"].map((x) => x)),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<dynamic>.from(json["Table5"].map((x) => x)),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x)),
    "Table2": List<dynamic>.from(table2.map((x) => x)),
    "Table3": List<dynamic>.from(table3.map((x) => x)),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x)),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
  };
}

class Table0 {
  int totalAgreementAmount;
  int totalAgreementGstAmount;
  int totalAgreementTdsAmount;
  int totalReceivedAgreementAmount;
  int totalOutstandingAgreementValue;
  int totalBooking;
  int nonRegisteredBooking;
  int registeredBooking;
  int upcomingRegistration;
  int totalCollection;
  int collectionAgreementReceived;
  int collectionGst;
  int collectionTds;
  int totalBrokerageAmount;
  int paidBrokerageAmount;
  int outstandingBrokerageAmount;
  int totalChannelPartner;

  Table0({
    required this.totalAgreementAmount,
    required this.totalAgreementGstAmount,
    required this.totalAgreementTdsAmount,
    required this.totalReceivedAgreementAmount,
    required this.totalOutstandingAgreementValue,
    required this.totalBooking,
    required this.nonRegisteredBooking,
    required this.registeredBooking,
    required this.upcomingRegistration,
    required this.totalCollection,
    required this.collectionAgreementReceived,
    required this.collectionGst,
    required this.collectionTds,
    required this.totalBrokerageAmount,
    required this.paidBrokerageAmount,
    required this.outstandingBrokerageAmount,
    required this.totalChannelPartner,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalAgreementAmount: parseValue<int>(json, "TotalAgreementAmount"),
    totalAgreementGstAmount: parseValue<int>(json, "TotalAgreementGSTAmount"),
    totalAgreementTdsAmount: parseValue<int>(json, "TotalAgreementTDSAmount"),
    totalReceivedAgreementAmount: parseValue<int>(
      json,
      "TotalReceivedAgreementAmount",
    ),
    totalOutstandingAgreementValue: parseValue<int>(
      json,
      "TotalOutstandingAgreementValue",
    ),
    totalBooking: parseValue<int>(json, "TotalBooking"),
    nonRegisteredBooking: parseValue<int>(json, "NonRegisteredBooking"),
    registeredBooking: parseValue<int>(json, "RegisteredBooking"),
    upcomingRegistration: parseValue<int>(json, "UpcomingRegistration"),
    totalCollection: parseValue<int>(json, "TotalCollection"),
    collectionAgreementReceived: parseValue<int>(
      json,
      "CollectionAgreementReceived",
    ),
    collectionGst: parseValue<int>(json, "CollectionGST"),
    collectionTds: parseValue<int>(json, "CollectionTDS"),
    totalBrokerageAmount: parseValue<int>(json, "TotalBrokerageAmount"),
    paidBrokerageAmount: parseValue<int>(json, "PaidBrokerageAmount"),
    outstandingBrokerageAmount: parseValue<int>(
      json,
      "OutstandingBrokerageAmount",
    ),
    totalChannelPartner: parseValue<int>(json, "TotalChannelPartner"),
  );

  Map<String, dynamic> toJson() => {
    "TotalAgreementAmount": totalAgreementAmount,
    "TotalAgreementGSTAmount": totalAgreementGstAmount,
    "TotalAgreementTDSAmount": totalAgreementTdsAmount,
    "TotalReceivedAgreementAmount": totalReceivedAgreementAmount,
    "TotalOutstandingAgreementValue": totalOutstandingAgreementValue,
    "TotalBooking": totalBooking,
    "NonRegisteredBooking": nonRegisteredBooking,
    "RegisteredBooking": registeredBooking,
    "UpcomingRegistration": upcomingRegistration,
    "TotalCollection": totalCollection,
    "CollectionAgreementReceived": collectionAgreementReceived,
    "CollectionGST": collectionGst,
    "CollectionTDS": collectionTds,
    "TotalBrokerageAmount": totalBrokerageAmount,
    "PaidBrokerageAmount": paidBrokerageAmount,
    "OutstandingBrokerageAmount": outstandingBrokerageAmount,
    "TotalChannelPartner": totalChannelPartner,
  };
}

class Table4 {
  Label label;
  int agreement;
  int gst;
  int tds;

  Table4({
    required this.label,
    required this.agreement,
    required this.gst,
    required this.tds,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    label: Label.fromJson(json["Label"]),
    agreement: parseValue<int>(json, "Agreement"),
    gst: parseValue<int>(json, "GST"),
    tds: parseValue<int>(json, "TDS"),
  );

  Map<String, dynamic> toJson() => {
    "Label": label.toJson(),
    "Agreement": agreement,
    "GST": gst,
    "TDS": tds,
  };
}

class Label {
  Label();

  factory Label.fromJson(Map<String, dynamic> json) => Label();

  Map<String, dynamic> toJson() => {};
}

class Table6 {
  String name;
  int totalCount;
  int approvedCount;
  int pendingCount;

  Table6({
    required this.name,
    required this.totalCount,
    required this.approvedCount,
    required this.pendingCount,
  });

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    name: parseValue<String>(json, "Name"),
    totalCount: parseValue<int>(json, "TotalCount"),
    approvedCount: parseValue<int>(json, "ApprovedCount"),
    pendingCount: parseValue<int>(json, "PendingCount"),
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "TotalCount": totalCount,
    "ApprovedCount": approvedCount,
    "PendingCount": pendingCount,
  };
}
