import 'package:k3h_erp_app/utils/functions/common_function.dart';

class LeaveTypeModel {
  int leaveTypeMasterId;
  String uniquekey;
  String leaveType;
  String leaveTypeCode;
  bool isCarryForward;
  int maxCarryForward;
  bool isEncashable;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LeaveTypeModel({
    required this.leaveTypeMasterId,
    required this.uniquekey,
    required this.leaveType,
    required this.leaveTypeCode,
    required this.isCarryForward,
    required this.maxCarryForward,
    required this.isEncashable,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) => LeaveTypeModel(
    leaveTypeMasterId: parseValue<int>(json, "LeaveTypeMasterId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    leaveType: parseValue<String>(json, "LeaveType"),
    leaveTypeCode: parseValue<String>(json, "LeaveTypeCode"),
    isCarryForward: parseValue<bool>(json, "IsCarryForward"),
    maxCarryForward: parseValue<int>(json, "MaxCarryForward"),
    isEncashable: parseValue<bool>(json, "IsEncashable"),
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
    "LeaveTypeMasterId": leaveTypeMasterId,
    "Uniquekey": uniquekey,
    "LeaveType": leaveType,
    "LeaveTypeCode": leaveTypeCode,
    "IsCarryForward": isCarryForward,
    "MaxCarryForward": maxCarryForward,
    "IsEncashable": isEncashable,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
