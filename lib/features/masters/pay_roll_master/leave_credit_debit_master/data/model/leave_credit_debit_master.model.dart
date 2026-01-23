import 'package:k3h_erp_app/utils/common_function.dart';

class LeaveCreditDebitMasterModel {
  int leaveCreditConfigurationId;
  String uniquekey;
  String leavePeriodMode;
  DateTime financialYearStartDate;
  DateTime financialYearEndDate;
  int departmentMasterId;
  String departmentName;
  String designationName;
  String designationId;
  List<LeaveBalanceType> leaveBalanceType;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LeaveCreditDebitMasterModel({
    required this.leaveCreditConfigurationId,
    required this.uniquekey,
    required this.leavePeriodMode,
    required this.financialYearStartDate,
    required this.financialYearEndDate,
    required this.departmentMasterId,
    required this.departmentName,
    required this.designationName,
    required this.designationId,
    required this.leaveBalanceType,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LeaveCreditDebitMasterModel.fromJson(Map<String, dynamic> json) =>
      LeaveCreditDebitMasterModel(
        leaveCreditConfigurationId: parseValue<int>(
          json,
          "LeaveCreditConfigurationId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        leavePeriodMode: parseValue<String>(json, "LeavePeriodMode"),
        financialYearStartDate: parseValue<DateTime>(
          json,
          "FinancialYearStartDate",
        ),
        financialYearEndDate: parseValue<DateTime>(
          json,
          "FinancialYearEndDate",
        ),
        departmentMasterId: parseValue<int>(json, "DepartmentMasterId"),
        departmentName: parseValue<String>(json, "DepartmentName"),
        designationName: parseValue<String>(json, "DesignationName"),
        designationId: parseValue<String>(json, "DesignationId"),
        leaveBalanceType: List<LeaveBalanceType>.from(
          json["LeaveBalanceType"].map((x) => LeaveBalanceType.fromJson(x)),
        ),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "LeaveCreditConfigurationId": leaveCreditConfigurationId,
    "Uniquekey": uniquekey,
    "LeavePeriodMode": leavePeriodMode,
    "FinancialYearStartDate": financialYearStartDate.toIso8601String(),
    "FinancialYearEndDate": financialYearEndDate.toIso8601String(),
    "DepartmentMasterId": departmentMasterId,
    "DepartmentName": departmentName,
    "DesignationName": designationName,
    "DesignationId": designationId,
    "LeaveBalanceType": List<dynamic>.from(
      leaveBalanceType.map((x) => x.toJson()),
    ),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class LeaveBalanceType {
  int leaveTypeBalanceId;
  int leaveTypeId;
  String leaveTypeName;
  int leaveCredit;
  int leaveCreditConfigurationId;

  LeaveBalanceType({
    required this.leaveTypeBalanceId,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.leaveCredit,
    required this.leaveCreditConfigurationId,
  });

  factory LeaveBalanceType.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceType(
        leaveTypeBalanceId: json["LeaveTypeBalanceId"],
        leaveTypeId: json["LeaveTypeId"],
        leaveTypeName: json["LeaveTypeName"],
        leaveCredit: json["LeaveCredit"],
        leaveCreditConfigurationId: json["LeaveCreditConfigurationId"],
      );

  Map<String, dynamic> toJson() => {
    "LeaveTypeBalanceId": leaveTypeBalanceId,
    "LeaveTypeId": leaveTypeId,
    "LeaveTypeName": leaveTypeName,
    "LeaveCredit": leaveCredit,
    "LeaveCreditConfigurationId": leaveCreditConfigurationId,
  };
}
