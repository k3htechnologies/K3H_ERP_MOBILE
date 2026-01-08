import 'package:k3h_erp_app/utils/common_function.dart';

class ShiftMasterModel {
  final int shiftManagementMasterId;
  final String uniqueKey;
  final String shiftCode;
  final String shiftName;
  final String shiftBeginTime;
  final String shiftEndTime;
  final String shiftDurationTime;
  final String shiftWorkDurationTime;
  final String firstHalfUpTo;
  final String absentWorkingHours;
  final String halfDayWorkingHours;
  final String halfDayInTimeAfter;
  final String halfDayOutTimeBefore;
  final String breakBeginTime;
  final String breakEndTime;
  final String breakDurationTime;
  final String graceTime;
  final String remarks;
  final String createdBy;
  final DateTime createdDate;
  final String modifiedBy;
  final DateTime modifiedDate;

  ShiftMasterModel({
    required this.shiftManagementMasterId,
    required this.uniqueKey,
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
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ShiftMasterModel.fromJson(Map<String, dynamic> json) {
    return ShiftMasterModel(
      shiftManagementMasterId: parseValue<int>(json, "ShiftManagementMasterId"),
      uniqueKey: parseValue<String>(json, "Uniquekey"),
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
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: parseValue<DateTime>(json, "CreatedDate"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
    );
  }

  Map<String, dynamic> toJson() => {
    "ShiftManagementMasterId": shiftManagementMasterId,
    "Uniquekey": uniqueKey,
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
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate.toIso8601String(),
  };
}
