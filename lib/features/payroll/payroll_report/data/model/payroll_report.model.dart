import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class PayrollApprovalModel {
  int employeeId;
  int levelNum;
  int payrollApprovalId;
  String approvalStatus;
  int? payrollRequestId;
  String moduleName;
  String remark;
  String employeeName;
  DateTime? createdDate;

  PayrollApprovalModel({
    required this.employeeId,
    required this.levelNum,
    required this.payrollApprovalId,
    required this.approvalStatus,
    required this.payrollRequestId,
    required this.moduleName,
    required this.remark,
    required this.employeeName,
    required this.createdDate,
  });

  /// -------------------- FROM JSON --------------------
  factory PayrollApprovalModel.fromJson(Map<String, dynamic> json) {
    return PayrollApprovalModel(
      employeeId: parseValue<int>(json, "EmployeeId"),
      levelNum: parseValue<int>(json, "LevelNum"),
      payrollApprovalId: parseValue<int>(json, "PayrollApprovalId"),
      approvalStatus: parseValue<String>(json, "ApprovalStatus"),
      payrollRequestId: json["PayrollRequestId"],
      moduleName: parseValue<String>(json, "ModuleName"),
      remark: parseValue<String>(json, "Remark"),
      employeeName: parseValue<String>(json, "EmployeeName"),
      createdDate:
          json["Date"] != null ? DateTime.parse(json["CreatedDate"]) : null,
    );
  }

  /// -------------------- TO JSON --------------------
  Map<String, dynamic> toJson() {
    return {
      "EmployeeId": employeeId,
      "LevelNum": levelNum,
      "PayrollApprovalId": payrollApprovalId,
      "ApprovalStatus": approvalStatus,
      "PayrollRequestId": payrollRequestId,
      "ModuleName": moduleName,
      "Remark": remark,
      "EmployeeName": employeeName,
      "CreatedDate": createdDate?.toIso8601String(),
    };
  }
}

extension PayrollApprovalMapper on PayrollApprovalModel {
  ApprovalLogHistory toApprovalLogHistory() {
    return ApprovalLogHistory(
      employeeCode: employeeId.toString(),
      fullName: employeeName,
      emailId: "",
      officeEmailId: "",
      personalMobileNumber: "",
      department: "",
      designation: "",
      branch: "",
      approvalStatus: approvalStatus,
      remarks: remark,
      date: createdDate,
    );
  }
}

extension PayrollApprovalListMapper on List<PayrollApprovalModel> {
  List<ApprovalLogHistory> toApprovalLogHistoryList() {
    return map((e) => e.toApprovalLogHistory()).toList();
  }
}
