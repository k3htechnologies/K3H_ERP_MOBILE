import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ReadyReckonerRateDetailsModel {
  int proposedOfferReadyReckonerRateDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  double residentialRate;
  double commercialRate;
  double shopRate;
  double industrialRate;
  double landRate;
  DateTime effectiveStartDate;
  DateTime effectiveEndDate;
  String financialYear;
  String remark;
  String zone;
  String subZone;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ReadyReckonerRateDetailsModel({
    required this.proposedOfferReadyReckonerRateDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.residentialRate,
    required this.commercialRate,
    required this.shopRate,
    required this.industrialRate,
    required this.landRate,
    required this.effectiveStartDate,
    required this.effectiveEndDate,
    required this.financialYear,
    required this.remark,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.zone,
    required this.subZone,
  });

  factory ReadyReckonerRateDetailsModel.fromJson(Map<String, dynamic> json) =>
      ReadyReckonerRateDetailsModel(
        proposedOfferReadyReckonerRateDetailsId: parseValue<int>(
          json,
          "ProposedOfferReadyReckonerRateDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        residentialRate: parseValue<double>(json, "ResidentialRate"),
        commercialRate: parseValue<double>(json, "CommercialRate"),
        shopRate: parseValue<double>(json, "ShopRate"),
        industrialRate: parseValue<double>(json, "IndustrialRate"),
        landRate: parseValue<double>(json, "LandRate"),
        effectiveStartDate: parseValue<DateTime>(json, "EffectiveStartDate"),
        effectiveEndDate: parseValue<DateTime>(json, "EffectiveEndDate"),
        financialYear: parseValue<String>(json, "FinancialYear"),
        remark: parseValue<String>(json, "Remark"),
        zone: parseValue<String>(json, "Zone"),
        subZone: parseValue<String>(json, "SubZone"),
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
    "ProposedOfferReadyReckonerRateDetailsId":
        proposedOfferReadyReckonerRateDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ResidentialRate": residentialRate,
    "CommercialRate": commercialRate,
    "ShopRate": shopRate,
    "IndustrialRate": industrialRate,
    "LandRate": landRate,
    "EffectiveStartDate": effectiveStartDate.toIso8601String(),
    "EffectiveEndDate": effectiveEndDate.toIso8601String(),
    "FinancialYear": financialYear,
    "Remark": remark,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "Zone": zone,
    "SubZone": subZone,
  };
}
