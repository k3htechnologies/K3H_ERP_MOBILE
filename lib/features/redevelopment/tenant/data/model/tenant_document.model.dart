import 'package:k3h_erp_app/utils/common_function.dart';

class TenantDocumentModel {
  int tenantDocumentId;
  String uniquekey;
  int tenantId;
  int buildingId;
  int projectId;
  String documentName;
  String documentUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TenantDocumentModel({
    required this.tenantDocumentId,
    required this.uniquekey,
    required this.tenantId,
    required this.buildingId,
    required this.projectId,
    required this.documentName,
    required this.documentUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TenantDocumentModel.fromJson(Map<String, dynamic> json) =>
      TenantDocumentModel(
        tenantDocumentId: parseValue<int>(json, "TenantDocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        tenantId: parseValue<int>(json, "TenantId"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        documentName: parseValue<String>(json, "DocumentName"),
        documentUrl: parseValue<String>(json, "DocumentURL"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "TenantDocumentId": tenantDocumentId,
    "Uniquekey": uniquekey,
    "TenantId": tenantId,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "DocumentName": documentName,
    "DocumentURL": documentUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}