import 'package:k3h_erp_app/utils/common_function.dart';

class EmployeeEducationDetailsModel {
  int employeeEducationDetailsId;
  String uniquekey;
  int employeeId;
  String qualification;
  String collegeName;
  String passing;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  EmployeeEducationDetailsModel({
    required this.employeeEducationDetailsId,
    required this.uniquekey,
    required this.employeeId,
    required this.qualification,
    required this.collegeName,
    required this.passing,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory EmployeeEducationDetailsModel.fromJson(Map<String, dynamic> json) =>
      EmployeeEducationDetailsModel(
        employeeEducationDetailsId: parseValue<int>(
          json,
          "EmployeeEducationDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        employeeId: parseValue<int>(json, "EmployeeId"),
        qualification: parseValue<String>(json, "Qualification"),
        collegeName: parseValue<String>(json, "CollegeName"),
        passing: parseValue<String>(json, "Passing"),
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
    "EmployeeEducationDetailsId": employeeEducationDetailsId,
    "Uniquekey": uniquekey,
    "EmployeeId": employeeId,
    "Qualification": qualification,
    "CollegeName": collegeName,
    "Passing": passing,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
