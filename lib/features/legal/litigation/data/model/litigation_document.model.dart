import 'package:k3h_erp_app/utils/common_function.dart';

class LitigationDocumentModel {
  int litigationHearingId;
  int litigationDocumentId;
  String uniquekey;
  int projectId;
  int litigationId;
  String documentName;
  String documentUrl;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LitigationDocumentModel({
    required this.litigationHearingId,
    required this.litigationDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.litigationId,
    required this.documentName,
    required this.documentUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LitigationDocumentModel.fromJson(Map<String, dynamic> json) {
    return LitigationDocumentModel(
      litigationHearingId: parseValue<int>(json, "LitigationHearingId"),
      litigationDocumentId: parseValue<int>(json, "LitigationDocumentId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      projectId: parseValue<int>(json, "ProjectId"),
      litigationId: parseValue<int>(json, "LitigationId"),
      documentName: parseValue<String>(json, "DocumentName"),
      documentUrl: parseValue<String>(json, "DocumentURL"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate:
          json["CreatedDate"] == null
              ? null
              : parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] == null
              ? null
              : parseValue<DateTime>(json, "ModifiedDate"),
    );
  }

  Map<String, dynamic> toJson() => {
    "LitigationHearingId": litigationDocumentId,
    "LitigationDocumentId": litigationDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "LitigationId": litigationId,
    "DocumentName": documentName,
    "DocumentURL": documentUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
