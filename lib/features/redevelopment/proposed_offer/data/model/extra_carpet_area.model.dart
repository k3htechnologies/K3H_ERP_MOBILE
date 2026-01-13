import 'package:k3h_erp_app/utils/common_function.dart';

class ExtraCarpetAreaModel {
  int proposedOfferExtraCarpetAreaId;
  String uniquekey;
  int buildingId;
  int projectId;
  String extraCarpetAreaOfferedType;
  double residentialExtraCarpetPercent;
  double commercialExtraCarpetPercent;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ExtraCarpetAreaModel({
    required this.proposedOfferExtraCarpetAreaId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.extraCarpetAreaOfferedType,
    required this.residentialExtraCarpetPercent,
    required this.commercialExtraCarpetPercent,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ExtraCarpetAreaModel.fromJson(Map<String, dynamic> json) =>
      ExtraCarpetAreaModel(
        proposedOfferExtraCarpetAreaId: parseValue<int>(
          json,
          "ProposedOfferExtraCarpetAreaId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        extraCarpetAreaOfferedType: parseValue<String>(
          json,
          "ExtraCarpetAreaOfferedType",
        ),
        residentialExtraCarpetPercent: parseValue<double>(
          json,
          "ResidentialExtraCarpetPercent",
        ),
        commercialExtraCarpetPercent: parseValue<double>(
          json,
          "CommercialExtraCarpetPercent",
        ),
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
    "ProposedOfferExtraCarpetAreaId": proposedOfferExtraCarpetAreaId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ExtraCarpetAreaOfferedType": extraCarpetAreaOfferedType,
    "ResidentialExtraCarpetPercent": residentialExtraCarpetPercent,
    "CommercialExtraCarpetPercent": commercialExtraCarpetPercent,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
