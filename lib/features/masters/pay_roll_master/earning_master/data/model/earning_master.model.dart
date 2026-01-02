import 'package:k3h_erp_app/utils/common_function.dart';

class EarningMasterModel {
  int earningMasterId;
  String uniquekey;
  String name;
  String type;
  double value;
  int branchMasterId;
  String branchName;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  EarningMasterModel({
    required this.earningMasterId,
    required this.uniquekey,
    required this.name,
    required this.type,
    required this.value,
    required this.branchMasterId,
    required this.branchName,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory EarningMasterModel.fromJson(Map<String, dynamic> json) =>
      EarningMasterModel(
        earningMasterId: parseValue<int>(json, "EarningMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        name: parseValue<String>(json, "Name"),
        type: parseValue<String>(json, "Type"),
        value: parseValue<double>(json, "Value"),
        branchMasterId: parseValue<int>(json, "BranchMasterId"),
        branchName: parseValue<String>(json, "BranchName"),
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
    "EarningMasterId": earningMasterId,
    "Uniquekey": uniquekey,
    "Name": name,
    "Type": type,
    "Value": value,
    "BranchMasterId": branchMasterId,
    "BranchName": branchName,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
