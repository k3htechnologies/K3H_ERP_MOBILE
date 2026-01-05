import 'package:k3h_erp_app/utils/common_function.dart';

class BuildingDocumentModel {
  int buildingDocumentId;
  String uniquekey;
  int buildingId;
  int projectId;
  String documentName;
  String documentURL;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BuildingDocumentModel({
    required this.buildingDocumentId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.documentName,
    required this.documentURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BuildingDocumentModel.fromJson(Map<String, dynamic> json) =>
      BuildingDocumentModel(
        buildingDocumentId: parseValue<int>(json, "BuildingDocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        documentName: parseValue<String>(json, "DocumentName"),
        documentURL: parseValue<String>(json, "DocumentURL"),
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

  Map<String, dynamic> toJson() => {
    "BuildingDocumentId": buildingDocumentId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "DocumentName": documentName,
    "DocumentURL": documentURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };

  factory BuildingDocumentModel.empty() => BuildingDocumentModel(
    buildingDocumentId: -1,
    uniquekey: '',
    buildingId: -1,
    projectId: -1,
    documentName: '',
    documentURL: '',
    createdById: -1,
    createdBy: '',
    createdDate: DateTime.now(),
    modifiedById: -1,
    modifiedBy: '',
    modifiedDate: null,
  );

  BuildingDocumentModel copyWith({
    int? buildingDocumentId,
    String? uniquekey,
    int? buildingId,
    int? projectId,
    String? documentName,
    String? documentURL,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return BuildingDocumentModel(
      buildingDocumentId: buildingDocumentId ?? this.buildingDocumentId,
      uniquekey: uniquekey ?? this.uniquekey,
      buildingId: buildingId ?? this.buildingId,
      projectId: projectId ?? this.projectId,
      documentName: documentName ?? this.documentName,
      documentURL: documentURL ?? this.documentURL,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
