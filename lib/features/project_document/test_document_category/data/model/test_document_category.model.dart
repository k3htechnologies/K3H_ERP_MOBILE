import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TestDocumentCategoryModel {
  int testDocumentCategoryId;
  int projectId;
  String uniquekey;
  String testDocumentCategoryName;
  int orderBy;
  int documentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TestDocumentCategoryModel({
    required this.testDocumentCategoryId,
    required this.projectId,
    required this.uniquekey,
    required this.testDocumentCategoryName,
    required this.orderBy,
    required this.documentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TestDocumentCategoryModel.fromJson(Map<String, dynamic> json) =>
      TestDocumentCategoryModel(
        testDocumentCategoryId: parseValue<int>(json, "TestDocumentCategoryId"),
        projectId: parseValue<int>(json, "ProjectId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        testDocumentCategoryName: parseValue<String>(
          json,
          "TestDocumentCategoryName",
        ),
        orderBy: parseValue<int>(json, "OrderBy"),
        documentCount: parseValue<int>(json, "DocumentCount"),
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
    "TestDocumentCategoryId": testDocumentCategoryId,
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "TestDocumentCategoryName": testDocumentCategoryName,
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
