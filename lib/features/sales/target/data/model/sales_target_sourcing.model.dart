import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SalesTargetSourcingModel {
  final String uniquekey;
  final int projectId;
  final int employeeId;
  final String employeeName;
  final String designationName;
  final int salesTargetSourcingId;
  final int walkinsByCp;
  final int freshVisits;
  final int revisits;
  final int bookings;
  final int totalMeetings;
  final int totalObm;
  final int totalObmFreshVisits;
  final int totalObmRevisits;
  final int totalIbm;
  final int uniqueCPs;
  final int activeCp;
  final int newCp;
  final DateTime fromDate;
  final DateTime toDate;
  final int createdById;
  final String createdBy;
  final String createdDate;
  final int modifiedById;
  final String modifiedBy;
  final dynamic modifiedDate;

  SalesTargetSourcingModel({
    required this.uniquekey,
    required this.projectId,
    required this.employeeId,
    required this.employeeName,
    required this.designationName,
    required this.salesTargetSourcingId,
    required this.walkinsByCp,
    required this.freshVisits,
    required this.revisits,
    required this.bookings,
    required this.totalMeetings,
    required this.totalObm,
    required this.totalObmFreshVisits,
    required this.totalObmRevisits,
    required this.totalIbm,
    required this.uniqueCPs,
    required this.activeCp,
    required this.newCp,
    required this.fromDate,
    required this.toDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory SalesTargetSourcingModel.fromJson(Map<String, dynamic> json) =>
      SalesTargetSourcingModel(
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        designationName: parseValue<String>(json, "DesignationName"),
        salesTargetSourcingId: parseValue<int>(json, "SalesTargetSourcingId"),
        walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
        freshVisits: parseValue<int>(json, "FreshVisits"),
        revisits: parseValue<int>(json, "Revisits"),
        bookings: parseValue<int>(json, "Bookings"),
        totalMeetings: parseValue<int>(json, "TotalMeetings"),
        totalObm: parseValue<int>(json, "TotalOBM"),
        totalObmFreshVisits: parseValue<int>(json, "TotalOBMFreshVisits"),
        totalObmRevisits: parseValue<int>(json, "TotalOBMRevisits"),
        totalIbm: parseValue<int>(json, "TotalIBM"),
        uniqueCPs: parseValue<int>(json, "UniqueCPs"),
        activeCp: parseValue<int>(json, "ActiveCP"),
        newCp: parseValue<int>(json, "NewCP"),
        fromDate: parseValue<DateTime>(json, "FromDate"),
        toDate: parseValue<DateTime>(json, "ToDate"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<String>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: parseValue<String>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "DesignationName": designationName,
    "SalesTargetSourcingId": salesTargetSourcingId,
    "WalkinsByCP": walkinsByCp,
    "FreshVisits": freshVisits,
    "Revisits": revisits,
    "Bookings": bookings,
    "TotalMeetings": totalMeetings,
    "TotalOBM": totalObm,
    "TotalOBMFreshVisits": totalObmFreshVisits,
    "TotalOBMRevisits": totalObmRevisits,
    "TotalIBM": totalIbm,
    "UniqueCPs": uniqueCPs,
    "ActiveCP": activeCp,
    "NewCP": newCp,
    "FromDate": fromDate.toIso8601String(),
    "ToDate": toDate.toIso8601String(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
