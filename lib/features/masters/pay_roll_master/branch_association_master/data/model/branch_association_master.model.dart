import 'package:k3h_erp_app/utils/common_function.dart';

class BranchAssociationModel {
  int branchAssociationsId;
  String uniquekey;
  String branchName;
  String branchMasterId;
  int employeeId;
  String employeeName;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BranchAssociationModel({
    required this.branchAssociationsId,
    required this.uniquekey,
    required this.branchName,
    required this.branchMasterId,
    required this.employeeId,
    required this.employeeName,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BranchAssociationModel.fromJson(Map<String, dynamic> json) =>
      BranchAssociationModel(
        branchAssociationsId: parseValue<int>(json,"BranchAssociationsId"),
        uniquekey: parseValue<String>(json,"Uniquekey"),
        branchName: parseValue<String>(json,"BranchName"),
        branchMasterId: parseValue<String>(json,"BranchMasterId"),
        employeeId: parseValue<int>(json,"EmployeeId"),
        employeeName: parseValue<String>(json,"EmployeeName"),
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
    "BranchAssociationsId": branchAssociationsId,
    "Uniquekey": uniquekey,
    "BranchName": branchName,
    "BranchMasterId": branchMasterId,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}