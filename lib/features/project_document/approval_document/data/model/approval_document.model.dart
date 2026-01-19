import 'package:k3h_erp_app/utils/common_function.dart';

class ApprovalDocumentModel {
  int approvalDocumentId;
  String uniquekey;
  int projectId;
  String approvalDocumentName;
  int approvalDocumentCategoryId;
  String approvalDocumentCategory;
  DateTime? approvalDocumentExpiryDate;
  String approvalDocumentRemark;
  String approvalDocumentStatus;
  String approvalDocumentURL;
  String approvalDocumentApprovalStatus;
  int uploadedApprovalDocumentCount;
  int approvalPendingApprovalDocumentCount;
  int rejectedApprovalDocumentCount;
  bool isApproval;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ApprovalDocumentModel({
    required this.approvalDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.approvalDocumentName,
    required this.approvalDocumentCategoryId,
    required this.approvalDocumentCategory,
    required this.approvalDocumentExpiryDate,
    required this.approvalDocumentRemark,
    required this.approvalDocumentStatus,
    required this.approvalDocumentURL,
    required this.approvalDocumentApprovalStatus,
    required this.uploadedApprovalDocumentCount,
    required this.approvalPendingApprovalDocumentCount,
    required this.rejectedApprovalDocumentCount,
    required this.isApproval,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ApprovalDocumentModel.fromJson(
    Map<String, dynamic> json,
  ) => ApprovalDocumentModel(
    approvalDocumentId: parseValue<int>(json, "ApprovalDocumentId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    approvalDocumentName: parseValue<String>(json, "ApprovalDocumentName"),
    approvalDocumentCategoryId: parseValue<int>(
      json,
      "ApprovalDocumentCategoryId",
    ),
    approvalDocumentCategory: parseValue<String>(
      json,
      "ApprovalDocumentCategory",
    ),
    approvalDocumentExpiryDate:
        json["ApprovalDocumentExpiryDate"] == null
            ? null
            : parseValue<DateTime>(json, "ApprovalDocumentExpiryDate"),
    approvalDocumentRemark: parseValue<String>(json, "ApprovalDocumentRemark"),
    approvalDocumentStatus: parseValue<String>(json, "ApprovalDocumentStatus"),
    approvalDocumentURL: parseValue<String>(json, "ApprovalDocumentURL"),
    approvalDocumentApprovalStatus: parseValue<String>(
      json,
      "ApprovalDocumentApprovalStatus",
    ),
    uploadedApprovalDocumentCount: parseValue<int>(
      json,
      "UploadedApprovalDocumentCount",
    ),
    approvalPendingApprovalDocumentCount: parseValue<int>(
      json,
      "ApprovalPendingApprovalDocumentCount",
    ),
    rejectedApprovalDocumentCount: parseValue<int>(
      json,
      "RejectedApprovalDocumentCount",
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
    "ApprovalDocumentId": approvalDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ApprovalDocumentName": approvalDocumentName,
    "ApprovalDocumentCategoryId": approvalDocumentCategoryId,
    "ApprovalDocumentCategory": approvalDocumentCategory,
    "ApprovalDocumentExpiryDate": approvalDocumentExpiryDate?.toIso8601String(),
    "ApprovalDocumentRemark": approvalDocumentRemark,
    "ApprovalDocumentStatus": approvalDocumentStatus,
    "ApprovalDocumentURL": approvalDocumentURL,
    "ApprovalDocumentApprovalStatus": approvalDocumentApprovalStatus,
    "UploadedApprovalDocumentCount": uploadedApprovalDocumentCount,
    "ApprovalPendingApprovalDocumentCount":
        approvalPendingApprovalDocumentCount,
    "RejectedApprovalDocumentCount": rejectedApprovalDocumentCount,
    "IsApproval": isApproval,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

extension ApprovalDocumentModelCopyWith on ApprovalDocumentModel {
  ApprovalDocumentModel copyWith({
    int? approvalDocumentId,
    String? uniquekey,
    int? projectId,
    String? approvalDocumentName,
    int? approvalDocumentCategoryId,
    String? approvalDocumentCategory,
    DateTime? approvalDocumentExpiryDate,
    String? approvalDocumentRemark,
    String? approvalDocumentStatus,
    String? approvalDocumentURL,
    String? approvalDocumentApprovalStatus,
    int? uploadedApprovalDocumentCount,
    int? approvalPendingApprovalDocumentCount,
    int? rejectedApprovalDocumentCount,
    bool? isApproval,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return ApprovalDocumentModel(
      approvalDocumentId: approvalDocumentId ?? this.approvalDocumentId,
      uniquekey: uniquekey ?? this.uniquekey,
      projectId: projectId ?? this.projectId,
      approvalDocumentName: approvalDocumentName ?? this.approvalDocumentName,
      approvalDocumentCategoryId:
          approvalDocumentCategoryId ?? this.approvalDocumentCategoryId,
      approvalDocumentCategory:
          approvalDocumentCategory ?? this.approvalDocumentCategory,
      approvalDocumentExpiryDate:
          approvalDocumentExpiryDate ?? this.approvalDocumentExpiryDate,
      approvalDocumentRemark:
          approvalDocumentRemark ?? this.approvalDocumentRemark,
      approvalDocumentStatus:
          approvalDocumentStatus ?? this.approvalDocumentStatus,
      approvalDocumentURL: approvalDocumentURL ?? this.approvalDocumentURL,
      approvalDocumentApprovalStatus:
          approvalDocumentApprovalStatus ?? this.approvalDocumentApprovalStatus,
      uploadedApprovalDocumentCount:
          uploadedApprovalDocumentCount ?? this.uploadedApprovalDocumentCount,
      approvalPendingApprovalDocumentCount:
          approvalPendingApprovalDocumentCount ??
          this.approvalPendingApprovalDocumentCount,
      rejectedApprovalDocumentCount:
          rejectedApprovalDocumentCount ?? this.rejectedApprovalDocumentCount,
      isApproval: isApproval ?? this.isApproval,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
