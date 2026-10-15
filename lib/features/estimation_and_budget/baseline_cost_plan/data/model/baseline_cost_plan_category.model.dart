import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BaselineCostPlanDocumentCategory {
  int baselineCostPlanDocumentCategoryId;
  int projectId;
  String uniquekey;
  String baselineCostPlanDocumentCategoryName;
  int orderBy;
  int documentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BaselineCostPlanDocumentCategory({
    required this.baselineCostPlanDocumentCategoryId,
    required this.projectId,
    required this.uniquekey,
    required this.baselineCostPlanDocumentCategoryName,
    required this.orderBy,
    required this.documentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BaselineCostPlanDocumentCategory.fromJson(
    Map<String, dynamic> json,
  ) => BaselineCostPlanDocumentCategory(
    baselineCostPlanDocumentCategoryId: parseValue<int>(
      json,
      "BaselineCostPlanDocumentCategoryId",
    ),
    projectId: parseValue<int>(json, "ProjectId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    baselineCostPlanDocumentCategoryName: parseValue<String>(
      json,
      "BaselineCostPlanDocumentCategoryName",
    ),
    orderBy: parseValue<int>(json, "OrderBy"),
    documentCount: parseValue<int>(json, "DocumentCount"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "BaselineCostPlanDocumentCategoryId": baselineCostPlanDocumentCategoryId,
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "BaselineCostPlanDocumentCategoryName":
        baselineCostPlanDocumentCategoryName,
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
