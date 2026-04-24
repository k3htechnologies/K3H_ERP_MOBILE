import 'package:k3h_erp_app/utils/common_function.dart';

class MaterialRequisitionModel {
  int materialRequisitionId;
  String uniquekey;
  String systemGeneratedCode;
  int projectId;
  String projectName;
  String attachmentsURL;
  String remarks;
  int clientRegistrationId;
  String materialRequisitionStage;
  String materialRequisitionStatus;
  String finalVendor;
  bool isSplit;
  bool isCopy;
  bool isRequisitionAction;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  double paidAmount;
  double totalPoAmount;
  double totalInoviceAmount;
  double totalInvoice;
  String purchaseOrderURL;
  bool isApprovalVendorFinalization;
  bool isApprovalInvoice;
  String vendorFinalizationApprovalStatus;
  String invoiceApprovalStatus;
  List<MaterialRequisitionDetailModel> materialRequisitionDetailData;

  MaterialRequisitionModel({
    required this.materialRequisitionId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.projectId,
    required this.projectName,
    required this.attachmentsURL,
    required this.remarks,
    required this.clientRegistrationId,
    required this.materialRequisitionStage,
    required this.materialRequisitionStatus,
    required this.finalVendor,
    required this.isSplit,
    required this.isCopy,
    required this.isRequisitionAction,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.paidAmount,
    required this.totalPoAmount,
    required this.totalInoviceAmount,
    required this.totalInvoice,
    required this.purchaseOrderURL,
    required this.isApprovalVendorFinalization,
    required this.isApprovalInvoice,
    required this.vendorFinalizationApprovalStatus,
    required this.invoiceApprovalStatus,
    required this.materialRequisitionDetailData,
  });

  factory MaterialRequisitionModel.fromJson(
    Map<String, dynamic> json,
  ) => MaterialRequisitionModel(
    materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    attachmentsURL: json["AttachmentsURL"],
    remarks: parseValue<String>(json, "Remarks"),
    clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
    materialRequisitionStage: parseValue<String>(
      json,
      "MaterialRequisitionStage",
    ),
    materialRequisitionStatus: parseValue<String>(
      json,
      "MaterialRequisitionStatus",
    ),
    finalVendor: parseValue<String>(json, "FinalVendor"),
    isSplit: parseValue<bool>(json, "IsSplit"),
    isCopy: parseValue<bool>(json, "IsCopy"),
    isRequisitionAction: parseValue<bool>(json, "IsRequisitionAction"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
    paidAmount: parseValue<double>(json, "PaidAmount"),
    totalPoAmount: parseValue<double>(json, "TotalPoAmount"),
    totalInoviceAmount: parseValue<double>(json, "TotalInvoiceAmount"),
    totalInvoice: parseValue<double>(json, "TotalInvoice"),
    purchaseOrderURL: parseValue<String>(json, "PurchaseOrderURL"),
    isApprovalVendorFinalization: parseValue<bool>(
      json,
      "IsApprovalVendorFinalization",
    ),
    isApprovalInvoice: parseValue<bool>(json, "IsApprovalInvoice"),
    vendorFinalizationApprovalStatus: parseValue<String>(
      json,
      "VendorFinalizationApprovalStatus",
    ),
    invoiceApprovalStatus: parseValue<String>(json, "InvoiceApprovalStatus"),
    materialRequisitionDetailData: List<MaterialRequisitionDetailModel>.from(
      json["MaterialRequisitionDetailData"].map(
        (e) => MaterialRequisitionDetailModel.fromJson(e),
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionId": materialRequisitionId,
    "Uniquekey": uniquekey,
    "SystemGeneratedCode": systemGeneratedCode,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "AttachmentsURL": attachmentsURL,
    "Remarks": remarks,
    "ClientRegistrationId": clientRegistrationId,
    "MaterialRequisitionStage": materialRequisitionStage,
    "MaterialRequisitionStatus": materialRequisitionStatus,
    "FinalVendor": finalVendor,
    "IsSplit": isSplit,
    "IsCopy": isCopy,
    "IsRequisitionAction": isRequisitionAction,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "PaidAmount": paidAmount,
    "TotalPoAmount": totalPoAmount,
    "TotalInvoiceAmount": totalInoviceAmount,
    "TotalInvoice": totalInvoice,
    "PurchaseOrderURL": purchaseOrderURL,
    "IsApprovalVendorFinalization": isApprovalVendorFinalization,
    "IsApprovalInvoice": isApprovalInvoice,
    "VendorFinalizationApprovalStatus": vendorFinalizationApprovalStatus,
    "InvoiceApprovalStatus": invoiceApprovalStatus,
    "MaterialRequisitionDetailData":
        materialRequisitionDetailData.map((e) => e.toJson()).toList(),
  };
}

class MaterialRequisitionDetailModel {
  int materialRequisitionDetailId;
  String uniquekey;
  int materialMasterId;
  String materialName;
  String subMaterialName;
  int subMaterialMasterId;
  double materialQuantity;
  int uomMasterId;
  String uomCode;
  String uom;
  DateTime requiredDate;
  double materialReceivedQuantityTillDate;
  String remarks;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  MaterialRequisitionDetailModel({
    required this.materialRequisitionDetailId,
    required this.uniquekey,
    required this.materialMasterId,
    required this.materialName,
    required this.subMaterialName,
    required this.subMaterialMasterId,
    required this.materialQuantity,
    required this.uomMasterId,
    required this.uomCode,
    required this.uom,
    required this.requiredDate,
    required this.materialReceivedQuantityTillDate,
    required this.remarks,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory MaterialRequisitionDetailModel.fromJson(Map<String, dynamic> json) =>
      MaterialRequisitionDetailModel(
        materialRequisitionDetailId: parseValue<int>(
          json,
          "MaterialRequisitionDetailId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        materialMasterId: parseValue<int>(json, "MaterialMasterId"),
        materialName: parseValue<String>(json, "MaterialName"),
        subMaterialName: parseValue<String>(json, "SubMaterialName"),
        subMaterialMasterId: parseValue<int>(json, "SubMaterialMasterId"),
        materialQuantity: parseValue<double>(json, "MaterialQuantity"),
        uomMasterId: parseValue<int>(json, "UomMasterId"),
        uomCode: parseValue<String>(json, "UomCode"),
        uom: parseValue<String>(json, "Uom"),
        remarks: parseValue<String>(json, "Remarks"),
        requiredDate: parseValue<DateTime>(json, "RequiredDate"),
        materialReceivedQuantityTillDate: parseValue<double>(
          json,
          "MaterialReceivedQuantityTillDate",
        ),
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
    "MaterialRequisitionDetailId": materialRequisitionDetailId,
    "Uniquekey": uniquekey,
    "MaterialMasterId": materialMasterId,
    "MaterialName": materialName,
    "SubMaterialName": subMaterialName,
    "SubMaterialMasterId": subMaterialMasterId,
    "MaterialQuantity": materialQuantity,
    "UomMasterId": uomMasterId,
    "UomCode": uomCode,
    "Uom": uom,
    "RequiredDate": requiredDate.toIso8601String(),
    "MaterialReceivedQuantityTillDate": materialReceivedQuantityTillDate,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };

  Map<String, dynamic> toJsonPayload() => {
    'MaterialRequisitionDetailId': materialRequisitionDetailId,
    'SubMaterialMasterId': subMaterialMasterId,
    'MaterialQuantity': materialQuantity,
    'UomMasterId': uomMasterId,
    'RequiredDate': formatDateTimeForApi(requiredDate),
  };
}
