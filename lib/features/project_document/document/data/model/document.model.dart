import 'package:k3h_erp_app/utils/common_function.dart';

class DocumentModel {
  int projectDocumentId;
  String uniquekey;
  int projectId;
  String projectDocumentName;
  int projectDocumentCategoryId;
  String projectDocumentCategory;
  DateTime? projectDocumentExpiryDate;
  String projectDocumentRemark;
  String projectDocumentStatus;
  String projectDocumentURL;
  String projectDocumentApprovalStatus;
  int uploadedProjectDocumentCount;
  int approvalPendingProjectDocumentCount;
  int rejectedProjectDocumentCount;
  bool isApproval;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DocumentModel({
    required this.projectDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.projectDocumentName,
    required this.projectDocumentCategoryId,
    required this.projectDocumentCategory,
    required this.projectDocumentExpiryDate,
    required this.projectDocumentRemark,
    required this.projectDocumentStatus,
    required this.projectDocumentURL,
    required this.projectDocumentApprovalStatus,
    required this.uploadedProjectDocumentCount,
    required this.approvalPendingProjectDocumentCount,
    required this.rejectedProjectDocumentCount,
    required this.isApproval,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    projectDocumentId: parseValue<int>(json, "ProjectDocumentId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    projectDocumentName: parseValue<String>(json, "ProjectDocumentName"),
    projectDocumentCategoryId: parseValue<int>(
      json,
      "ProjectDocumentCategoryId",
    ),
    projectDocumentCategory: parseValue<String>(
      json,
      "ProjectDocumentCategory",
    ),
    projectDocumentExpiryDate:
        json["ProjectDocumentExpiryDate"] == null
            ? null
            : parseValue<DateTime>(json, "ProjectDocumentExpiryDate"),
    projectDocumentRemark: parseValue<String>(json, "ProjectDocumentRemark"),
    projectDocumentStatus: parseValue<String>(json, "ProjectDocumentStatus"),
    projectDocumentURL: parseValue<String>(json, "ProjectDocumentURL"),
    projectDocumentApprovalStatus: parseValue<String>(
      json,
      "ProjectDocumentApprovalStatus",
    ),
    uploadedProjectDocumentCount: parseValue<int>(
      json,
      "UploadedProjectDocumentCount",
    ),
    approvalPendingProjectDocumentCount: parseValue<int>(
      json,
      "ApprovalPendingProjectDocumentCount",
    ),
    rejectedProjectDocumentCount: parseValue<int>(
      json,
      "RejectedProjectDocumentCount",
    ),
    isApproval: parseValue<bool>(json, "IsApproval"),
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
    "ProjectDocumentId": projectDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectDocumentName": projectDocumentName,
    "ProjectDocumentCategoryId": projectDocumentCategoryId,
    "ProjectDocumentCategory": projectDocumentCategory,
    "ProjectDocumentExpiryDate": projectDocumentExpiryDate?.toIso8601String(),
    "ProjectDocumentRemark": projectDocumentRemark,
    "ProjectDocumentStatus": projectDocumentStatus,
    "ProjectDocumentURL": projectDocumentURL,
    "ProjectDocumentApprovalStatus": projectDocumentApprovalStatus,
    "UploadedProjectDocumentCount": uploadedProjectDocumentCount,
    "ApprovalPendingProjectDocumentCount": approvalPendingProjectDocumentCount,
    "RejectedProjectDocumentCount": rejectedProjectDocumentCount,
    "IsApproval": isApproval,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
