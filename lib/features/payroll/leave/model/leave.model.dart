import 'package:k3h_erp_app/utils/common_function.dart';

class LeaveModel {
  int leaveId;
  String uniquekey;
  int leaveTypeMasterId;
  String leaveType;
  String leaveTypeCode;
  DateTime startDate;
  DateTime endDate;
  String startDateLeaveDuration;
  String endDateLeaveDuration;
  double noOfDays;
  String reason;
  String leaveDocumentUrl;
  String leaveStatus;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LeaveModel({
    required this.leaveId,
    required this.uniquekey,
    required this.leaveTypeMasterId,
    required this.leaveType,
    required this.leaveTypeCode,
    required this.startDate,
    required this.endDate,
    required this.startDateLeaveDuration,
    required this.endDateLeaveDuration,
    required this.noOfDays,
    required this.reason,
    required this.leaveDocumentUrl,
    required this.leaveStatus,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    leaveId: parseValue<int>(json, "LeaveId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    leaveTypeMasterId: parseValue<int>(json, "LeaveTypeMasterId"),
    leaveType: parseValue<String>(json, "LeaveType"),
    leaveTypeCode: parseValue<String>(json, "LeaveTypeCode"),
    startDate: parseValue<DateTime>(json, "StartDate"),
    endDate: parseValue<DateTime>(json, "EndDate"),
    startDateLeaveDuration: parseValue<String>(json, "StartDateLeaveDuration"),
    endDateLeaveDuration: parseValue<String>(json, "EndDateLeaveDuration"),
    noOfDays: parseValue<double>(json, "NoOfDays"),
    reason: parseValue<String>(json, "Reason"),
    leaveDocumentUrl: parseValue<String>(json, "LeaveDocumentURL"),
    leaveStatus: parseValue<String>(json, "Status"),
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
    "LeaveId": leaveId,
    "Uniquekey": uniquekey,
    "LeaveTypeMasterId": leaveTypeMasterId,
    "LeaveType": leaveType,
    "LeaveTypeCode": leaveTypeCode,
    "StartDate": startDate.toIso8601String(),
    "EndDate": endDate.toIso8601String(),
    "StartDateLeaveDuration": startDateLeaveDuration,
    "EndDateLeaveDuration": endDateLeaveDuration,
    "NoOfDays": noOfDays,
    "Reason": reason,
    "LeaveDocumentURL": leaveDocumentUrl,
    "LeaveStatus": leaveStatus,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
