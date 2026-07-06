import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ClassificationParameterModel {
  final int classificationParameterId;
  final String uniquekey;
  final int projectId;
  final String minBudget;
  final String possessionType;
  final String requirement;
  final String requirementType;
  final String villageMasterId;
  final String villageName;
  final String timeLine;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  ClassificationParameterModel({
    required this.classificationParameterId,
    required this.uniquekey,
    required this.projectId,
    required this.minBudget,
    required this.possessionType,
    required this.requirement,
    required this.requirementType,
    required this.villageMasterId,
    required this.villageName,
    required this.timeLine,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ClassificationParameterModel.fromJson(Map<String, dynamic> json) =>
      ClassificationParameterModel(
        classificationParameterId: parseValue<int>(
          json,
          "ClassificationParameterId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        minBudget: parseValue<String>(json, "MinBudget"),
        possessionType: parseValue<String>(json, "PossessionType"),
        requirement: parseValue<String>(json, "Requirement"),
        requirementType: parseValue<String>(json, "RequirementType"),
        villageMasterId: parseValue<String>(json, "VillageMasterId"),
        villageName: parseValue<String>(json, "VillageName"),
        timeLine: parseValue<String>(json, "TimeLine"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ClassificationParameterId": classificationParameterId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "MinBudget": minBudget,
    "PossessionType": possessionType,
    "Requirement": requirement,
    "RequirementType": requirementType,
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "TimeLine": timeLine,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate!.toIso8601String(),
  };
}
