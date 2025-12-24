import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

EmployeeDocumentModel employeeDocumentModelFromJson(String str) =>
    EmployeeDocumentModel.fromJson(json.decode(str));

String employeeDocumentModelToJson(EmployeeDocumentModel data) =>
    json.encode(data.toJson());

class EmployeeDocumentModel {
  int employeeDocumentId;
  String uniquekey;
  int employeeId;
  String fullName;
  String documentName;
  String documentUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  EmployeeDocumentModel({
    required this.employeeDocumentId,
    required this.uniquekey,
    required this.employeeId,
    required this.fullName,
    required this.documentName,
    required this.documentUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory EmployeeDocumentModel.fromJson(Map<String, dynamic> json) =>
      EmployeeDocumentModel(
        employeeDocumentId: parseValue(json, "EmployeeDocumentId"),
        uniquekey: parseValue(json, "Uniquekey"),
        employeeId: parseValue(json, "EmployeeId"),
        fullName: parseValue(json, "FullName"),
        documentName: parseValue(json, "DocumentName"),
        documentUrl: parseValue(json, "DocumentURL"),
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
    "EmployeeDocumentId": employeeDocumentId,
    "Uniquekey": uniquekey,
    "EmployeeId": employeeId,
    "FullName": fullName,
    "DocumentName": documentName,
    "DocumentURL": documentUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
