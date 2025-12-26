// To parse this JSON data, do
//
//     final shiftManagementMappingModel = shiftManagementMappingModelFromJson(jsonString);

import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

ShiftManagementMappingModel shiftManagementMappingModelFromJson(String str) =>
    ShiftManagementMappingModel.fromJson(json.decode(str));

String shiftManagementMappingModelToJson(ShiftManagementMappingModel data) =>
    json.encode(data.toJson());

class ShiftManagementMappingModel {
  int shiftManagementMasterMappingId;
  String uniquekey;
  String departmentMasterId;
  String departmentName;
  String employeeId;
  String employeeName;
  int shiftManagementMasterId;
  String shiftCode;
  String shiftName;
  String shiftBeginTime;
  String shiftEndTime;
  String shiftDurationTime;
  String shiftWorkDurationTime;
  String firstHalfUpTo;
  String absentWorkingHours;
  String halfDayWorkingHours;
  String halfDayInTimeAfter;
  String halfDayOutTimeBefore;
  String breakBeginTime;
  String breakEndTime;
  String breakDurationTime;
  String graceTime;
  String remarks;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  ShiftManagementMappingModel({
    required this.shiftManagementMasterMappingId,
    required this.uniquekey,
    required this.departmentMasterId,
    required this.departmentName,
    required this.employeeId,
    required this.employeeName,
    required this.shiftManagementMasterId,
    required this.shiftCode,
    required this.shiftName,
    required this.shiftBeginTime,
    required this.shiftEndTime,
    required this.shiftDurationTime,
    required this.shiftWorkDurationTime,
    required this.firstHalfUpTo,
    required this.absentWorkingHours,
    required this.halfDayWorkingHours,
    required this.halfDayInTimeAfter,
    required this.halfDayOutTimeBefore,
    required this.breakBeginTime,
    required this.breakEndTime,
    required this.breakDurationTime,
    required this.graceTime,
    required this.remarks,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ShiftManagementMappingModel.fromJson(
    Map<String, dynamic> json,
  ) => ShiftManagementMappingModel(
    shiftManagementMasterMappingId: parseValue<int>(
      json,
      "ShiftManagementMasterMappingId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    departmentMasterId: parseValue<String>(json, "DepartmentMasterId"),
    departmentName: parseValue<String>(json, "DepartmentName"),
    employeeId: parseValue<String>(json, "EmployeeId"),
    employeeName: parseValue<String>(json, "EmployeeName"),
    shiftManagementMasterId: parseValue<int>(json, "ShiftManagementMasterId"),
    shiftCode: parseValue<String>(json, "ShiftCode"),
    shiftName: parseValue<String>(json, "ShiftName"),
    shiftBeginTime: parseValue<String>(json, "ShiftBeginTime"),
    shiftEndTime: parseValue<String>(json, "ShiftEndTime"),
    shiftDurationTime: parseValue<String>(json, "ShiftDurationTime"),
    shiftWorkDurationTime: parseValue<String>(json, "ShiftWorkDurationTime"),
    firstHalfUpTo: parseValue<String>(json, "FirstHalfUpTo"),
    absentWorkingHours: parseValue<String>(json, "AbsentWorkingHours"),
    halfDayWorkingHours: parseValue<String>(json, "HalfDayWorkingHours"),
    halfDayInTimeAfter: parseValue<String>(json, "HalfDayInTimeAfter"),
    halfDayOutTimeBefore: parseValue<String>(json, "HalfDayOutTimeBefore"),
    breakBeginTime: parseValue<String>(json, "BreakBeginTime"),
    breakEndTime: parseValue<String>(json, "BreakEndTime"),
    breakDurationTime: parseValue<String>(json, "BreakDurationTime"),
    graceTime: parseValue<String>(json, "GraceTime"),
    remarks: parseValue<String>(json, "Remarks"),
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
    "ShiftManagementMasterMappingId": shiftManagementMasterMappingId,
    "Uniquekey": uniquekey,
    "DepartmentMasterId": departmentMasterId,
    "DepartmentName": departmentName,
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "ShiftManagementMasterId": shiftManagementMasterId,
    "ShiftCode": shiftCode,
    "ShiftName": shiftName,
    "ShiftBeginTime": shiftBeginTime,
    "ShiftEndTime": shiftEndTime,
    "ShiftDurationTime": shiftDurationTime,
    "ShiftWorkDurationTime": shiftWorkDurationTime,
    "FirstHalfUpTo": firstHalfUpTo,
    "AbsentWorkingHours": absentWorkingHours,
    "HalfDayWorkingHours": halfDayWorkingHours,
    "HalfDayInTimeAfter": halfDayInTimeAfter,
    "HalfDayOutTimeBefore": halfDayOutTimeBefore,
    "BreakBeginTime": breakBeginTime,
    "BreakEndTime": breakEndTime,
    "BreakDurationTime": breakDurationTime,
    "GraceTime": graceTime,
    "Remarks": remarks,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
