import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BaselineCostPlanDocumentModel {
  int baselineCostPlanDocumentId;
  String uniquekey;
  int projectId;
  String baselineCostPlanDocumentName;
  int baselineCostPlanDocumentCategoryId;
  String baselineCostPlanDocumentCategory;
  String baselineCostPlanDocumentRemark;
  String baselineCostPlanDocumentUrl;
  double baselineCostPlanValue;
  int isMaster;
  int uploadedDocumentCount;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BaselineCostPlanDocumentModel({
    required this.baselineCostPlanDocumentId,
    required this.uniquekey,
    required this.projectId,
    required this.baselineCostPlanDocumentName,
    required this.baselineCostPlanDocumentCategoryId,
    required this.baselineCostPlanDocumentCategory,
    required this.baselineCostPlanDocumentRemark,
    required this.baselineCostPlanDocumentUrl,
    required this.baselineCostPlanValue,
    required this.isMaster,
    required this.uploadedDocumentCount,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BaselineCostPlanDocumentModel.fromJson(Map<String, dynamic> json) =>
      BaselineCostPlanDocumentModel(
        baselineCostPlanDocumentId: parseValue<int>(
          json,
          "BaselineCostPlanDocumentId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        baselineCostPlanDocumentName: parseValue<String>(
          json,
          "BaselineCostPlanDocumentName",
        ),
        baselineCostPlanDocumentCategoryId: parseValue<int>(
          json,
          "BaselineCostPlanDocumentCategoryId",
        ),
        baselineCostPlanDocumentCategory: parseValue<String>(
          json,
          "BaselineCostPlanDocumentCategory",
        ),
        baselineCostPlanDocumentRemark: parseValue<String>(
          json,
          "BaselineCostPlanDocumentRemark",
        ),
        baselineCostPlanDocumentUrl: json["BaselineCostPlanDocumentURL"],
        baselineCostPlanValue: parseValue<double>(
          json,
          "BaselineCostPlanValue",
        ),
        isMaster: parseValue<int>(json, "IsMaster"),
        uploadedDocumentCount: parseValue<int>(json, "UploadedDocumentCount"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : DateTime.parse(json["ModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
    "BaselineCostPlanDocumentId": baselineCostPlanDocumentId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "BaselineCostPlanDocumentName": baselineCostPlanDocumentName,
    "BaselineCostPlanDocumentCategoryId": baselineCostPlanDocumentCategoryId,
    "BaselineCostPlanDocumentCategory": baselineCostPlanDocumentCategory,
    "BaselineCostPlanDocumentRemark": baselineCostPlanDocumentRemark,
    "BaselineCostPlanDocumentURL": baselineCostPlanDocumentUrl,
    "BaselineCostPlanValue": baselineCostPlanValue,
    "IsMaster": isMaster,
    "UploadedDocumentCount": uploadedDocumentCount,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

extension BaselineCostPlanDocumentModelCopyWith
    on BaselineCostPlanDocumentModel {
  BaselineCostPlanDocumentModel copyWith({
    int? baselineCostPlanDocumentId,
    String? uniquekey,
    int? projectId,
    String? baselineCostPlanDocumentName,
    int? baselineCostPlanDocumentCategoryId,
    String? baselineCostPlanDocumentCategory,
    String? baselineCostPlanDocumentRemark,
    String? baselineCostPlanDocumentUrl,
    double? baselineCostPlanValue,
    int? isMaster,
    int? uploadedDocumentCount,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return BaselineCostPlanDocumentModel(
      baselineCostPlanDocumentId:
          baselineCostPlanDocumentId ?? this.baselineCostPlanDocumentId,
      uniquekey: uniquekey ?? this.uniquekey,
      projectId: projectId ?? this.projectId,
      baselineCostPlanDocumentName:
          baselineCostPlanDocumentName ?? this.baselineCostPlanDocumentName,
      baselineCostPlanDocumentCategoryId:
          baselineCostPlanDocumentCategoryId ??
          this.baselineCostPlanDocumentCategoryId,
      baselineCostPlanDocumentCategory:
          baselineCostPlanDocumentCategory ??
          this.baselineCostPlanDocumentCategory,
      baselineCostPlanDocumentRemark:
          baselineCostPlanDocumentRemark ?? this.baselineCostPlanDocumentRemark,
      baselineCostPlanDocumentUrl:
          baselineCostPlanDocumentUrl ?? this.baselineCostPlanDocumentUrl,
      baselineCostPlanValue:
          baselineCostPlanValue ?? this.baselineCostPlanValue,
      isMaster: isMaster ?? this.isMaster,
      uploadedDocumentCount:
          uploadedDocumentCount ?? this.uploadedDocumentCount,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
