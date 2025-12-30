import 'package:k3h_erp_app/utils/common_function.dart';

class AssetMasterModel {
  int assetMasterId;
  String uniquekey;
  String assetCode;
  String assetName;
  String assetType;
  String assetModel;
  String assetBrand;
  String serialNumber;
  DateTime purchaseDate;
  DateTime? warrantyExpiryDate;
  double assetCost;
  String supplierName;
  String status;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  AssetMasterModel({
    required this.assetMasterId,
    required this.uniquekey,
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

  factory AssetMasterModel.fromJson(Map<String, dynamic> json) =>
      AssetMasterModel(
        assetMasterId: parseValue<int>(json, 'AssetMasterId'),
        uniquekey: parseValue<String>(json, 'Uniquekey'),
        assetCode: parseValue<String>(json, "AssetCode"),
        assetName: parseValue<String>(json, 'AssetName'),
        assetType: parseValue<String>(json, 'AssetType'),
        assetModel: parseValue<String>(json, 'AssetModel'),
        assetBrand: parseValue<String>(json, 'AssetBrand'),
        serialNumber: parseValue<String>(json, 'SerialNumber'),
        purchaseDate: parseValue<DateTime>(json, 'PurchaseDate'),
        warrantyExpiryDate:
        json["WarrantyExpiryDate"] == null
            ? null
            : DateTime.parse(json["WarrantyExpiryDate"]),
        assetCost: parseValue<double>(json, 'AssetCost'),
        supplierName: parseValue<String>(json, 'SupplierName'),
        status: parseValue<String>(json, 'Status'),
        createdById: parseValue(json, 'CreatedById'),
        createdBy: parseValue<String>(json, 'CreatedBy'),
        createdDate: parseValue<DateTime>(json, 'CreatedDate'),
        modifiedById: parseValue<int>(json, 'ModifiedById'),
        modifiedBy: parseValue<String>(json, 'ModifiedBy'),
        modifiedDate: json["ModifiedDate"] == null ? null : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "AssetMasterId": assetMasterId,
    "Uniquekey": uniquekey,
    "AssetCode": assetCode,
    "AssetName": assetName,
    "AssetType": assetType,
    "AssetModel": assetModel,
    "AssetBrand": assetBrand,
    "SerialNumber": serialNumber,
    "PurchaseDate": purchaseDate.toIso8601String(),
    "WarrantyExpiryDate": warrantyExpiryDate?.toIso8601String(),
    "AssetCost": assetCost,
    "SupplierName": supplierName,
    "Status": status,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}