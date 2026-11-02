import 'package:k3h_erp_app/utils/functions/common_function.dart';

class GatePassDashboardModel {
  List<Table0> table0;
  List<Table1> table1;
  List<Table2> table2;
  List<Table3> table3;
  List<Table4> table4;

  GatePassDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
  });

  factory GatePassDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => GatePassDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
  };
}

class Table0 {
  int totalVisitors;
  int currentlyInside;
  int expectedToday;
  int checkedOut;
  int overstaying;
  int pendingApprovals;

  Table0({
    required this.totalVisitors,
    required this.currentlyInside,
    required this.expectedToday,
    required this.checkedOut,
    required this.overstaying,
    required this.pendingApprovals,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalVisitors: parseValue<int>(json, "TotalVisitors"),
    currentlyInside: parseValue<int>(json, "CurrentlyInside"),
    expectedToday: parseValue<int>(json, "ExpectedToday"),
    checkedOut: parseValue<int>(json, "CheckedOut"),
    overstaying: parseValue<int>(json, "Overstaying"),
    pendingApprovals: parseValue<int>(json, "PendingApprovals"),
  );

  Map<String, dynamic> toJson() => {
    "TotalVisitors": totalVisitors,
    "CurrentlyInside": currentlyInside,
    "ExpectedToday": expectedToday,
    "CheckedOut": checkedOut,
    "Overstaying": overstaying,
    "PendingApprovals": pendingApprovals,
  };
}

class Table1 {
  int externalId;
  String uniquekey;
  String visitorName;
  String contact;
  int noOfParticipants;
  String address;
  int employeeId;
  String appointmentWith;
  DateTime checkInTime;
  DateTime? checkOutTime;
  String purpose;
  String status;
  String remark;
  String approvalRemark;
  bool isApproval;
  bool isCheckOutEnabled;
  bool isNoticationEnabled;
  String photoUrl;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String message;
  int totalRecords;

