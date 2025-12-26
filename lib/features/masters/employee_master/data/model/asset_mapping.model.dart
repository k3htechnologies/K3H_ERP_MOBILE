// To parse this JSON data, do
//
//     final assetMappingModel = assetMappingModelFromJson(jsonString);

import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

AssetMappingModel assetMappingModelFromJson(String str) =>
    AssetMappingModel.fromJson(json.decode(str));

String assetMappingModelToJson(AssetMappingModel data) =>
    json.encode(data.toJson());

class AssetMappingModel {
  int assetMasterMappingId;
  String uniquekey;
  DateTime assignedDate;
  int employeeId;
  String employeeName;
  DateTime returnDate;
  String conditionOnIssue;
  String conditionOnReturn;
  String remarks;
  int assetMasterId;
  String assetCode;
  String assetName;
  String assetType;
  String assetModel;
  String assetBrand;
  String serialNumber;
  DateTime purchaseDate;
  DateTime warrantyExpiryDate;
  int assetCost;
  String supplierName;
  String status;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  AssetMappingModel({
    required this.assetMasterMappingId,
    required this.uniquekey,
    required this.assignedDate,
    required this.employeeId,
    required this.employeeName,
    required this.returnDate,
    required this.conditionOnIssue,
    required this.conditionOnReturn,
    required this.remarks,
    required this.assetMasterId,
    required this.assetCode,
    required this.assetName,
    required this.assetType,
    required this.assetModel,
    required this.assetBrand,
    required this.serialNumber,
    required this.purchaseDate,
    required this.warrantyExpiryDate,
    required this.assetCost,
    required this.supplierName,
    required this.status,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory AssetMappingModel.fromJson(Map<String, dynamic> json) =>
      AssetMappingModel(
        assetMasterMappingId: parseValue<int>(json, "AssetMasterMappingId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        assignedDate: DateTime.parse(json["AssignedDate"]),
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        returnDate: DateTime.parse(json["ReturnDate"]),
        conditionOnIssue: parseValue<String>(json, "ConditionOnIssue"),
        conditionOnReturn: parseValue<String>(json, "ConditionOnReturn"),
        remarks: parseValue<String>(json, "Remarks"),
        assetMasterId: parseValue<int>(json, "AssetMasterId"),
        assetCode: parseValue<String>(json, "AssetCode"),
        assetName: parseValue<String>(json, "AssetName"),
        assetType: parseValue<String>(json, "AssetType"),
        assetModel: parseValue<String>(json, "AssetModel"),
        assetBrand: parseValue<String>(json, "AssetBrand"),
        serialNumber: parseValue<String>(json, "SerialNumber"),
        purchaseDate: DateTime.parse(json["PurchaseDate"]),
        warrantyExpiryDate: DateTime.parse(json["WarrantyExpiryDate"]),
        assetCost: parseValue<int>(json, "AssetCost"),
        supplierName: parseValue<String>(json, "SupplierName"),
        status: parseValue<String>(json, "Status"),
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
    "AssetMasterMappingId": assetMasterMappingId,
    "Uniquekey": uniquekey,
    "AssignedDate": assignedDate.toIso8601String(),
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "ReturnDate": returnDate.toIso8601String(),
    "ConditionOnIssue": conditionOnIssue,
    "ConditionOnReturn": conditionOnReturn,
    "Remarks": remarks,
    "AssetMasterId": assetMasterId,
    "AssetCode": assetCode,
    "AssetName": assetName,
    "AssetType": assetType,
    "AssetModel": assetModel,
    "AssetBrand": assetBrand,
    "SerialNumber": serialNumber,
    "PurchaseDate": purchaseDate.toIso8601String(),
    "WarrantyExpiryDate": warrantyExpiryDate.toIso8601String(),
    "AssetCost": assetCost,
    "SupplierName": supplierName,
    "Status": status,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate!.toIso8601String(),
  };
}
