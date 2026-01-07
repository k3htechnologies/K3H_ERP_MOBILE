import 'package:k3h_erp_app/utils/common_function.dart';

class LeaveTypeModel {
  final int leaveTypeMasterId;
  final String uniqueKey;
  final String leaveType;
  final String leaveTypeCode;
  final bool isCarryForward;
  final int maxCarryForward;
  final bool isEncashable;

  const LeaveTypeModel({
    required this.leaveTypeMasterId,
    required this.uniqueKey,
    required this.leaveType,
    required this.leaveTypeCode,
    required this.isCarryForward,
    required this.maxCarryForward,
    required this.isEncashable,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      leaveTypeMasterId: parseValue<int>(json, "LeaveTypeMasterId"),
      uniqueKey: parseValue<String>(json, "Uniquekey"),
      leaveType: parseValue<String>(json, "LeaveType"),
      leaveTypeCode: parseValue<String>(json, "LeaveTypeCode"),
      isCarryForward: parseValue<bool>(json, "IsCarryForward"),
      maxCarryForward: parseValue<int>(json, "MaxCarryForward"),
      isEncashable: parseValue<bool>(json, "IsEncashable"),
    );
  }
  Map<String, dynamic> toJson() => {
    "LeaveTypeMasterId": leaveTypeMasterId,
    "Uniquekey": uniqueKey,
    "LeaveType": leaveType,
    "LeaveTypeCode": leaveTypeCode,
    "IsCarryForward": isCarryForward,
    "MaxCarryForward": maxCarryForward,
    "IsEncashable": isEncashable,
  };
}
