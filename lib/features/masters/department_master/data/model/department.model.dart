import 'package:k3h_erp_app/utils/common_function.dart';

class DepartmentModel  {
  int departmentMasterId;
  String uniquekey;
  String departmentCode;
  String departmentName;
  int numberOfEmployee;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DepartmentModel({
    required this.departmentMasterId,
    required this.uniquekey,
    required this.departmentCode,
    required this.departmentName,
    required this.numberOfEmployee,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        departmentMasterId: parseValue<int>(json, "DepartmentMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        departmentCode: parseValue<String>(json, "DepartmentCode"),
        departmentName: parseValue<String>(json, "DepartmentName"),
        numberOfEmployee: parseValue<int>(json, "NumberOfEmployee"),
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
    "DepartmentMasterId": departmentMasterId,
    "Uniquekey": uniquekey,
    "DepartmentCode": departmentCode,
    "DepartmentName": departmentName,
    "NumberOfEmployee": numberOfEmployee,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}