import 'package:k3h_erp_app/utils/functions/common_function.dart';

class LeaveEncashmentMasterModel {
  final int leaveEncashmentSlabId;
  final String uniqueKey;
  final String earningMasterName;
  final double minSalary;
  final double maxSalary;
  final double encashmentRate;
  final int createdById;
  final String createdBy;

  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  LeaveEncashmentMasterModel({
    required this.uniqueKey,
    required this.earningMasterName,
    required this.minSalary,
    required this.maxSalary,
    required this.encashmentRate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.leaveEncashmentSlabId,
  });

  factory LeaveEncashmentMasterModel.fromJson(Map<String, dynamic> json) {
    return LeaveEncashmentMasterModel(
      leaveEncashmentSlabId: parseValue<int>(
        json,
        "LeaveEncashmentMasterSlabsId",
      ),
      uniqueKey: parseValue<String>(json, "Uniquekey"),
      earningMasterName: parseValue<String>(json, "EarningMasterName"),
      minSalary: parseValue<double>(json, "MinSalary"),
      maxSalary: parseValue<double>(json, "MaxSalary"),
      encashmentRate: parseValue<double>(json, "EncashmentRate"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue(json, "CreatedBy"),
      createdDate: DateTime.parse(json["CreatedDate"]),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] == null
              ? null
              : DateTime.parse(json["ModifiedDate"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "LeaveEncashmentMasterSlabsId": leaveEncashmentSlabId,
    "Uniquekey": uniqueKey,
    "EarningMasterName": earningMasterName,
    "MinSalary": minSalary,
    "MaxSalary": maxSalary,
    "EncashmentRate": encashmentRate,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
