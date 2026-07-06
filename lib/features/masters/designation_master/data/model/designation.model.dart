import 'package:k3h_erp_app/utils/functions/common_function.dart';

class DesignationMasterModel {
  int designationMasterId;
  String uniquekey;
  String designationName;
  int noticePeriod;
  int probationPeriod;
  int numberOfEmployee;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  bool isSetAccessModule;

  DesignationMasterModel({
    required this.designationMasterId,
    required this.uniquekey,
    required this.designationName,
    required this.noticePeriod,
    required this.probationPeriod,
    required this.numberOfEmployee,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.isSetAccessModule,
  });

  factory DesignationMasterModel.fromJson(Map<String, dynamic> json) =>
      DesignationMasterModel(
        designationMasterId: parseValue<int>(json, "DesignationMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        designationName: parseValue<String>(json, "DesignationName"),
        noticePeriod: parseValue<int>(json, "NoticePeriod"),
        probationPeriod: parseValue<int>(json, "ProbationPeriod"),
        numberOfEmployee: parseValue<int>(json, "NumberOfEmployee"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
        isSetAccessModule: parseValue<bool>(json, "IsSetAccessModule"),
      );

  Map<String, dynamic> toJson() => {
    "DesignationMasterId": designationMasterId,
    "Uniquekey": uniquekey,
    "DesignationName": designationName,
    "NoticePeriod": noticePeriod,
    "ProbationPeriod": probationPeriod,
    "NumberOfEmployee": numberOfEmployee,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "IsSetAccessModule":isSetAccessModule
  };
}
