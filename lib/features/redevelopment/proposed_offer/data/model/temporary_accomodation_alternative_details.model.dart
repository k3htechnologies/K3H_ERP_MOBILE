import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TemporaryAccommodationAlternativeDetailsModel {
  int proposedOfferTemporaryAccommodationAlternativeDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  bool isAdditionalTemporaryAccommodationAlternative;
  String type;
  String tenure;
  double amount;
  String unitSqFtLumsum;
  double carpetAreaSqFt;
  DateTime temporaryAccommodationAlternativeStartDate;
  DateTime temporaryAccommodationAlternativeEndDate;
  bool isPayBrokerage;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TemporaryAccommodationAlternativeDetailsModel({
    required this.proposedOfferTemporaryAccommodationAlternativeDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.isAdditionalTemporaryAccommodationAlternative,
    required this.type,
    required this.tenure,
    required this.amount,
    required this.unitSqFtLumsum,
    required this.carpetAreaSqFt,
    required this.temporaryAccommodationAlternativeStartDate,
    required this.temporaryAccommodationAlternativeEndDate,
    required this.isPayBrokerage,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TemporaryAccommodationAlternativeDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => TemporaryAccommodationAlternativeDetailsModel(
    proposedOfferTemporaryAccommodationAlternativeDetailsId: parseValue<int>(
      json,
      "ProposedOfferTemporaryAccommodationAlternativeDetailsId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    isAdditionalTemporaryAccommodationAlternative: parseValue<bool>(
      json,
      "IsAdditionalTemporaryAccommodationAlternative",
    ),
    type: parseValue<String>(json, "Type"),
    tenure: parseValue<String>(json, "Tenure"),
    amount: parseValue<double>(json, "Amount"),
    unitSqFtLumsum: parseValue<String>(json, "UnitSqFtLumsum"),
    carpetAreaSqFt: parseValue<double>(json, "CarpetAreaSqFt"),
    temporaryAccommodationAlternativeStartDate: parseValue<DateTime>(
      json,
      "TemporaryAccommodationAlternativeStartDate",
    ),
    temporaryAccommodationAlternativeEndDate: parseValue<DateTime>(
      json,
      "TemporaryAccommodationAlternativeEndDate",
    ),
    isPayBrokerage: parseValue<bool>(json, "IsPayBrokerage"),
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
    "ProposedOfferTemporaryAccommodationAlternativeDetailsId":
        proposedOfferTemporaryAccommodationAlternativeDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "IsAdditionalTemporaryAccommodationAlternative":
        isAdditionalTemporaryAccommodationAlternative,
    "Type": type,
    "Tenure": tenure,
    "Amount": amount,
    "UnitSqFtLumsum": unitSqFtLumsum,
    "CarpetAreaSqFt": carpetAreaSqFt,
    "TemporaryAccommodationAlternativeStartDate":
        temporaryAccommodationAlternativeStartDate.toIso8601String(),
    "TemporaryAccommodationAlternativeEndDate":
        temporaryAccommodationAlternativeEndDate.toIso8601String(),
    "IsPayBrokerage": isPayBrokerage,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
