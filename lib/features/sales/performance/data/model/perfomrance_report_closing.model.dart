// To parse this JSON data, do
//
//     final performanceReportSourcingModel = performanceReportSourcingModelFromJson(jsonString);

import 'dart:convert';

PerformanceReportSourcingModel performanceReportSourcingModelFromJson(
  String str,
) => PerformanceReportSourcingModel.fromJson(json.decode(str));

String performanceReportSourcingModelToJson(
  PerformanceReportSourcingModel data,
) => json.encode(data.toJson());

class PerformanceReportSourcingModel {
  final List<String> successMessage;
  final List<dynamic> errorMessage;
  final List<dynamic> warningMessage;
  final List<Datum> data;
  final bool isSuccess;
  final int totalNumberOfRecord;
  final int httpStatusCode;

  PerformanceReportSourcingModel({
    required this.successMessage,
    required this.errorMessage,
    required this.warningMessage,
    required this.data,
    required this.isSuccess,
    required this.totalNumberOfRecord,
    required this.httpStatusCode,
  });

  factory PerformanceReportSourcingModel.fromJson(Map<String, dynamic> json) =>
      PerformanceReportSourcingModel(
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
  final int freshVisits;
  final int actualFreshVisits;
  final int performanceFreshVisits;
  final int revisits;
  final int actualRevisits;
  final int performanceRevisits;
  final int bookings;
  final int actualBookings;
  final int performanceBookings;
  final int totalMeetings;
  final int actualTotalMeetings;
  final int performanceTotalMeetings;
  final int totalObm;
  final int actualTotalObm;
  final int performanceTotalObm;
  final int totalObmFreshVisits;
  final int actualTotalObmFreshVisits;
  final int performanceTotalObmFreshVisits;
  final int totalObmRevisits;
  final int actualTotalObmRevisits;
  final int performanceTotalObmRevisits;
  final int totalIbm;
  final int actualTotalIbm;
  final int performanceTotalIbm;
  final int uniqueCPs;
  final int actualUniqueCPs;
  final int performanceUniqueCPs;
  final int activeCp;
  final int actualActiveCp;
  final int performanceActiveCp;
  final int newCp;
  final int actualNewCp;
  final int performanceNewCp;

  Datum({
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.walkinsByCp,
    required this.actualWalkinsByCp,
    required this.performanceWalkinsByCp,
    required this.freshVisits,
    required this.actualFreshVisits,
    required this.performanceFreshVisits,
    required this.revisits,
    required this.actualRevisits,
    required this.performanceRevisits,
    required this.bookings,
    required this.actualBookings,
    required this.performanceBookings,
    required this.totalMeetings,
    required this.actualTotalMeetings,
    required this.performanceTotalMeetings,
    required this.totalObm,
    required this.actualTotalObm,
    required this.performanceTotalObm,
    required this.totalObmFreshVisits,
    required this.actualTotalObmFreshVisits,
    required this.performanceTotalObmFreshVisits,
    required this.totalObmRevisits,
    required this.actualTotalObmRevisits,
    required this.performanceTotalObmRevisits,
    required this.totalIbm,
    required this.actualTotalIbm,
    required this.performanceTotalIbm,
    required this.uniqueCPs,
    required this.actualUniqueCPs,
    required this.performanceUniqueCPs,
    required this.activeCp,
    required this.actualActiveCp,
    required this.performanceActiveCp,
    required this.newCp,
    required this.actualNewCp,
    required this.performanceNewCp,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    employeeId: json["EmployeeId"],
    employeeName: json["EmployeeName"],
    designationName: json["DesignationName"],
    walkinsByCp: json["WalkinsByCP"],
    actualWalkinsByCp: json["ActualWalkinsByCP"],
    performanceWalkinsByCp: json["PerformanceWalkinsByCP"],
    freshVisits: json["FreshVisits"],
    actualFreshVisits: json["ActualFreshVisits"],
    performanceFreshVisits: json["PerformanceFreshVisits"],
    revisits: json["Revisits"],
    actualRevisits: json["ActualRevisits"],
    performanceRevisits: json["PerformanceRevisits"],
    bookings: json["Bookings"],
    actualBookings: json["ActualBookings"],
    performanceBookings: json["PerformanceBookings"],
    totalMeetings: json["TotalMeetings"],
    actualTotalMeetings: json["ActualTotalMeetings"],
    performanceTotalMeetings: json["PerformanceTotalMeetings"],
    totalObm: json["TotalOBM"],
    actualTotalObm: json["ActualTotalOBM"],
    performanceTotalObm: json["PerformanceTotalOBM"],
    totalObmFreshVisits: json["TotalOBMFreshVisits"],
    actualTotalObmFreshVisits: json["ActualTotalOBMFreshVisits"],
    performanceTotalObmFreshVisits: json["PerformanceTotalOBMFreshVisits"],
    totalObmRevisits: json["TotalOBMRevisits"],
    actualTotalObmRevisits: json["ActualTotalOBMRevisits"],
    performanceTotalObmRevisits: json["PerformanceTotalOBMRevisits"],
    totalIbm: json["TotalIBM"],
    actualTotalIbm: json["ActualTotalIBM"],
    performanceTotalIbm: json["PerformanceTotalIBM"],
    uniqueCPs: json["UniqueCPs"],
    actualUniqueCPs: json["ActualUniqueCPs"],
    performanceUniqueCPs: json["PerformanceUniqueCPs"],
    activeCp: json["ActiveCP"],
    actualActiveCp: json["ActualActiveCP"],
    performanceActiveCp: json["PerformanceActiveCP"],
    newCp: json["NewCP"],
    actualNewCp: json["ActualNewCP"],
    performanceNewCp: json["PerformanceNewCP"],
  );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "WalkinsByCP": walkinsByCp,
    "ActualWalkinsByCP": actualWalkinsByCp,
    "PerformanceWalkinsByCP": performanceWalkinsByCp,
    "FreshVisits": freshVisits,
    "ActualFreshVisits": actualFreshVisits,
    "PerformanceFreshVisits": performanceFreshVisits,
    "Revisits": revisits,
    "ActualRevisits": actualRevisits,
    "PerformanceRevisits": performanceRevisits,
    "Bookings": bookings,
    "ActualBookings": actualBookings,
    "PerformanceBookings": performanceBookings,
    "TotalMeetings": totalMeetings,
    "ActualTotalMeetings": actualTotalMeetings,
    "PerformanceTotalMeetings": performanceTotalMeetings,
    "TotalOBM": totalObm,
    "ActualTotalOBM": actualTotalObm,
    "PerformanceTotalOBM": performanceTotalObm,
    "TotalOBMFreshVisits": totalObmFreshVisits,
    "ActualTotalOBMFreshVisits": actualTotalObmFreshVisits,
    "PerformanceTotalOBMFreshVisits": performanceTotalObmFreshVisits,
    "TotalOBMRevisits": totalObmRevisits,
    "ActualTotalOBMRevisits": actualTotalObmRevisits,
    "PerformanceTotalOBMRevisits": performanceTotalObmRevisits,
    "TotalIBM": totalIbm,
    "ActualTotalIBM": actualTotalIbm,
    "PerformanceTotalIBM": performanceTotalIbm,
    "UniqueCPs": uniqueCPs,
    "ActualUniqueCPs": actualUniqueCPs,
    "PerformanceUniqueCPs": performanceUniqueCPs,
    "ActiveCP": activeCp,
    "ActualActiveCP": actualActiveCp,
    "PerformanceActiveCP": performanceActiveCp,
    "NewCP": newCp,
    "ActualNewCP": actualNewCp,
    "PerformanceNewCP": performanceNewCp,
  };
}
