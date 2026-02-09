import 'package:k3h_erp_app/utils/common_function.dart';

class EmployeeExperienceDetailsModel {
  int employeeExperienceDetailsId;
  String uniquekey;
  int employeeId;
  String companyName;
  String role;
  String tenure;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  EmployeeExperienceDetailsModel({
    required this.employeeExperienceDetailsId,
    required this.uniquekey,
    required this.employeeId,
    required this.companyName,
    required this.role,
    required this.tenure,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory EmployeeExperienceDetailsModel.fromJson(Map<String, dynamic> json) =>
      EmployeeExperienceDetailsModel(
        employeeExperienceDetailsId: parseValue<int>(
          json,
          "EmployeeExperienceDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        employeeId: parseValue<int>(json, "EmployeeId"),
        companyName: parseValue<String>(json, "CompanyName"),
        role: parseValue<String>(json, "Role"),
        tenure: parseValue<String>(json, "Tenure"),
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
    "EmployeeExperienceDetailsId": employeeExperienceDetailsId,
    "Uniquekey": uniquekey,
    "EmployeeId": employeeId,
    "CompanyName": companyName,
    "Role": role,
    "Tenure": tenure,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
