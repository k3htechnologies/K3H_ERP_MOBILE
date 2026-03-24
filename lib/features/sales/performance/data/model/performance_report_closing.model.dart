// To parse this JSON data, do
//
//     final performanceReportClosingModel = performanceReportClosingModelFromJson(jsonString);

import 'dart:convert';

PerformanceReportClosingModel performanceReportClosingModelFromJson(
  String str,
) => PerformanceReportClosingModel.fromJson(json.decode(str));

String performanceReportClosingModelToJson(
  PerformanceReportClosingModel data,
) => json.encode(data.toJson());

class PerformanceReportClosingModel {
  final List<String> successMessage;
  final List<dynamic> errorMessage;
  final List<dynamic> warningMessage;
  final List<Datum> data;
  final bool isSuccess;
  final int totalNumberOfRecord;
  final int httpStatusCode;

  PerformanceReportClosingModel({
    required this.successMessage,
    required this.errorMessage,
    required this.warningMessage,
    required this.data,
    required this.isSuccess,
    required this.totalNumberOfRecord,
    required this.httpStatusCode,
  });

  factory PerformanceReportClosingModel.fromJson(Map<String, dynamic> json) =>
      PerformanceReportClosingModel(
        successMessage: List<String>.from(json["SuccessMessage"].map((x) => x)),
        errorMessage: List<dynamic>.from(json["ErrorMessage"].map((x) => x)),
        warningMessage: List<dynamic>.from(
          json["WarningMessage"].map((x) => x),
        ),
        data: List<Datum>.from(json["Data"].map((x) => Datum.fromJson(x))),
        isSuccess: json["IsSuccess"],
        totalNumberOfRecord: json["TotalNumberOfRecord"],
        httpStatusCode: json["HttpStatusCode"],
      );

  Map<String, dynamic> toJson() => {
    "SuccessMessage": List<dynamic>.from(successMessage.map((x) => x)),
    "ErrorMessage": List<dynamic>.from(errorMessage.map((x) => x)),
    "WarningMessage": List<dynamic>.from(warningMessage.map((x) => x)),
    "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    "IsSuccess": isSuccess,
    "TotalNumberOfRecord": totalNumberOfRecord,
    "HttpStatusCode": httpStatusCode,
  };
}

class Datum {
  final int employeeId;
  final String employeeName;
  final String designationName;
  final int walkinsByCp;
  final int actualWalkinsByCp;
  final int performanceWalkinsByCp;
  final int walkinsDirect;
  final int actualWalkinsDirect;
  final int performanceWalkinsDirect;
  final int freshVisits;
  final int actualFreshVisits;
  final int performanceFreshVisits;
  final int revisits;
  final int actualRevisits;
  final int performanceRevisits;
  final int bookingByCp;
  final int actualBookingByCp;
  final int performanceBookingByCp;
  final int bookingDirect;
  final int actualBookingDirect;
  final int performanceBookingDirect;

  Datum({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCp,
    required this.actualWalkinsByCp,
    required this.performanceWalkinsByCp,
    required this.walkinsDirect,
    required this.actualWalkinsDirect,
    required this.performanceWalkinsDirect,
    required this.freshVisits,
    required this.actualFreshVisits,
    required this.performanceFreshVisits,
    required this.revisits,
    required this.actualRevisits,
    required this.performanceRevisits,
    required this.bookingByCp,
    required this.actualBookingByCp,
    required this.performanceBookingByCp,
    required this.bookingDirect,
    required this.actualBookingDirect,
    required this.performanceBookingDirect,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    employeeId: json["EmployeeId"],
    employeeName: json["EmployeeName"],
    designationName: json["DesignationName"],
    walkinsByCp: json["WalkinsByCP"],
    actualWalkinsByCp: json["ActualWalkinsByCP"],
    performanceWalkinsByCp: json["PerformanceWalkinsByCP"],
    walkinsDirect: json["WalkinsDirect"],
    actualWalkinsDirect: json["ActualWalkinsDirect"],
    performanceWalkinsDirect: json["PerformanceWalkinsDirect"],
    freshVisits: json["FreshVisits"],
    actualFreshVisits: json["ActualFreshVisits"],
    performanceFreshVisits: json["PerformanceFreshVisits"],
    revisits: json["Revisits"],
    actualRevisits: json["ActualRevisits"],
    performanceRevisits: json["PerformanceRevisits"],
    bookingByCp: json["BookingByCP"],
    actualBookingByCp: json["ActualBookingByCP"],
    performanceBookingByCp: json["PerformanceBookingByCP"],
    bookingDirect: json["BookingDirect"],
    actualBookingDirect: json["ActualBookingDirect"],
    performanceBookingDirect: json["PerformanceBookingDirect"],
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCp,
    "ActualWalkinsByCP": actualWalkinsByCp,
    "PerformanceWalkinsByCP": performanceWalkinsByCp,
    "WalkinsDirect": walkinsDirect,
    "ActualWalkinsDirect": actualWalkinsDirect,
    "PerformanceWalkinsDirect": performanceWalkinsDirect,
    "FreshVisits": freshVisits,
    "ActualFreshVisits": actualFreshVisits,
    "PerformanceFreshVisits": performanceFreshVisits,
    "Revisits": revisits,
    "ActualRevisits": actualRevisits,
    "PerformanceRevisits": performanceRevisits,
    "BookingByCP": bookingByCp,
    "ActualBookingByCP": actualBookingByCp,
    "PerformanceBookingByCP": performanceBookingByCp,
    "BookingDirect": bookingDirect,
    "ActualBookingDirect": actualBookingDirect,
    "PerformanceBookingDirect": performanceBookingDirect,
  };
}
