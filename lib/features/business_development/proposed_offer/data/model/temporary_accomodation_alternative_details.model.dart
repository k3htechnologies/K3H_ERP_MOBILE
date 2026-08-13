import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TemporaryAlternativeAccommodationDetailsModel {
  int proposedOfferTemporaryAlternateAccommodationDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  bool isAdditionalTemporaryAlternateAccommodation;
  String type;
  String tenure;
  double amount;
  String unitSqFtLumsum;
  double carpetAreaSqFt;
  DateTime? temporaryAlternateAccommodationStartDate;
  DateTime? temporaryAlternateAccommodationEndDate;
  bool isPayBrokerage;
  bool isPayTAA;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TemporaryAlternativeAccommodationDetailsModel({
    required this.proposedOfferTemporaryAlternateAccommodationDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.isAdditionalTemporaryAlternateAccommodation,
    required this.type,
    required this.tenure,
    required this.amount,
    required this.unitSqFtLumsum,
    required this.carpetAreaSqFt,
    required this.temporaryAlternateAccommodationStartDate,
    required this.temporaryAlternateAccommodationEndDate,
    required this.isPayBrokerage,
    required this.isPayTAA,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TemporaryAlternativeAccommodationDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => TemporaryAlternativeAccommodationDetailsModel(
    proposedOfferTemporaryAlternateAccommodationDetailsId: parseValue<int>(
      json,
      "ProposedOfferTemporaryAlternateAccommodationDetailsId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    isAdditionalTemporaryAlternateAccommodation: parseValue<bool>(
      json,
      "IsAdditionalTemporaryAlternateAccommodation",
    ),
    type: parseValue<String>(json, "Type"),
    tenure: parseValue<String>(json, "Tenure"),
    amount: parseValue<double>(json, "Amount"),
    unitSqFtLumsum: parseValue<String>(json, "UnitSqFtLumsum"),
    carpetAreaSqFt: parseValue<double>(json, "CarpetAreaSqFt"),
    temporaryAlternateAccommodationStartDate:
        json["TemporaryAlternateAccommodationStartDate"] == null
            ? null
            : parseValue<DateTime>(
              json,
              "TemporaryAlternateAccommodationStartDate",
            ),
    temporaryAlternateAccommodationEndDate:
        json["TemporaryAlternateAccommodationEndDate"] == null
            ? null
            : parseValue<DateTime>(
              json,
              "TemporaryAlternateAccommodationEndDate",
            ),
    isPayBrokerage: parseValue<bool>(json, "IsPayBrokerage"),
    isPayTAA: parseValue<bool>(json, "IsPayTAA"),
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
    "ProposedOfferTemporaryAlternateAccommodationDetailsId":
        proposedOfferTemporaryAlternateAccommodationDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "IsAdditionalTemporaryAlternateAccommodation":
        isAdditionalTemporaryAlternateAccommodation,
    "Type": type,
    "Tenure": tenure,
    "Amount": amount,
    "UnitSqFtLumsum": unitSqFtLumsum,
    "CarpetAreaSqFt": carpetAreaSqFt,
    "TemporaryAlternateAccommodationStartDate":
        temporaryAlternateAccommodationStartDate?.toIso8601String(),
    "TemporaryAlternateAccommodationEndDate":
        temporaryAlternateAccommodationEndDate?.toIso8601String(),
    "IsPayBrokerage": isPayBrokerage,
    "IsPayTAA": isPayTAA,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
