import 'package:k3h_erp_app/utils/common_function.dart';

class DocumentCategoryModel {
  int projectDocumentCategoryId;
  int projectId;
  String uniquekey;
  String projectDocumentCategoryName;
  int orderBy;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DocumentCategoryModel({
    required this.projectDocumentCategoryId,
    required this.projectId,
    required this.uniquekey,
    required this.projectDocumentCategoryName,
    required this.orderBy,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) =>
      DocumentCategoryModel(
        projectDocumentCategoryId: parseValue(
          json,
          "ProjectDocumentCategoryId",
        ),
        projectId: parseValue(json, "ProjectId"),
        uniquekey: parseValue(json, "Uniquekey"),
        projectDocumentCategoryName: parseValue(
          json,
          "ProjectDocumentCategoryName",
        ),
        orderBy: parseValue(json, "OrderBy"),
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
    "ProjectDocumentCategoryId": projectDocumentCategoryId,
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "ProjectDocumentCategoryName": projectDocumentCategoryName,
    "OrderBy": orderBy,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
