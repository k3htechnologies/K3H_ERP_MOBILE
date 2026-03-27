import 'package:k3h_erp_app/utils/common_function.dart';

class ApprovalLogHistory {
  String employeeCode;
  String fullName;
  String emailId;
  String officeEmailId;
  String personalMobileNumber;
  String department;
  String designation;
  String branch;
  String approvalStatus;
  String remarks;
  DateTime? date;

  ApprovalLogHistory({
    required this.employeeCode,
    required this.fullName,
    required this.emailId,
    required this.officeEmailId,
    required this.personalMobileNumber,
    required this.department,
    required this.designation,
    required this.branch,
    required this.approvalStatus,
    required this.remarks,
    required this.date,
  });

  factory ApprovalLogHistory.fromJson(Map<String, dynamic> json) =>
      ApprovalLogHistory(
        employeeCode: parseValue<String>(json, "EmployeeCode"),
        fullName: parseValue<String>(json, "FullName"),
        emailId: parseValue<String>(json, "EmailId"),
        officeEmailId: parseValue<String>(json, "OfficeEmailId"),
        personalMobileNumber: parseValue<String>(json, "PersonalMobileNumber"),
        department: parseValue<String>(json, "Department"),
        designation: parseValue<String>(json, "Designation"),
        branch: parseValue<String>(json, "Branch"),
        approvalStatus: parseValue<String>(json, "ApprovalStatus"),
        remarks: parseValue<String>(json, "Remarks"),
        date: json["Date"] != null ? DateTime.parse(json["Date"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "EmployeeCode": employeeCode,
    "FullName": fullName,
    "EmailId": emailId,
    "OfficeEmailId": officeEmailId,
    "PersonalMobileNumber": personalMobileNumber,
    "Department": department,
    "Designation": designation,
    "Branch": branch,
    "ApprovalStatus": approvalStatus,
    "Remarks": remarks,
    "Date": date?.toIso8601String(),
  };
}
