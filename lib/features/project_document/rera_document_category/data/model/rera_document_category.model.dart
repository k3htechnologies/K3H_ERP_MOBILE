import 'package:k3h_erp_app/utils/common_function.dart';

class RERADocumentCategoryModel {
  int projectRERADocumentCategoryId;
  int projectId;
  String uniquekey;
  String projectRERADocumentCategoryName;
  int orderBy;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  RERADocumentCategoryModel({
    required this.projectRERADocumentCategoryId,
    required this.projectId,
    required this.uniquekey,
    required this.projectRERADocumentCategoryName,
    required this.orderBy,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RERADocumentCategoryModel.fromJson(Map<String, dynamic> json) =>
      RERADocumentCategoryModel(
        projectRERADocumentCategoryId: parseValue(
          json,
          "ProjectRERADocumentCategoryId",
        ),
        projectId: parseValue(json, "ProjectId"),
        uniquekey: parseValue(json, "Uniquekey"),
        projectRERADocumentCategoryName: parseValue(
          json,
          "ProjectRERADocumentCategoryName",
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
    "ProjectRERADocumentCategoryId": projectRERADocumentCategoryId,
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "ProjectRERADocumentCategoryName": projectRERADocumentCategoryName,
    "OrderBy": orderBy,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
