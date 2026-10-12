import 'package:k3h_erp_app/utils/functions/common_function.dart';

class DrawingDocumentCategoryModel {
  int drawingDocumentCategoryId;
  int projectId;
  String uniquekey;
  String drawingDocumentCategoryName;
  int orderBy;
  int documentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DrawingDocumentCategoryModel({
    required this.drawingDocumentCategoryId,
    required this.projectId,
    required this.uniquekey,
    required this.drawingDocumentCategoryName,
    required this.orderBy,
    required this.documentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DrawingDocumentCategoryModel.fromJson(Map<String, dynamic> json) =>
      DrawingDocumentCategoryModel(
        drawingDocumentCategoryId: parseValue<int>(
          json,
          "DrawingDocumentCategoryId",
        ),
        projectId: parseValue<int>(json, "ProjectId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        drawingDocumentCategoryName: parseValue<String>(
          json,
          "DrawingDocumentCategoryName",
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
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "DrawingDocumentCategoryId": drawingDocumentCategoryId,
    "ProjectId": projectId,
    "Uniquekey": uniquekey,
    "DrawingDocumentCategoryName": drawingDocumentCategoryName,
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
