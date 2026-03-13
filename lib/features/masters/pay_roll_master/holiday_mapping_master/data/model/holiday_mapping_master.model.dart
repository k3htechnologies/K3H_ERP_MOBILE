import 'package:k3h_erp_app/utils/common_function.dart';

class HolidayMappingModel {
  int holidayMappingMasterId;
  String uniquekey;
  int holidayMasterId;
  String holidayName;
  DateTime holidayDate;
  String branchName;
  String branchMasterId;
  String departmentName;
  String departmentMasterId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  HolidayMappingModel({
    required this.holidayMappingMasterId,
    required this.uniquekey,
    required this.holidayMasterId,
    required this.holidayName,
    required this.holidayDate,
    required this.branchName,
    required this.branchMasterId,
    required this.departmentName,
    required this.departmentMasterId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory HolidayMappingModel.fromJson(Map<String, dynamic> json) =>
      HolidayMappingModel(
        holidayMappingMasterId: parseValue<int>(json, "HolidayMappingMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        holidayMasterId: parseValue<int>(json, "HolidayMasterId"),
        holidayName: parseValue<String>(json, "HolidayName"),
        holidayDate: parseValue<DateTime>(json, "HolidayDate"),
        branchName: parseValue<String>(json, "BranchName"),
        branchMasterId: parseValue<String>(json, "BranchMasterId"),
        departmentName: parseValue<String>(json, "DepartmentName"),
        departmentMasterId: parseValue<String>(json, "DepartmentMasterId"),
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
    "HolidayMappingMasterId": holidayMappingMasterId,
    "Uniquekey": uniquekey,
    "HolidayMasterId": holidayMasterId,
    "HolidayName": holidayName,
    "HolidayDate": holidayDate.toIso8601String(),
    "BranchName": branchName,
    "BranchMasterId": branchMasterId,
    "DepartmentName": departmentName,
    "DepartmentMasterId": departmentMasterId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