  Table1({
    required this.externalId,
    required this.uniquekey,
    required this.visitorName,
    required this.contact,
    required this.noOfParticipants,
    required this.address,
    required this.employeeId,
    required this.appointmentWith,
    required this.checkInTime,
    required this.checkOutTime,
    required this.purpose,
    required this.status,
    required this.remark,
    required this.approvalRemark,
    required this.isApproval,
    required this.isCheckOutEnabled,
    required this.isNoticationEnabled,
    required this.photoUrl,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.message,
    required this.totalRecords,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    externalId: parseValue<int>(json, "ExternalId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    visitorName: parseValue<String>(json, "VisitorName"),
    contact: parseValue<String>(json, "Contact"),
    noOfParticipants: parseValue<int>(json, "NoOfParticipants"),
    address: parseValue<String>(json, "Address"),
    employeeId: parseValue<int>(json, "EmployeeId"),
    appointmentWith: parseValue<String>(json, "AppointmentWith"),
    checkInTime: parseValue<DateTime>(json, "CheckInTime"),
    checkOutTime:
        json["CheckOutTime"] == null || json["CheckOutTime"] is Map
            ? null
            : DateTime.tryParse(json["CheckOutTime"].toString()),

    purpose: parseValue<String>(json, "Purpose"),
    status: parseValue<String>(json, "Status"),
    remark: parseValue<String>(json, "Remark"),
    approvalRemark: parseValue<String>(json, "ApprovalRemark"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    isCheckOutEnabled: parseValue<bool>(json, "IsCheckOutEnabled"),
    isNoticationEnabled: parseValue<bool>(json, "IsNoticationEnabled"),
    photoUrl: parseValue<String>(json, "PhotoURL"),
    clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null || json["ModifiedDate"] is Map
            ? null
            : DateTime.tryParse(json["ModifiedDate"].toString()),
    message: parseValue<String>(json, "Message"),
    totalRecords: parseValue<int>(json, "TotalRecords"),
  );

  Map<String, dynamic> toJson() => {
    "ExternalId": externalId,
    "Uniquekey": uniquekey,
    "VisitorName": visitorName,
    "Contact": contact,
    "NoOfParticipants": noOfParticipants,
    "Address": address,
    "EmployeeId": employeeId,
    "AppointmentWith": appointmentWith,
    "CheckInTime": checkInTime.toIso8601String(),
    "CheckOutTime": checkOutTime?.toIso8601String(),
    "Purpose": purpose,
    "Status": status,
    "Remark": remark,
    "ApprovalRemark": approvalRemark,
    "IsApproval": isApproval,
    "IsCheckOutEnabled": isCheckOutEnabled,
    "IsNoticationEnabled": isNoticationEnabled,
    "PhotoURL": photoUrl,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "Message": message,
    "TotalRecords": totalRecords,
  };
}

class Table2 {
  int externalId;
  String visitorName;
  int noOfParticipants;
  DateTime visitTime;
  DateTime outDateTime;
  String purpose;
  String status;

  Table2({
    required this.externalId,
    required this.visitorName,
    required this.noOfParticipants,
    required this.visitTime,
    required this.outDateTime,
    required this.purpose,
    required this.status,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    externalId: parseValue<int>(json, "ExternalId"),
    visitorName: parseValue<String>(json, "VisitorName"),
    noOfParticipants: parseValue<int>(json, "NoOfParticipants"),
    visitTime: parseValue<DateTime>(json, "VisitTime"),
    outDateTime: parseValue<DateTime>(json, "OutDateTime"),
    purpose: parseValue<String>(json, "Purpose"),
    status: parseValue<String>(json, "Status"),
  );

  Map<String, dynamic> toJson() => {
    "ExternalId": externalId,
    "VisitorName": visitorName,
    "NoOfParticipants": noOfParticipants,
    "VisitTime": visitTime.toIso8601String(),
    "OutDateTime": outDateTime.toIso8601String(),
    "Purpose": purpose,
    "Status": status,
  };
}

class Table3 {
  String purpose;
  int visitorCount;
  double percentage;

  Table3({
    required this.purpose,
    required this.visitorCount,
    required this.percentage,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    purpose: parseValue<String>(json, "Purpose"),
    visitorCount: parseValue<int>(json, "VisitorCount"),
    percentage: parseValue<double>(json, "Percentage"),
  );

  Map<String, dynamic> toJson() => {
    "Purpose": purpose,
    "VisitorCount": visitorCount,
    "Percentage": percentage,
  };
}

class Table4 {
  String alertType;
  int externalId;
  String visitorName;
  String contact;
  String appointmentWith;
  String visitTime;
  String outDateTime;
  String purpose;
  String alertMessage;
  String status;

  Table4({
    required this.alertType,
    required this.externalId,
    required this.visitorName,
    required this.contact,
    required this.appointmentWith,
    required this.visitTime,
    required this.outDateTime,
    required this.purpose,
    required this.alertMessage,
    required this.status,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    alertType: parseValue<String>(json, "AlertType"),
    externalId: parseValue<int>(json, "ExternalId"),
    visitorName: parseValue<String>(json, "VisitorName"),
    contact: parseValue<String>(json, "Contact"),
    appointmentWith: parseValue<String>(json, "AppointmentWith"),
    visitTime: parseValue<String>(json, "VisitTime"),
    outDateTime: parseValue<String>(json, "OutDateTime"),
    purpose: parseValue<String>(json, "Purpose"),
    alertMessage: parseValue<String>(json, "AlertMessage"),
    status: parseValue<String>(json, "Status"),
  );

  Map<String, dynamic> toJson() => {
    "AlertType": alertType,
    "ExternalId": externalId,
    "VisitorName": visitorName,
    "Contact": contact,
    "AppointmentWith": appointmentWith,
    "VisitTime": visitTime,
    "OutDateTime": outDateTime,
    "Purpose": purpose,
    "AlertMessage": alertMessage,
    "Status": status,
  };
}
