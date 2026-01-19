import 'package:k3h_erp_app/utils/common_function.dart';

class ApprovalDocumentCategoryModel {
  int approvalDocumentCategoryId;
  int projectId;
  String uniquekey;
  String approvalDocumentCategoryName;
  int orderBy;
  int documentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ApprovalDocumentCategoryModel({
    required this.approvalDocumentCategoryId,
    required this.projectId,
    required this.uniquekey,
    required this.approvalDocumentCategoryName,
    required this.orderBy,
    required this.documentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ApprovalDocumentCategoryModel.fromJson(Map<String, dynamic> json) =>
      ApprovalDocumentCategoryModel(
        approvalDocumentCategoryId: parseValue(
          json,
          "ApprovalDocumentCategoryId",
        ),
        projectId: parseValue(json, "ProjectId"),
        uniquekey: parseValue(json, "Uniquekey"),
        approvalDocumentCategoryName: parseValue(
          json,
          "ApprovalDocumentCategoryName",
        ),
        orderBy: parseValue(json, "OrderBy"),
        documentCount: parseValue(json, "DocumentCount"),
        createdById: parseValue(json, "CreatedById"),
        createdBy: parseValue(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue(json, "ModifiedById"),
        modifiedBy: parseValue(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "ApprovalDocumentCategoryId": approvalDocumentCategoryId,
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "ApprovalDocumentCategoryName": approvalDocumentCategoryName,
    "OrderBy": orderBy,
    "DocumentCount": documentCount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
