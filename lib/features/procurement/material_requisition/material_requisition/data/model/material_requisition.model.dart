import 'package:k3h_erp_app/utils/functions/common_function.dart';

class MaterialRequisitionModel {
  int materialRequisitionId;
  String uniquekey;
  String systemGeneratedCode;
  String materialRequisitionType;
  int projectId;
  String projectName;
  String projectLocation;
  String companyName;
  String companyGSTNumber;
  String companyPANNumber;
  String closeCompletionRemark;
  String attachmentsURL;
  String remarks;
  int clientRegistrationId;
  String materialRequisitionStatus;
  bool isSplit;
  bool isCopy;
  bool isRequisitionAction;
  bool isApproval;
  String approvalStatus;
  int createdById;
  String createdBy;
  DateTime createdDate;
  String department;
  int departmentMasterId;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  double paidAmount;
  double tdsPaidAmount;
  double totalPoAmount;
  double totalInvoiceAmount;
  int totalInvoice;
  String purchaseOrderURL;

  List<MaterialRequisitionDetailModel> materialRequisitionDetailData;

  MaterialRequisitionModel({
    required this.materialRequisitionId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.materialRequisitionType,
    required this.projectId,
    required this.projectName,
    required this.projectLocation,
    required this.companyName,
    required this.companyGSTNumber,
    required this.companyPANNumber,
    required this.closeCompletionRemark,
    required this.attachmentsURL,
    required this.remarks,
    required this.clientRegistrationId,
    required this.materialRequisitionStatus,
    required this.isSplit,
    required this.isCopy,
    required this.isRequisitionAction,
    required this.isApproval,
    required this.approvalStatus,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.department,
    required this.departmentMasterId,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.paidAmount,
    required this.tdsPaidAmount,
    required this.totalPoAmount,
    required this.totalInvoiceAmount,
    required this.totalInvoice,
    required this.purchaseOrderURL,
    required this.materialRequisitionDetailData,
  });

  factory MaterialRequisitionModel.fromJson(Map<String, dynamic> json) =>
      MaterialRequisitionModel(
        materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
        materialRequisitionType: parseValue<String>(
          json,
          "MaterialRequisitionType",
        ),
        projectId: parseValue<int>(json, "ProjectId"),
        projectName: parseValue<String>(json, "ProjectName"),
        projectLocation: parseValue<String>(json, "ProjectLocation"),
        companyName: parseValue<String>(json, "CompanyName"),
        companyGSTNumber: parseValue<String>(json, "CompanyGSTNumber"),
        companyPANNumber: parseValue<String>(json, "CompanyPANNumber"),
        closeCompletionRemark: parseValue<String>(
          json,
          "CloseCompletionRemark",
        ),
        attachmentsURL: parseValue<String>(json, "AttachmentsURL"),
        remarks: parseValue<String>(json, "Remarks"),
        clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
        materialRequisitionStatus: parseValue<String>(
          json,
          "MaterialRequisitionStatus",
        ),
        isSplit: parseValue<bool>(json, "IsSplit"),
        isCopy: parseValue<bool>(json, "IsCopy"),
        isRequisitionAction: parseValue<bool>(json, "IsRequisitionAction"),
        isApproval: parseValue<bool>(json, "IsApproval"),
        approvalStatus: parseValue<String>(json, "ApprovalStatus"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        department: parseValue<String>(json, "Department"),
        departmentMasterId: parseValue<int>(json, "DepartmentMasterId"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
        paidAmount: parseValue<double>(json, "PaidAmount"),
        tdsPaidAmount: parseValue<double>(json, "TDSPaidAmount"),
        totalPoAmount: parseValue<double>(json, "TotalPoAmount"),
        totalInvoiceAmount: parseValue<double>(json, "TotalInvoiceAmount"),
        totalInvoice: parseValue<int>(json, "TotalInvoice"),
        purchaseOrderURL: parseValue<String>(json, "PurchaseOrderURL"),
        materialRequisitionDetailData:
            (json["MaterialRequisitionDetailData"] as List? ?? [])
                .map((e) => MaterialRequisitionDetailModel.fromJson(e))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionId": materialRequisitionId,
    "Uniquekey": uniquekey,
    "SystemGeneratedCode": systemGeneratedCode,
    "MaterialRequisitionType": materialRequisitionType,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "ProjectLocation": projectLocation,
    "CompanyName": companyName,
    "CompanyGSTNumber": companyGSTNumber,
    "CompanyPANNumber": companyPANNumber,
    "CloseCompletionRemark": closeCompletionRemark,
    "AttachmentsURL": attachmentsURL,
    "Remarks": remarks,
    "ClientRegistrationId": clientRegistrationId,
    "MaterialRequisitionStatus": materialRequisitionStatus,
    "IsSplit": isSplit,
    "IsCopy": isCopy,
    "IsRequisitionAction": isRequisitionAction,
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "Department": department,
    "DepartmentMasterId": departmentMasterId,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "PaidAmount": paidAmount,
    "TDSPaidAmount": tdsPaidAmount,
    "TotalPoAmount": totalPoAmount,
    "TotalInvoiceAmount": totalInvoiceAmount,
    "TotalInvoice": totalInvoice,
    "PurchaseOrderURL": purchaseOrderURL,
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
  String remark;
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
    required this.remark,
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
        remark: parseValue<String>(json, "Remark"),
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
    "Remark": remark,
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
    'Remark': remark,
  };
}
