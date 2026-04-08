import 'package:k3h_erp_app/utils/common_function.dart';

class PurchaseOrderModel {
  int materialRequisitionPurchaseOrderId;
  String uniquekey;
  int materialRequisitionId;
  String purchaseOrderUrl;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  PurchaseOrderModel({
    required this.materialRequisitionPurchaseOrderId,
    required this.uniquekey,
    required this.materialRequisitionId,
    required this.purchaseOrderUrl,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderModel(
        materialRequisitionPurchaseOrderId: parseValue<int>(
          json,
          "MaterialRequisitionPurchaseOrderId",
        ),
        uniquekey: parseValue<String>(json, 'Uniquekey'),
        materialRequisitionId: parseValue<int>(json, 'MaterialRequisitionId'),
        purchaseOrderUrl: parseValue<String>(json, 'PurchaseOrderURL'),
        clientRegistrationId: parseValue<int>(json, 'ClientRegistrationId'),
        createdById: parseValue<int>(json, 'CreatedById'),
        createdBy: parseValue<String>(json, 'CreatedBy'),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, 'ModifiedById'),
        modifiedBy: parseValue<String>(json, 'ModifiedBy'),
        modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionPurchaseOrderId": materialRequisitionPurchaseOrderId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionId": materialRequisitionId,
    "PurchaseOrderURL": purchaseOrderUrl,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
