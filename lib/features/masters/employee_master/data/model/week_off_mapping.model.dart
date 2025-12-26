// To parse this JSON data, do
//
//     final weekOffMappingModel = weekOffMappingModelFromJson(jsonString);

import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

WeekOffMappingModel weekOffMappingModelFromJson(String str) =>
    WeekOffMappingModel.fromJson(json.decode(str));

String weekOffMappingModelToJson(WeekOffMappingModel data) =>
    json.encode(data.toJson());

class WeekOffMappingModel {
  int weekOffPolicyMasterMappingId;
  String uniquekey;
  String departmentMasterId;
  String departmentName;
  String employeeId;
  String employeeName;
  int weekOffPolicyMasterId;
  String weekOffPolicyCode;
  String weekOffPolicyName;
  int weekDays;
  String weekDaysStartsOn;
  String weeklyOff;
  String weeklyOff2;
  String weeklyOff2Type;
  String notApplicableForMonths;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  WeekOffMappingModel({
    required this.weekOffPolicyMasterMappingId,
    required this.uniquekey,
    required this.departmentMasterId,
    required this.departmentName,
    required this.employeeId,
    required this.employeeName,
    required this.weekOffPolicyMasterId,
    required this.weekOffPolicyCode,
    required this.weekOffPolicyName,
    required this.weekDays,
    required this.weekDaysStartsOn,
    required this.weeklyOff,
    required this.weeklyOff2,
    required this.weeklyOff2Type,
    required this.notApplicableForMonths,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory WeekOffMappingModel.fromJson(Map<String, dynamic> json) =>
      WeekOffMappingModel(
        weekOffPolicyMasterMappingId: parseValue<int>(
          json,
          "WeekOffPolicyMasterMappingId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        departmentMasterId: parseValue<String>(json, "DepartmentMasterId"),
        departmentName: parseValue<String>(json, "DepartmentName"),
        employeeId: parseValue<String>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        weekOffPolicyMasterId: parseValue<int>(json, "WeekOffPolicyMasterId"),
        weekOffPolicyCode: parseValue<String>(json, "WeekOffPolicyCode"),
        weekOffPolicyName: parseValue<String>(json, "WeekOffPolicyName"),
        weekDays: parseValue<int>(json, "WeekDays"),
        weekDaysStartsOn: parseValue<String>(json, "WeekDaysStartsOn"),
        weeklyOff: parseValue<String>(json, "WeeklyOff"),
        weeklyOff2: parseValue<String>(json, "WeeklyOff2"),
        weeklyOff2Type: parseValue<String>(json, "WeeklyOff2Type"),
        notApplicableForMonths: parseValue<String>(
          json,
          "NotApplicableForMonths",
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
    "WeekOffPolicyMasterMappingId": weekOffPolicyMasterMappingId,
    "Uniquekey": uniquekey,
    "DepartmentMasterId": departmentMasterId,
    "DepartmentName": departmentName,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "WeekOffPolicyMasterId": weekOffPolicyMasterId,
    "WeekOffPolicyCode": weekOffPolicyCode,
    "WeekOffPolicyName": weekOffPolicyName,
    "WeekDays": weekDays,
    "WeekDaysStartsOn": weekDaysStartsOn,
    "WeeklyOff": weeklyOff,
    "WeeklyOff2": weeklyOff2,
    "WeeklyOff2Type": weeklyOff2Type,
    "NotApplicableForMonths": notApplicableForMonths,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
