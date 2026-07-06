import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectCompletionModel {
  int proposedOfferProjectCompletionId;
  String uniquekey;
  int buildingId;
  int projectId;
  int completionTimelineMonths;
  int gracePeriodMonths;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProjectCompletionModel({
    required this.proposedOfferProjectCompletionId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.completionTimelineMonths,
    required this.gracePeriodMonths,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProjectCompletionModel.fromJson(Map<String, dynamic> json) =>
      ProjectCompletionModel(
        proposedOfferProjectCompletionId: parseValue<int>(
          json,
          "ProposedOfferProjectCompletionId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        completionTimelineMonths: parseValue<int>(
          json,
          "CompletionTimelineMonths",
        ),
        gracePeriodMonths: parseValue<int>(json, "GracePeriodMonths"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null || json["ModifiedDate"] == ""
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ProposedOfferProjectCompletionId": proposedOfferProjectCompletionId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "CompletionTimelineMonths": completionTimelineMonths,
    "GracePeriodMonths": gracePeriodMonths,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
