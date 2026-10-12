import 'package:k3h_erp_app/utils/functions/common_function.dart';

class DrawingDocumentModel {
  int drawingDocumentId;
  String uniquekey;
  int projectId;
  String drawingDocumentName;
  int drawingDocumentCategoryId;
  String drawingDocumentCategory;
  DateTime? drawingDocumentRevisionDate;
  String drawingDocumentRemark;
  String drawingDocumentStatus;
  String drawingDocumentUrl;
  String drawingDocumentDwgurl;
  String approvalStatus;
  bool isApproval;
  int isMaster;
  int inventoryFloorId;
  String floor;
  int uploadedApprovalDocumentCount;
  int approvalPendingApprovalDocumentCount;
  int rejectedApprovalDocumentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  DrawingDocumentModel({
    required this.drawingDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.drawingDocumentName,
    required this.drawingDocumentCategoryId,
    required this.drawingDocumentCategory,
    required this.drawingDocumentRevisionDate,
    required this.drawingDocumentRemark,
    required this.drawingDocumentStatus,
    required this.drawingDocumentUrl,
    required this.drawingDocumentDwgurl,
    required this.approvalStatus,
    required this.isApproval,
    required this.isMaster,
    required this.inventoryFloorId,
    required this.floor,
    required this.uploadedApprovalDocumentCount,
    required this.approvalPendingApprovalDocumentCount,
    required this.rejectedApprovalDocumentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory DrawingDocumentModel.fromJson(
    Map<String, dynamic> json,
  ) => DrawingDocumentModel(
    drawingDocumentId: parseValue<int>(json, "DrawingDocumentId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    drawingDocumentName: parseValue<String>(json, "DrawingDocumentName"),
    drawingDocumentCategoryId: parseValue<int>(
      json,
      "DrawingDocumentCategoryId",
    ),
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
    drawingDocumentUrl: parseValue<String>(json, "DrawingDocumentURL"),
    drawingDocumentDwgurl: parseValue<String>(json, "DrawingDocumentDWGURL"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    isMaster: parseValue<int>(json, "IsMaster"),
    inventoryFloorId: parseValue<int>(json, "InventoryFloorId"),
    floor: parseValue<String>(json, "Floor"),
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
    "DrawingDocumentId": drawingDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "DrawingDocumentName": drawingDocumentName,
    "DrawingDocumentCategoryId": drawingDocumentCategoryId,
    "DrawingDocumentCategory": drawingDocumentCategory,
    "DrawingDocumentRevisionDate":
        drawingDocumentRevisionDate?.toIso8601String(),
    "DrawingDocumentRemark": drawingDocumentRemark,
    "DrawingDocumentStatus": drawingDocumentStatus,
    "DrawingDocumentURL": drawingDocumentUrl,
    "DrawingDocumentDWGURL": drawingDocumentDwgurl,
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "IsMaster": isMaster,
    "InventoryFloorId": inventoryFloorId,
    "Floor": floor,
    "UploadedApprovalDocumentCount": uploadedApprovalDocumentCount,
    "ApprovalPendingApprovalDocumentCount":
        approvalPendingApprovalDocumentCount,
    "RejectedApprovalDocumentCount": rejectedApprovalDocumentCount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

extension DrawingDocumentModelCopyWith on DrawingDocumentModel {
  DrawingDocumentModel copyWith({
    int? drawingDocumentId,
    String? uniquekey,
    int? projectId,
    String? drawingDocumentName,
    int? drawingDocumentCategoryId,
    String? drawingDocumentCategory,
    DateTime? drawingDocumentRevisionDate,
    String? drawingDocumentRemark,
    String? drawingDocumentStatus,
    String? drawingDocumentUrl,
    String? drawingDocumentDwgurl,
    String? approvalStatus,
    bool? isApproval,
    int? isMaster,
    int? inventoryFloorId,
    String? floor,
    int? uploadedApprovalDocumentCount,
    int? approvalPendingApprovalDocumentCount,
    int? rejectedApprovalDocumentCount,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return DrawingDocumentModel(
      drawingDocumentId: drawingDocumentId ?? this.drawingDocumentId,
      uniquekey: uniquekey ?? this.uniquekey,
      projectId: projectId ?? this.projectId,
      drawingDocumentName: drawingDocumentName ?? this.drawingDocumentName,
      drawingDocumentCategoryId:
          drawingDocumentCategoryId ?? this.drawingDocumentCategoryId,
      drawingDocumentCategory:
          drawingDocumentCategory ?? this.drawingDocumentCategory,
      drawingDocumentRevisionDate:
          drawingDocumentRevisionDate ?? this.drawingDocumentRevisionDate,
      drawingDocumentRemark:
          drawingDocumentRemark ?? this.drawingDocumentRemark,
      drawingDocumentStatus:
          drawingDocumentStatus ?? this.drawingDocumentStatus,
      drawingDocumentUrl: drawingDocumentUrl ?? this.drawingDocumentUrl,
      drawingDocumentDwgurl:
          drawingDocumentDwgurl ?? this.drawingDocumentDwgurl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isApproval: isApproval ?? this.isApproval,
      isMaster: isMaster ?? this.isMaster,
      inventoryFloorId: inventoryFloorId ?? this.inventoryFloorId,
      floor: floor ?? this.floor,
      uploadedApprovalDocumentCount:
          uploadedApprovalDocumentCount ?? this.uploadedApprovalDocumentCount,
      approvalPendingApprovalDocumentCount:
          approvalPendingApprovalDocumentCount ??
          this.approvalPendingApprovalDocumentCount,
      rejectedApprovalDocumentCount:
          rejectedApprovalDocumentCount ?? this.rejectedApprovalDocumentCount,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
