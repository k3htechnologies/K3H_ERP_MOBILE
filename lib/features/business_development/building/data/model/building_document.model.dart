import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BuildingDocumentModel {
  int buildingDocumentId;
  String uniquekey;
  int buildingId;
  int projectId;
  String documentName;
  String documentURL;
  int uploadedBuildingDocumentCount;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String documentRemark;

  BuildingDocumentModel({
    required this.buildingDocumentId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.documentName,
    required this.documentURL,
    required this.uploadedBuildingDocumentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.documentRemark,
  });

  factory BuildingDocumentModel.fromJson(Map<String, dynamic> json) =>
      BuildingDocumentModel(
        buildingDocumentId: parseValue<int>(json, "BuildingDocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        documentName: parseValue<String>(json, "DocumentName"),
        documentURL: parseValue<String>(json, "DocumentURL"),
        uploadedBuildingDocumentCount: parseValue<int>(
          json,
          "UploadedBuildingDocumentCount",
        ),
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
        documentRemark: parseValue<String>(json, "DocumentRemark"),
      );

  Map<String, dynamic> toJson() => {
    "BuildingDocumentId": buildingDocumentId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "DocumentName": documentName,
    "DocumentURL": documentURL,
    "UploadedBuildingDocumentCount": uploadedBuildingDocumentCount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "DocumentRemark": documentRemark,
  };
}
