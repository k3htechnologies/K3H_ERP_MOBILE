// To parse this JSON data, do
//
//     final proposedPlansModel = proposedPlansModelFromJson(jsonString);

import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

ProposedPlansModel proposedPlansModelFromJson(String str) =>
    ProposedPlansModel.fromJson(json.decode(str));

String proposedPlansModelToJson(ProposedPlansModel data) =>
    json.encode(data.toJson());

class ProposedPlansModel {
  int proposedOfferProposedPlanId;
  String uniquekey;
  int projectId;
  int totalNumberOfFloors;
  int totalUnits;
  String planDocumentUrl;
  int totalParking;
  String amenities;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProposedPlansModel({
    required this.proposedOfferProposedPlanId,
    required this.uniquekey,
    required this.projectId,
    required this.totalNumberOfFloors,
    required this.totalUnits,
    required this.planDocumentUrl,
    required this.totalParking,
    required this.amenities,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProposedPlansModel.fromJson(Map<String, dynamic> json) =>
      ProposedPlansModel(
        proposedOfferProposedPlanId: parseValue<int>(
          json,
          "ProposedOfferProposedPlanId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        totalNumberOfFloors: parseValue<int>(json, "TotalNumberOfFloors"),
        totalUnits: parseValue<int>(json, "TotalUnits"),
        planDocumentUrl: parseValue<String>(json, "PlanDocumentURL"),
        totalParking: parseValue<int>(json, "TotalParking"),
        amenities: parseValue<String>(json, "Amenities"),
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
    "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "TotalNumberOfFloors": totalNumberOfFloors,
    "TotalUnits": totalUnits,
    "PlanDocumentURL": planDocumentUrl,
    "TotalParking": totalParking,
    "Amenities": amenities,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
