import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

BranchMasterModel branchMasterModelFromJson(String str) =>
    BranchMasterModel.fromJson(json.decode(str));

String branchMasterModelToJson(BranchMasterModel data) =>
    json.encode(data.toJson());

class BranchMasterModel {
  int branchMasterId;
  String uniquekey;
  String branchCode;
  String branchName;
  bool isHeadOffice;
  String location;
  int numberOfEmployee;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BranchMasterModel({
    required this.branchMasterId,
    required this.uniquekey,
    required this.branchCode,
    required this.branchName,
    required this.isHeadOffice,
    required this.location,
    required this.numberOfEmployee,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BranchMasterModel.fromJson(Map<String, dynamic> json) =>
      BranchMasterModel(
        branchMasterId: parseValue<int>(json, "BranchMasterId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        branchCode: parseValue<String>(json, "BranchCode"),
        branchName: parseValue<String>(json, "BranchName"),
        isHeadOffice: parseValue<bool>(json, "IsHeadOffice"),
        location: parseValue<String>(json, "Location"),
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
      );

  Map<String, dynamic> toJson() => {
    "BranchMasterId": branchMasterId,
    "Uniquekey": uniquekey,
    "BranchCode": branchCode,
    "BranchName": branchName,
    "IsHeadOffice": isHeadOffice,
    "Location": location,
    "NumberOfEmployee": numberOfEmployee,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}