import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TermSheetDocumentModel {
  int termSheetDocumentId;
  String uniquekey;
  int projectId;
  int termSheetId;
  int termSheetDetailsId;
  String documentName;
  String documentUrl;
  String documentRemark;
  bool isSubmittedOriginalDocument;
  bool isCollectedOriginalDocument;
  DateTime? collectedOriginalDocumentDate;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TermSheetDocumentModel({
    required this.termSheetDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.termSheetId,
    required this.termSheetDetailsId,
    required this.documentName,
    required this.documentUrl,
    required this.documentRemark,
    required this.isSubmittedOriginalDocument,
    required this.isCollectedOriginalDocument,
    required this.collectedOriginalDocumentDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TermSheetDocumentModel.fromJson(Map<String, dynamic> json) =>
      TermSheetDocumentModel(
        termSheetDocumentId: parseValue<int>(json, "TermSheetDocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        termSheetId: parseValue<int>(json, "TermSheetId"),
        termSheetDetailsId: parseValue<int>(json, "TermSheetDetailsId"),
        documentName: parseValue<String>(json, "DocumentName"),
        documentUrl: parseValue<String>(json, "DocumentURL"),
        documentRemark: parseValue<String>(json, "DocumentRemark"),
        isSubmittedOriginalDocument: parseValue<bool>(
          json,
          "IsSubmittedOriginalDocument",
        ),
        isCollectedOriginalDocument: parseValue<bool>(
          json,
          "IsCollectedOriginalDocument",
        ),
        collectedOriginalDocumentDate:
            json["CollectedOriginalDocumentDate"] == null
                ? null
                : DateTime.parse(json["CollectedOriginalDocumentDate"]),
        createdById: json["CreatedById"],
        createdBy: json["CreatedBy"],
        createdDate:
            json["CreatedDate"] == null
                ? null
                : DateTime.parse(json["CreatedDate"]),
        modifiedById: json["ModifiedById"],
        modifiedBy: json["ModifiedBy"],
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "TermSheetDocumentId": termSheetDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "TermSheetId": termSheetId,
    "TermSheetDetailsId": termSheetDetailsId,
    "DocumentName": documentName,
    "DocumentURL": documentUrl,
    "DocumentRemark": documentRemark,
    "IsSubmittedOriginalDocument": isSubmittedOriginalDocument,
    "IsCollectedOriginalDocument": isCollectedOriginalDocument,
    "CollectedOriginalDocumentDate":
        collectedOriginalDocumentDate?.toIso8601String(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
