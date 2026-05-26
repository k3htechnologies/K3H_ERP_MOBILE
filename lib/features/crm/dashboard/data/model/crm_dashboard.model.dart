import 'package:k3h_erp_app/utils/common_function.dart';

class CrmDashboardModel {
  List<Table0> table0;
  List<Table1> table1;
  List<Table2> table2;
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
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<dynamic>.from(json["Table3"].map((x) => x)),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<dynamic>.from(json["Table5"].map((x) => x)),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x)),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x)),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
  };
}

class Table0 {
  double totalAgreementAmount;
  double totalAgreementGstAmount;
  double totalAgreementTdsAmount;
  double totalReceivedAgreementAmount;
  double totalOutstandingAgreementValue;
  int totalBooking;
  int nonRegisteredBooking;
  int registeredBooking;
  int upcomingRegistration;
  double totalCollection;
  double collectionAgreementReceived;
  double collectionGst;
  double collectionTds;
  double totalBrokerageAmount;
  double paidBrokerageAmount;
  double outstandingBrokerageAmount;
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
    totalAgreementAmount: parseValue<double>(json, "TotalAgreementAmount"),
    totalAgreementGstAmount: parseValue<double>(
      json,
      "TotalAgreementGSTAmount",
    ),
    totalAgreementTdsAmount: parseValue<double>(
      json,
      "TotalAgreementTDSAmount",
    ),
    totalReceivedAgreementAmount: parseValue<double>(
      json,
      "TotalReceivedAgreementAmount",
    ),
    totalOutstandingAgreementValue: parseValue<double>(
      json,
      "TotalOutstandingAgreementValue",
    ),
    totalBooking: parseValue<int>(json, "TotalBooking"),
    nonRegisteredBooking: parseValue<int>(json, "NonRegisteredBooking"),
    registeredBooking: parseValue<int>(json, "RegisteredBooking"),
    upcomingRegistration: parseValue<int>(json, "UpcomingRegistration"),
    totalCollection: parseValue<double>(json, "TotalCollection"),
    collectionAgreementReceived: parseValue<double>(
      json,
      "CollectionAgreementReceived",
    ),
    collectionGst: parseValue<double>(json, "CollectionGST"),
    collectionTds: parseValue<double>(json, "CollectionTDS"),
    totalBrokerageAmount: parseValue<double>(json, "TotalBrokerageAmount"),
    paidBrokerageAmount: parseValue<double>(json, "PaidBrokerageAmount"),
    outstandingBrokerageAmount: parseValue<double>(
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

class Table1 {
  int brokerageAmount;
  String channelPartnerName;

  Table1({required this.brokerageAmount, required this.channelPartnerName});

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    brokerageAmount: parseValue<int>(json, "BrokerageAmount"),
    channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
  );

  Map<String, dynamic> toJson() => {
    "BrokerageAmount": brokerageAmount,
    "ChannelPartnerName": channelPartnerName,
  };
}

class Table2 {
  String systemGeneratedCode;
  String applicantName;
  double agreementValue;
  DateTime createdDate;
  String flat;

  Table2({
    required this.systemGeneratedCode,
    required this.applicantName,
    required this.agreementValue,
    required this.createdDate,
    required this.flat,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    agreementValue: parseValue<double>(json, "AgreementValue"),
    createdDate:
        json["CreatedDate"] != null
            ? DateTime.parse(json["CreatedDate"])
            : DateTime.now(),
    flat: parseValue<String>(json, "Flat"),
  );

  Map<String, dynamic> toJson() => {
    "SystemGeneratedCode": systemGeneratedCode,
    "ApplicantName": applicantName,
    "AgreementValue": agreementValue,
    "CreatedDate": createdDate.toIso8601String(),
    "Flat": flat,
  };
}

class Table4 {
  String label;
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
    label: parseValue<String>(json, "Label"),
    agreement: parseValue<int>(json, "Agreement"),
    gst: parseValue<int>(json, "GST"),
    tds: parseValue<int>(json, "TDS"),
  );

  Map<String, dynamic> toJson() => {
    "Label": label,
    "Agreement": agreement,
    "GST": gst,
    "TDS": tds,
  };
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
