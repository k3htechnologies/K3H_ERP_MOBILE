import 'package:k3h_erp_app/utils/functions/common_function.dart';

class InventoryDrawingDocumentModel {
  String drawingDocumentName;
  String drawingDocumentUrl;
  String drawingDocumentDwgurl;
  String drawingDocumentCategory;
  DateTime? drawingDocumentRevisionDate;
  String drawingDocumentRemark;
  String drawingDocumentStatus;
  String approvalStatus;
  String createdBy;
  DateTime createdDate;
  String modifiedBy;
  DateTime? modifiedDate;

  InventoryDrawingDocumentModel({
    required this.drawingDocumentName,
    required this.drawingDocumentUrl,
    required this.drawingDocumentDwgurl,
    required this.drawingDocumentCategory,
    required this.drawingDocumentRevisionDate,
    required this.drawingDocumentRemark,
    required this.drawingDocumentStatus,
    required this.approvalStatus,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory InventoryDrawingDocumentModel.fromJson(
    Map<String, dynamic> json,
  ) => InventoryDrawingDocumentModel(
    drawingDocumentName: parseValue<String>(json, "DrawingDocumentName"),
    drawingDocumentUrl: parseValue<String>(json, "DrawingDocumentURL"),
    drawingDocumentDwgurl: parseValue<String>(json, "DrawingDocumentDWGURL"),
    drawingDocumentCategory: parseValue<String>(
      json,
      "DrawingDocumentCategory",
    ),
    drawingDocumentRevisionDate:
        json["DrawingDocumentRevisionDate"] == null
            ? null
            : parseValue<DateTime>(json, "DrawingDocumentRevisionDate"),
    drawingDocumentRemark: parseValue<String>(json, "DrawingDocumentRemark"),
    drawingDocumentStatus: parseValue<String>(json, "DrawingDocumentStatus"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedBy: json["ModifiedBy"],
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "DrawingDocumentName": drawingDocumentName,
    "DrawingDocumentURL": drawingDocumentUrl,
    "DrawingDocumentDWGURL": drawingDocumentDwgurl,
    "DrawingDocumentCategory": drawingDocumentCategory,
    "DrawingDocumentRevisionDate":
        drawingDocumentRevisionDate?.toIso8601String(),
    "DrawingDocumentRemark": drawingDocumentRemark,
    "DrawingDocumentStatus": drawingDocumentStatus,
    "ApprovalStatus": approvalStatus,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
