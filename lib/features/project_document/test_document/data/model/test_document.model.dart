import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TestDocumentModel {
  int testDocumentId;
  String uniquekey;
  int projectId;
  String testDocumentName;
  int testDocumentCategoryId;
  String testDocumentCategory;
  DateTime? testDocumentExpiryDate;
  String testDocumentRemark;
  String testDocumentUrl;
  String approvalStatus;
  bool isApproval;
  int isMaster;
  int uploadedApprovalDocumentCount;
  int approvalPendingApprovalDocumentCount;
  int rejectedApprovalDocumentCount;
  int expiredApprovalDocumentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TestDocumentModel({
    required this.testDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.testDocumentName,
    required this.testDocumentCategoryId,
    required this.testDocumentCategory,
    required this.testDocumentExpiryDate,
    required this.testDocumentRemark,
    required this.testDocumentUrl,
    required this.approvalStatus,
    required this.isApproval,
    required this.isMaster,
    required this.uploadedApprovalDocumentCount,
    required this.approvalPendingApprovalDocumentCount,
    required this.rejectedApprovalDocumentCount,
    required this.expiredApprovalDocumentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TestDocumentModel.fromJson(Map<String, dynamic> json) =>
      TestDocumentModel(
        testDocumentId: parseValue<int>(json, "TestDocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        testDocumentName: parseValue<String>(json, "TestDocumentName"),
        testDocumentCategoryId: parseValue<int>(json, "TestDocumentCategoryId"),
        testDocumentCategory: parseValue<String>(json, "TestDocumentCategory"),
        testDocumentExpiryDate:
            json["TestDocumentExpiryDate"] == null
                ? null
                : DateTime.parse(json["TestDocumentExpiryDate"]),
        testDocumentRemark: parseValue<String>(json, "TestDocumentRemark"),
        testDocumentUrl: parseValue<String>(json, "TestDocumentURL"),
        approvalStatus: parseValue<String>(json, "ApprovalStatus"),
        isApproval: parseValue<bool>(json, "IsApproval"),
        isMaster: parseValue<int>(json, "IsMaster"),
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
        expiredApprovalDocumentCount: parseValue<int>(
          json,
          "ExpiredApprovalDocumentCount",
        ),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "TestDocumentId": testDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "TestDocumentName": testDocumentName,
    "TestDocumentCategoryId": testDocumentCategoryId,
    "TestDocumentCategory": testDocumentCategory,
    "TestDocumentExpiryDate": testDocumentExpiryDate?.toIso8601String(),
    "TestDocumentRemark": testDocumentRemark,
    "TestDocumentURL": testDocumentUrl,
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "IsMaster": isMaster,
    "UploadedApprovalDocumentCount": uploadedApprovalDocumentCount,
    "ApprovalPendingApprovalDocumentCount":
        approvalPendingApprovalDocumentCount,
    "RejectedApprovalDocumentCount": rejectedApprovalDocumentCount,
    "ExpiredApprovalDocumentCount": expiredApprovalDocumentCount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

extension TestDocumentModelCopyWith on TestDocumentModel {
  TestDocumentModel copyWith({
    int? testDocumentId,
    String? uniquekey,
    int? projectId,
    String? testDocumentName,
    int? testDocumentCategoryId,
    String? testDocumentCategory,
    DateTime? testDocumentExpiryDate,
    String? testDocumentRemark,
    String? testDocumentUrl,
    String? approvalStatus,
    bool? isApproval,
    int? isMaster,
    int? uploadedApprovalDocumentCount,
    int? approvalPendingApprovalDocumentCount,
    int? rejectedApprovalDocumentCount,
    int? expiredApprovalDocumentCount,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return TestDocumentModel(
      testDocumentId: testDocumentId ?? this.testDocumentId,
      uniquekey: uniquekey ?? this.uniquekey,
      projectId: projectId ?? this.projectId,
      testDocumentName: testDocumentName ?? this.testDocumentName,
      testDocumentCategoryId:
          testDocumentCategoryId ?? this.testDocumentCategoryId,
      testDocumentCategory: testDocumentCategory ?? this.testDocumentCategory,
      testDocumentExpiryDate:
          testDocumentExpiryDate ?? this.testDocumentExpiryDate,
      testDocumentRemark: testDocumentRemark ?? this.testDocumentRemark,
      testDocumentUrl: testDocumentUrl ?? this.testDocumentUrl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isApproval: isApproval ?? this.isApproval,
      isMaster: isMaster ?? this.isMaster,
      uploadedApprovalDocumentCount:
          uploadedApprovalDocumentCount ?? this.uploadedApprovalDocumentCount,
      approvalPendingApprovalDocumentCount:
          approvalPendingApprovalDocumentCount ??
          this.approvalPendingApprovalDocumentCount,
      rejectedApprovalDocumentCount:
          rejectedApprovalDocumentCount ?? this.rejectedApprovalDocumentCount,
      expiredApprovalDocumentCount:
          expiredApprovalDocumentCount ?? this.expiredApprovalDocumentCount,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
