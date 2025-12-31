import 'package:k3h_erp_app/utils/common_function.dart';

class DeductionMasterModel {
  int deductionMasterId;
  String uniquekey;
  String name;
  String type;
  int value;
  int branchMasterId;
  String branchName;
  int minSalary;
  int maxSalary;
  String gender;
  int stateMasterId;
  String stateName;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DeductionMasterModel({
    required this.deductionMasterId,
    required this.uniquekey,
    required this.name,
    required this.type,
    required this.value,
    required this.branchMasterId,
    required this.branchName,
    required this.minSalary,
    required this.maxSalary,
    required this.gender,
    required this.stateMasterId,
    required this.stateName,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DeductionMasterModel.fromJson(Map<String, dynamic> json) =>
      DeductionMasterModel(
        deductionMasterId: json["DeductionMasterId"],
        uniquekey: parseValue<String>(json, "Uniquekey"),
        name: parseValue<String>(json, "Name"),
        type: parseValue<String>(json, "Type"),
        value: parseValue<int>(json, "Value"),
        branchMasterId: parseValue<int>(json, "BranchMasterId"),
        branchName: parseValue<String>(json, "BranchName"),
        minSalary: parseValue<int>(json, "MinSalary"),
        maxSalary: parseValue<int>(json, "MaxSalary"),
        gender: parseValue<String>(json, "Gender"),
        stateMasterId: parseValue<int>(json, "StateMasterId"),
        stateName: parseValue<String>(json, "StateName"),
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
    "DeductionMasterId": deductionMasterId,
    "Uniquekey": uniquekey,
    "Name": name,
    "Type": type,
    "Value": value,
    "BranchMasterId": branchMasterId,
    "BranchName": branchName,
    "MinSalary": minSalary,
    "MaxSalary": maxSalary,
    "Gender": gender,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
