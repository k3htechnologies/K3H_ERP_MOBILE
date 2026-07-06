import 'package:k3h_erp_app/utils/functions/common_function.dart';

class RERADocumentModel {
  int projectRERADocumentId;
  String uniquekey;
  int projectId;
  String projectRERADocumentName;
  int projectRERADocumentCategoryId;
  String projectRERADocumentCategory;
  String projectRERADocumentRemark;
  String projectRERADocumentStatus;
  String projectRERADocumentURL;
  String? reraPortalScreenShotURL;
  String projectRERADocumentApprovalStatus;
  int uploadedProjectRERADocumentCount;
  int approvalPendingProjectRERADocumentCount;
  int rejectedProjectRERADocumentCount;
  bool isApproval;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  RERADocumentModel({
    required this.projectRERADocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.projectRERADocumentName,
    required this.projectRERADocumentCategoryId,
    required this.projectRERADocumentCategory,
    required this.projectRERADocumentRemark,
    required this.projectRERADocumentStatus,
    required this.reraPortalScreenShotURL,
    required this.projectRERADocumentURL,
    required this.projectRERADocumentApprovalStatus,
    required this.uploadedProjectRERADocumentCount,
    required this.approvalPendingProjectRERADocumentCount,
    required this.rejectedProjectRERADocumentCount,
    required this.isApproval,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RERADocumentModel.fromJson(Map<String, dynamic> json) =>
      RERADocumentModel(
        projectRERADocumentId: parseValue<int>(json, "ProjectRERADocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        projectRERADocumentName: parseValue<String>(
          json,
          "ProjectRERADocumentName",
        ),
        projectRERADocumentCategoryId: parseValue<int>(
          json,
          "ProjectRERADocumentCategoryId",
        ),
        projectRERADocumentCategory: parseValue<String>(
          json,
          "ProjectRERADocumentCategory",
        ),
        projectRERADocumentRemark: parseValue<String>(
          json,
          "ProjectRERADocumentRemark",
        ),
        projectRERADocumentStatus: parseValue<String>(
          json,
          "ProjectRERADocumentStatus",
        ),
        reraPortalScreenShotURL: parseValue<String>(
          json,
          "RERAPortalScreenShotURL",
        ),
        projectRERADocumentURL: parseValue<String>(
          json,
          "ProjectRERADocumentURL",
        ),
        projectRERADocumentApprovalStatus: parseValue<String>(
          json,
          "ProjectRERADocumentApprovalStatus",
        ),
        uploadedProjectRERADocumentCount: parseValue<int>(
          json,
          "UploadedProjectRERADocumentCount",
        ),
        approvalPendingProjectRERADocumentCount: parseValue<int>(
          json,
          "ApprovalPendingProjectRERADocumentCount",
        ),
        rejectedProjectRERADocumentCount: parseValue<int>(
          json,
          "RejectedProjectRERADocumentCount",
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
    "ProjectRERADocumentId": projectRERADocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectRERADocumentName": projectRERADocumentName,
    "ProjectRERADocumentCategoryId": projectRERADocumentCategoryId,
    "ProjectRERADocumentCategory": projectRERADocumentCategory,
    "ProjectRERADocumentRemark": projectRERADocumentRemark,
    "ProjectRERADocumentStatus": projectRERADocumentStatus,
    "RERAPortalScreenShotURL": reraPortalScreenShotURL,
    "ProjectRERADocumentURL": projectRERADocumentURL,
    "ProjectRERADocumentApprovalStatus": projectRERADocumentApprovalStatus,
    "UploadedProjectRERADocumentCount": uploadedProjectRERADocumentCount,
    "ApprovalPendingProjectRERADocumentCount":
        approvalPendingProjectRERADocumentCount,
    "RejectedProjectRERADocumentCount": rejectedProjectRERADocumentCount,
    "IsApproval": isApproval,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

extension DocumentModelCopyWith on RERADocumentModel {
  RERADocumentModel copyWith({
    int? projectRERADocumentId,
    String? uniquekey,
    int? projectId,
    String? projectRERADocumentName,
    int? projectRERADocumentCategoryId,
    String? projectRERADocumentCategory,
    String? projectRERADocumentRemark,
    String? projectRERADocumentStatus,
    String? reraPortalScreenShotURL,
    String? projectRERADocumentURL,
    String? projectRERADocumentApprovalStatus,
    int? uploadedProjectRERADocumentCount,
    int? approvalPendingProjectRERADocumentCount,
    int? rejectedProjectRERADocumentCount,
    bool? isApproval,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return RERADocumentModel(
      projectRERADocumentId:
          projectRERADocumentId ?? this.projectRERADocumentId,
      uniquekey: uniquekey ?? this.uniquekey,
      projectId: projectId ?? this.projectId,
      projectRERADocumentName:
          projectRERADocumentName ?? this.projectRERADocumentName,
      projectRERADocumentCategoryId:
          projectRERADocumentCategoryId ?? this.projectRERADocumentCategoryId,
      projectRERADocumentCategory:
          projectRERADocumentCategory ?? this.projectRERADocumentCategory,
      projectRERADocumentRemark:
          projectRERADocumentRemark ?? this.projectRERADocumentRemark,
      projectRERADocumentStatus:
          projectRERADocumentStatus ?? this.projectRERADocumentStatus,
      projectRERADocumentURL:
          projectRERADocumentURL ?? this.projectRERADocumentURL,
      reraPortalScreenShotURL:
          reraPortalScreenShotURL ?? this.reraPortalScreenShotURL,
      projectRERADocumentApprovalStatus:
          projectRERADocumentApprovalStatus ??
          this.projectRERADocumentApprovalStatus,
      uploadedProjectRERADocumentCount:
          uploadedProjectRERADocumentCount ??
          this.uploadedProjectRERADocumentCount,
      approvalPendingProjectRERADocumentCount:
          approvalPendingProjectRERADocumentCount ??
          this.approvalPendingProjectRERADocumentCount,
      rejectedProjectRERADocumentCount:
          rejectedProjectRERADocumentCount ??
          this.rejectedProjectRERADocumentCount,
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
