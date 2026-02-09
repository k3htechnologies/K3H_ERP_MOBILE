import 'package:k3h_erp_app/utils/common_function.dart';

class TargetModel {
  int saleTargetId;
  String uniquekey;
  int projectId;
  int employeeId;
  String employeeName;
  String mobileNumber;
  DateTime targetMonth;
  int plannedTarget;
  int achievedTarget;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TargetModel({
    required this.saleTargetId,
    required this.uniquekey,
    required this.projectId,
    required this.employeeId,
    required this.employeeName,
    required this.mobileNumber,
    required this.targetMonth,
    required this.plannedTarget,
    required this.achievedTarget,
    required this.createdById,
    required this.createdBy,
    this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory TargetModel.fromJson(Map<String, dynamic> json) =>
      TargetModel(
        saleTargetId: parseValue<int>(json, "SaleTargetId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        targetMonth: parseValue<DateTime>(json, "TargetMonth"),
        plannedTarget: parseValue<int>(json, "PlannedTarget"),
        achievedTarget: parseValue<int>(json, "AchievedTarget"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
        json["CreatedDate"] == null
            ? null
            : DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "SaleTargetId": saleTargetId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "MobileNumber": mobileNumber,
    "TargetMonth": targetMonth.toIso8601String(),
    "PlannedTarget": plannedTarget,
    "AchievedTarget": achievedTarget,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}